import Foundation
import Combine

@MainActor final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [MusicProject] = []
    @Published var error: String?
    private(set) var unsavedProjects: [UUID: MusicProject] = [:]
    let root: URL
    var recordingDirectory: URL { root.appendingPathComponent("Recordings", isDirectory: true) }
    var projectDirectory: URL { root.appendingPathComponent("Projects", isDirectory: true) }
    private let encoder: JSONEncoder = { let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys]; return e }()
    private let decoder = JSONDecoder()
    init(root: URL? = nil) {
        self.root = root ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("StarMusic", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: projectDirectory, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: recordingDirectory, withIntermediateDirectories: true)
            try load()
            let marker = self.root.appendingPathComponent("initialized")
            if !FileManager.default.fileExists(atPath: marker.path) {
                for i in 0..<3 { try save(.example(i)) }
                try Data("1".utf8).write(to: marker, options: .atomic)
            }
        } catch { self.error = error.localizedDescription }
    }
    func load() throws {
        var valid: [MusicProject] = []; var rejected = 0
        for url in try FileManager.default.contentsOfDirectory(at: projectDirectory, includingPropertiesForKeys: nil) where url.pathExtension == "json" {
            do { let p = try decoder.decode(MusicProject.self, from: Data(contentsOf: url)); try p.validate(); valid.append(p) }
            catch { rejected += 1 }
        }
        projects = valid.sorted { $0.updated > $1.updated }
        if rejected > 0 { error = "有 \(rejected) 个草稿暂时无法读取；原文件仍保留在应用文件夹中。" }
    }
    func save(_ project: MusicProject) throws {
        try project.validate()
        let data = try encoder.encode(project)
        do { try data.write(to: projectDirectory.appendingPathComponent(project.id.uuidString + ".json"), options: .atomic) }
        catch { unsavedProjects[project.id] = project; throw error }
        unsavedProjects.removeValue(forKey: project.id)
        if let i = projects.firstIndex(where: { $0.id == project.id }) { projects[i] = project } else { projects.append(project) }
        projects.sort { $0.updated > $1.updated }
    }
    func update(_ project: MusicProject, _ change: (inout MusicProject) -> Void) {
        var p = project; change(&p); p.updated = Date()
        do { try save(p) } catch { self.error = error.localizedDescription }
    }
    func duplicate(_ p: MusicProject) throws {
        var copy = p; copy.id = UUID(); copy.name += " · 副本"; copy.sample = false; copy.updated = Date(); copy.created = Date()
        copy.tracks = copy.tracks.map { track in
            var t = track; t.id = UUID(); t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; return t
        }
        var replacements: [String: String] = [:]
        let files = Set(p.tracks.flatMap { ($0.sourceHistory ?? []) + [$0.recordingFile].compactMap { $0 } } + [p.recordingFile].compactMap { $0 })
        for file in files {
            let newName = UUID().uuidString + "." + URL(fileURLWithPath: file).pathExtension
            try FileManager.default.copyItem(at: recordingDirectory.appendingPathComponent(file), to: recordingDirectory.appendingPathComponent(newName))
            replacements[file] = newName
        }
        copy.recordingFile = p.recordingFile.flatMap { replacements[$0] }
        for index in copy.tracks.indices { copy.tracks[index].recordingFile = p.tracks[index].recordingFile.flatMap { replacements[$0] }; copy.tracks[index].sourceHistory = p.tracks[index].sourceHistory?.compactMap { replacements[$0] } }

        try save(copy)
    }
    func recordingURL(_ p: MusicProject, trackID: UUID? = nil) -> URL? {
        if let id = trackID, !p.tracks.contains(where: { $0.id == id }) { return nil }
        let track = trackID.flatMap { id in p.tracks.first { $0.id == id } } ?? p.tracks.first
        let file = track?.recordingFile ?? ((trackID == nil || trackID == p.tracks.first?.id) ? p.recordingFile : nil)
        return file.map { recordingDirectory.appendingPathComponent($0) }
    }
    func package(_ snapshot: MusicProject) throws -> URL {
        let p = unsavedProjects[snapshot.id] ?? snapshot
        try p.validate()
        var originals: [String: Data] = [:], total = 0
        let files = Set(p.tracks.flatMap { ($0.sourceHistory ?? []) + [$0.recordingFile].compactMap { $0 } } + [p.recordingFile].compactMap { $0 })
        for file in files {
            let data = try Data(contentsOf: recordingDirectory.appendingPathComponent(file)); total += data.count
            guard total <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
            originals[file] = data
        }
        let pack = ProjectPackage(project: p, recording: nil, recordings: originals)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(p.id.uuidString + ".starmusic")
        try encoder.encode(pack).write(to: url, options: .atomic); return url
    }
    func importPackage(_ data: Data) throws -> MusicProject {
        guard data.count <= 512 * 1024 * 1024 else { throw MusicError.tooLarge }
        var pack = (try? decoder.decode(ProjectPackage.self, from: data))
        if pack == nil { pack = try WebProjectImport.decode(data) }
        guard let pack, pack.format == "StarMusicNative", (1...2).contains(pack.version) else { throw MusicError.invalidProject }
        try pack.project.validate()
        var p = pack.project; p.id = UUID(); p.deleted = false; p.sample = false; p.updated = Date(); p.created = Date()
        p.tracks = p.tracks.map { var t = $0; t.id = UUID(); t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; return t }
        var originals = pack.recordings ?? [:]
        if let old = pack.recording { originals[pack.project.recordingFile ?? "original.wav"] = old }
        var replacements: [String: String] = [:], total = 0
        for (file, recording) in originals {
            guard MusicProject.validRecordingName(file) else { throw MusicError.invalidProject }
            total += recording.count; guard total <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
            let name = UUID().uuidString + "." + URL(fileURLWithPath: file).pathExtension
            try recording.write(to: recordingDirectory.appendingPathComponent(name), options: .atomic); replacements[file] = name
        }
        // New identifiers and copied source files make every imported project independent.
        let required = Set(p.tracks.flatMap { ($0.sourceHistory ?? []) + [$0.recordingFile].compactMap { $0 } } + [p.recordingFile].compactMap { $0 })
        guard required.isSubset(of: Set(replacements.keys)) else { throw MusicError.invalidProject }
        p.recordingFile = p.recordingFile.flatMap { replacements[$0] }
        for i in p.tracks.indices { p.tracks[i].recordingFile = p.tracks[i].recordingFile.flatMap { replacements[$0] }; p.tracks[i].sourceHistory = p.tracks[i].sourceHistory?.compactMap { replacements[$0] } }
        try save(p); return p
    }

}

