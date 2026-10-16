import Foundation

enum MIDI {
    private struct Event { var tick: Int; var bytes: [UInt8]; var order: Int }
    private struct RawNote { var start: Int; var end: Int; var pitch: Int; var program: Int; var channel: Int; var port: Int }
    private struct Tempo { var tick: Int; var microseconds: Int }
    private struct TrackState: Codable { var volume: Double; var muted: Bool; var solo: Bool }
    private static let melodicChannels = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15]
    private static func variable(_ value: Int) -> [UInt8] { var n = value, bytes = [UInt8(n & 127)]; n >>= 7; while n > 0 { bytes.insert(UInt8(n & 127) | 128, at: 0); n >>= 7 }; return bytes }
    private static func meta(_ type: UInt8, _ bytes: [UInt8]) -> [UInt8] { [255, type] + variable(bytes.count) + bytes }
    static func export(_ p: MusicProject) throws -> Data {
        try p.validate(); var data = Data()
        func text(_ s: String) { data.append(contentsOf: s.utf8) }
        func u16(_ n: UInt16) { data.append(UInt8(n >> 8)); data.append(UInt8(n & 255)) }
        func u32(_ n: UInt32) { data.append(contentsOf: [UInt8(n >> 24), UInt8((n >> 16) & 255), UInt8((n >> 8) & 255), UInt8(n & 255)]) }
        text("MThd"); u32(6); u16(1); u16(UInt16(p.tracks.count)); u16(480)
        let solo = p.tracks.contains { $0.solo }
        for (index, track) in p.tracks.enumerated() {
            var events: [Event] = []
            if index == 0 {
                let tempo = Int((60000000 / p.bpm).rounded())
                events.append(Event(tick: 0, bytes: [255, 81, 3, UInt8((tempo >> 16) & 255), UInt8((tempo >> 8) & 255), UInt8(tempo & 255)], order: 0))
            }
            // MIDI Port gives each set of fifteen melodic channels its own namespace.
            // Channel 9 is reserved for GM percussion and is never used for a pitched track.
            let channel = UInt8(melodicChannels[index % 15]), port = UInt8(index / 15)
            let program: UInt8 = track.instrument == .guitar ? 24 : track.instrument == .synth ? 89 : 0
            events.append(Event(tick: 0, bytes: meta(0x21, [port]), order: 0))
            events.append(Event(tick: 0, bytes: meta(0x03, Array(track.name.utf8)), order: 0))
            let state = TrackState(volume: track.volume, muted: track.muted, solo: track.solo)
            events.append(Event(tick: 0, bytes: meta(0x7f, Array("StarMusic1:".utf8) + Array(try JSONEncoder().encode(state))), order: 0))
            events.append(Event(tick: 0, bytes: [192 + channel, program], order: 1))
            let audible = !track.muted && (!solo || track.solo)
            events.append(Event(tick: 0, bytes: [176 + channel, 7, audible ? UInt8((track.volume * 127).rounded()) : 0], order: 1))
            for note in track.notes {
                guard let midi = note.midi else { continue }
                let start = Int((note.start * 480).rounded()), end = max(start + 1, Int(((note.start + note.duration) * 480).rounded()))
                events.append(Event(tick: start, bytes: [144 + channel, UInt8(midi), 100], order: 3))
                events.append(Event(tick: end, bytes: [128 + channel, UInt8(midi), 0], order: 2))
            }
            // Stable tie-breaking also keeps port/name metadata in the declared order.
            let sorted = events.enumerated().sorted { a, b in a.element.tick == b.element.tick ? (a.element.order == b.element.order ? a.offset < b.offset : a.element.order < b.element.order) : a.element.tick < b.element.tick }
            var bytes: [UInt8] = [], last = 0
            for item in sorted { bytes += variable(item.element.tick - last); bytes += item.element.bytes; last = item.element.tick }
            bytes += [0, 255, 47, 0]; text("MTrk"); u32(UInt32(bytes.count)); data.append(contentsOf: bytes)
        }
        return data
    }
    static func parse(_ data: Data) throws -> MusicProject {
        guard data.count <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
        var reader = Reader(bytes: Array(data)); guard try reader.text(4) == "MThd" else { throw MusicError.invalidMIDI }
        let headerLength = try reader.number(4), format = try reader.number(2), count = try reader.number(2), ppq = try reader.number(2)
        // 128 musical tracks plus an optional independent tempo conductor.
        guard headerLength >= 6, format <= 1, (1...129).contains(count), ppq > 0, ppq & 0x8000 == 0, format != 0 || count == 1 else { throw MusicError.invalidMIDI }
        try reader.skip(headerLength - 6)
        struct Chunk { var name: String; var notes: [RawNote]; var volumes: [Int: Double]; var state: TrackState? }
        var chunks: [Chunk] = [], tempos: [Tempo] = [], noteCount = 0, eventCount = 0
        for index in 0..<count {
            guard try reader.text(4) == "MTrk" else { throw MusicError.invalidMIDI }
            let size = try reader.number(4), end = reader.position + size
            guard end <= reader.bytes.count else { throw MusicError.invalidMIDI }
            var tick = 0, running: UInt8 = 0, notes: [RawNote] = [], open: [Int: [RawNote]] = [:], programs: [Int: Int] = [:], volumes: [Int: Double] = [:]
            var port = 0, name = "声部 \(index + 1)", state: TrackState?
            while reader.position < end {
                eventCount += 1; guard eventCount <= 1_000_000 else { throw MusicError.tooLarge }
                tick += try reader.variable(); var status = try reader.byte()
                if status < 128 { reader.position -= 1; status = running } else if status < 240 { running = status }
                guard status >= 128 else { throw MusicError.invalidMIDI }
                if status == 255 {
                    let type = try reader.byte(), length = try reader.variable(), bytes = try reader.take(length)
                    if type == 81 && length == 3 {
                        let tempo = Int(bytes[0]) << 16 | Int(bytes[1]) << 8 | Int(bytes[2]); guard tempo > 0 else { throw MusicError.invalidMIDI }
                        tempos.append(Tempo(tick: tick, microseconds: tempo))
                    }
                    if type == 0x21 && length == 1 { port = Int(bytes[0]) }
                    if type == 0x03 { name = String(String(decoding: bytes, as: UTF8.self).prefix(120)) }
                    if type == 0x7f, bytes.starts(with: Array("StarMusic1:".utf8)) { state = try JSONDecoder().decode(TrackState.self, from: Data(bytes.dropFirst(11))) }
                } else if status == 240 || status == 247 { let length = try reader.variable(); try reader.skip(length); running = 0 }
                else {
                    let type = status >> 4; guard (8...14).contains(type) else { throw MusicError.invalidMIDI }
                    let x = Int(try reader.byte()), y = type == 12 || type == 13 ? 0 : Int(try reader.byte()), channel = Int(status & 15), address = port * 16 + channel
                    guard x < 128, y < 128 else { throw MusicError.invalidMIDI }
                    let key = address * 128 + x
                    if type == 12 { programs[address] = x }
                    if type == 11 && x == 7 { volumes[address] = Double(y) / 127 }
                    if type == 9 && y > 0 {
                        noteCount += 1; guard noteCount <= 20000 else { throw MusicError.tooLarge }
                        open[key, default: []].append(RawNote(start: tick, end: tick, pitch: x, program: programs[address] ?? 0, channel: channel, port: port))
                    }
                    if type == 8 || (type == 9 && y == 0), var queue = open[key], !queue.isEmpty {
                        var note = queue.removeFirst(); open[key] = queue; note.end = tick
                        if note.end > note.start { notes.append(note) }
                    }
                }
                guard reader.position <= end else { throw MusicError.invalidMIDI }
            }
            chunks.append(Chunk(name: name, notes: notes, volumes: volumes, state: state))
        }
        let ordered = tempos.enumerated().sorted { $0.element.tick == $1.element.tick ? $0.offset < $1.offset : $0.element.tick < $1.element.tick }.map(\.element)
        let initial = ordered.last(where: { $0.tick == 0 })?.microseconds ?? 500000
        var p = MusicProject(); p.bpm = max(30, min(300, 60000000 / Double(initial))); p.tracks = []
        // Flatten a tempo map into absolute time on the app's single-clock beat grid.
        // This preserves every onset/duration instead of applying the last BPM globally.
        func seconds(_ tick: Int) -> Double {
            var previous = 0, tempo = 500000, result = 0.0
            for event in ordered where event.tick <= tick { result += Double(event.tick - previous) / Double(ppq) * Double(tempo) / 1_000_000; previous = event.tick; tempo = event.microseconds }
            return result + Double(tick - previous) / Double(ppq) * Double(tempo) / 1_000_000
        }
        let directBeats = ordered.allSatisfy { $0.microseconds == initial } && (30...300).contains(60000000 / Double(initial))
        for chunk in chunks {
            let groups = Dictionary(grouping: chunk.notes) { "\($0.port):\($0.channel):\($0.program)" }
            for key in groups.keys.sorted() {
                let values = groups[key]!, first = values[0]
                let instrument: Instrument = (24...31).contains(first.program) ? .guitar : first.program >= 80 ? .synth : .piano
                var track = MusicTrack(name: groups.count > 1 ? "\(chunk.name) · \(first.channel + 1)" : chunk.name, instrument: instrument)
                track.volume = chunk.state?.volume ?? chunk.volumes[first.port * 16 + first.channel] ?? 0.7
                track.muted = chunk.state?.muted ?? false; track.solo = chunk.state?.solo ?? false
                track.notes = values.map { note in
                    let start = seconds(note.start), finish = seconds(note.end)
                    return MusicNote(midi: note.pitch, start: directBeats ? Double(note.start) / Double(ppq) : start * p.bpm / 60, duration: directBeats ? Double(note.end - note.start) / Double(ppq) : (finish - start) * p.bpm / 60)
                }.sorted { $0.start < $1.start }
                p.tracks.append(track); guard p.tracks.count <= 128 else { throw MusicError.midiCapacity }
            }
        }
        if Set(ordered.map(\.microseconds)).count > 1 { p.source = "变速 MIDI 已按原始播放时间导入；使用统一节奏网格保留声音先后与时长。"; p.freeRhythm = true }
        guard !p.tracks.isEmpty else { throw MusicError.noNotes }; try p.validate(); return p
    }
    private struct Reader {
        var bytes: [UInt8]; var position = 0
        mutating func byte() throws -> UInt8 { guard position < bytes.count else { throw MusicError.invalidMIDI }; defer { position += 1 }; return bytes[position] }
        mutating func take(_ n: Int) throws -> [UInt8] { guard n >= 0, position <= bytes.count - n else { throw MusicError.invalidMIDI }; defer { position += n }; return Array(bytes[position..<(position + n)]) }
        mutating func text(_ n: Int) throws -> String { String(decoding: try take(n), as: UTF8.self) }
        mutating func number(_ n: Int) throws -> Int { var result = 0; for _ in 0..<n { result = (result << 8) | Int(try byte()) }; return result }
        mutating func skip(_ n: Int) throws { _ = try take(n) }
        mutating func variable() throws -> Int { var value = 0; for _ in 0..<4 { let b = try byte(); value = (value << 7) | Int(b & 127); if b & 128 == 0 { return value } }; throw MusicError.invalidMIDI }
    }
}
