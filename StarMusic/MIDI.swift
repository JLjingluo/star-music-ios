import Foundation

enum MIDI {
    static func export(_ p: MusicProject) throws -> Data {
        try p.validate(); var data = Data()
        func text(_ s: String) { data.append(contentsOf: s.utf8) }
        func u16(_ n: UInt16) { data.append(UInt8(n >> 8)); data.append(UInt8(n & 255)) }
        func u32(_ n: UInt32) { data.append(contentsOf: [UInt8(n >> 24), UInt8((n >> 16) & 255), UInt8((n >> 8) & 255), UInt8(n & 255)]) }
        func variable(_ value: Int) -> [UInt8] { var n = value, bytes = [UInt8(n & 127)]; n >>= 7; while n > 0 { bytes.insert(UInt8(n & 127) | 128, at: 0); n >>= 7 }; return bytes }
        text("MThd"); u32(6); u16(1); u16(UInt16(p.tracks.count)); u16(480)
        for (index, track) in p.tracks.enumerated() {
            var events: [(Int, [UInt8])] = []
            if index == 0 {
                let tempo = Int((60000000 / p.bpm).rounded())
                events.append((0, [255, 81, 3, UInt8((tempo >> 16) & 255), UInt8((tempo >> 8) & 255), UInt8(tempo & 255)]))
            }
            let channel = UInt8(index % 16), program: UInt8 = track.instrument == .guitar ? 24 : track.instrument == .synth ? 89 : 0
            events.append((0, [192 + channel, program]))
            for note in track.notes {
                guard let midi = note.midi else { continue }
                events.append((Int((note.start * 480).rounded()), [144 + channel, UInt8(midi), UInt8(max(1, Int(track.volume * 100)))]))
                events.append((Int(((note.start + note.duration) * 480).rounded()), [128 + channel, UInt8(midi), 0]))
            }
            events.sort { a, b in
                func priority(_ event: [UInt8]) -> Int { event[0] >= 192 ? 0 : event[0] >> 4 == 8 ? 1 : 2 }
                return a.0 == b.0 ? priority(a.1) < priority(b.1) : a.0 < b.0
            }
            var bytes: [UInt8] = [], last = 0
            for (tick, event) in events { bytes += variable(max(0, tick - last)); bytes += event; last = tick }
            bytes += [0, 255, 47, 0]; text("MTrk"); u32(UInt32(bytes.count)); data.append(contentsOf: bytes)
        }
        return data
    }
    static func parse(_ data: Data) throws -> MusicProject {
        var reader = Reader(bytes: Array(data)); guard try reader.text(4) == "MThd" else { throw MusicError.invalidMIDI }
        let headerLength = try reader.number(4), format = try reader.number(2), count = try reader.number(2), ppq = try reader.number(2)
        guard headerLength >= 6, format <= 1, count <= 64, ppq > 0, ppq & 0x8000 == 0 else { throw MusicError.invalidMIDI }
        try reader.skip(headerLength - 6)
        var p = MusicProject(); p.tracks = []
        for index in 0..<count {
            guard try reader.text(4) == "MTrk" else { throw MusicError.invalidMIDI }
            let size = try reader.number(4), end = reader.position + size
            guard end <= reader.bytes.count else { throw MusicError.invalidMIDI }
            var tick = 0, running: UInt8 = 0, notes: [MusicNote] = [], open: [Int: [(Int, Int)]] = [:], instrument = Instrument.piano
            while reader.position < end {
                tick += try reader.variable(); var status = try reader.byte()
                if status < 128 { reader.position -= 1; status = running } else if status < 240 { running = status }
                guard status >= 128 else { throw MusicError.invalidMIDI }
                if status == 255 {
                    let type = try reader.byte(), length = try reader.variable(), bytes = try reader.take(length)
                    if type == 81 && length == 3 { let tempo = Int(bytes[0]) << 16 | Int(bytes[1]) << 8 | Int(bytes[2]); guard tempo > 0 else { throw MusicError.invalidMIDI }; p.bpm = max(30, min(300, 60000000 / Double(tempo))) }
                } else if status == 240 || status == 247 { let length = try reader.variable(); try reader.skip(length) }
                else {
                    let type = status >> 4; guard (8...14).contains(type) else { throw MusicError.invalidMIDI }
                    let x = Int(try reader.byte()), y = type == 12 || type == 13 ? 0 : Int(try reader.byte()), key = Int(status & 15) * 128 + x
                    if type == 12 { instrument = (24...31).contains(x) ? .guitar : x >= 80 ? .synth : .piano }
                    if type == 9 && y > 0 { open[key, default: []].append((tick, x)) }
                    if type == 8 || (type == 9 && y == 0), var queue = open[key], !queue.isEmpty {
                        let note = queue.removeFirst(); open[key] = queue
                        notes.append(MusicNote(midi: note.1, start: Double(note.0) / Double(ppq), duration: max(0.125, Double(tick - note.0) / Double(ppq))))
                    }
                }
                guard reader.position <= end else { throw MusicError.invalidMIDI }
            }
            if !notes.isEmpty { p.tracks.append(MusicTrack(name: "声部 \(index + 1)", instrument: instrument, notes: notes.sorted { $0.start < $1.start })) }
        }
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