@MainActor final class EditorSession: ObservableObject {
    @Published var project: MusicProject
    @Published var saveStatus = "已保存到本地"
    @Published var selectedNote: UUID?
    @Published var trackIndex = 0
    @Published private(set) var undoHistory: [MusicProject] = []
    @Published private(set) var redoHistory: [MusicProject] = []
    let store: ProjectStore
    init(_ project: MusicProject, store: ProjectStore) {
        self.project = store.unsavedProjects[project.id] ?? project; self.store = store
        if store.unsavedProjects[project.id] != nil { saveStatus = "保存失败 · 请重试或导出" }
    }
    func edit(_ operation: (inout MusicProject) -> Void) {
        undoHistory.append(project); if undoHistory.count > 256 { undoHistory.removeFirst() }; redoHistory = []
        operation(&project); project.updated = Date(); persist()
    }
    @discardableResult func persist() -> Bool {
        saveStatus = "保存中…"
        do { try store.save(project); saveStatus = "已保存到本地"; return true }
        catch { saveStatus = "保存失败 · 请重试或导出"; store.error = error.localizedDescription; return false }
    }
    func undo() { guard let p = undoHistory.popLast() else { return }; redoHistory.append(project); project = p; clampTrack(); persist() }
    func redo() { guard let p = redoHistory.popLast() else { return }; undoHistory.append(project); project = p; clampTrack(); persist() }
    private func clampTrack() { trackIndex = min(trackIndex, project.tracks.count - 1) }
    var track: MusicTrack { project.tracks[min(trackIndex, project.tracks.count - 1)] }
    var selected: MusicNote? { track.notes.first { $0.id == selectedNote } }
    func editNote(_ operation: (inout MusicNote) -> Void) {
        guard let i = track.notes.firstIndex(where: { $0.id == selectedNote }) else { return }
        let t = trackIndex; edit { operation(&$0.tracks[t].notes[i]) }
    }
    func deleteNote() {
        let id = selectedNote; let t = trackIndex; edit { $0.tracks[t].notes.removeAll { $0.id == id } }; selectedNote = nil
    }
    func addNote(midi: Int?, start: Double, duration: Double = 1) {
        let note = MusicNote(midi: midi, start: max(0, start), duration: duration); let t = trackIndex
        edit { $0.tracks[t].notes.append(note) }; selectedNote = note.id
    }
}
