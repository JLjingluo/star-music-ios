import Foundation
import Combine
import AVFoundation

@MainActor final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [MusicProject] = []
    @Published var error: String?
    private(set) var unsavedProjects: [UUID: MusicProject] = [:]
    @Published private(set) var recoveryMessage: String?
    private(set) var durableRecovery: Set<UUID> = []
    let root: URL
    var recordingDirectory: URL { root.appendingPathComponent("Recordings", isDirectory: true) }
    var projectDirectory: URL { root.appendingPathComponent("Projects", isDirectory: true) }
    var recoveryDirectory: URL { root.appendingPathComponent("Recovery", isDirectory: true) }
    var previousDirectory: URL { root.appendingPathComponent("Previous", isDirectory: true) }
    private let encoder: JSONEncoder = { let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys]; return e }()
    private let decoder = JSONDecoder()
    init(root: URL? = nil) {
        self.root = root ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("StarMusic", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: recordingDirectory, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: recoveryDirectory, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: previousDirectory, withIntermediateDirectories: true)
            do { try FileManager.default.createDirectory(at: projectDirectory, withIntermediateDirectories: true) } catch { self.error = "草稿目录暂时不可写，正在检查恢复快照。" }
            try load()
            let marker = self.root.appendingPathComponent("initialized")
            if !FileManager.default.fileExists(atPath: marker.path) {
                for i in 0..<3 { try save(.example(i)) }
                try Data("1".utf8).write(to: marker, options: .atomic)
            }
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-test-dense-score") {
                var fixture = MusicProject(); fixture.id = UUID(uuidString: "00000000-0000-4000-8000-000000000070")!; fixture.name = "密集谱面回归"; fixture.bpm = 96
                var notes: [MusicNote] = []
                let durations: [Double] = [0.0625, 0.125, 0.25, 0.5]
                for i in 0..<40 {
                    let pitch: Int? = i % 9 == 0 ? nil : 52 + i % 13
                    let confidence: Double = i % 4 == 0 ? 0.6 : 1
                    notes.append(MusicNote(midi: pitch, start: Double(i) * 0.075, duration: durations[i % 4], confidence: confidence))
                }
                fixture.tracks[0].notes = notes
                try save(fixture)
            }
            #endif
        } catch { self.error = error.localizedDescription }
    }
    func load() throws {
        var valid: [MusicProject] = []; var rejected = 0
        for url in (try? FileManager.default.contentsOfDirectory(at: projectDirectory, includingPropertiesForKeys: nil)) ?? [] where url.pathExtension == "json" {
            do { var p = try decoder.decode(MusicProject.self, from: Data(contentsOf: url)).migratingLegacyRecording(); restoreRecordingDuration(&p); try p.validate(); valid.append(p) }
            catch { rejected += 1 }
        }
        // Recovery files are written before the primary commit. A higher revision is an
        // explicitly uncommitted edit, never silently replaced by the older primary.
        for directory in [previousDirectory, recoveryDirectory] {
            for url in (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? [] where url.pathExtension == "json" {
                guard var recovered = try? decoder.decode(MusicProject.self, from: Data(contentsOf: url)), (try? recovered.validate()) != nil else { continue }
                recovered = recovered.migratingLegacyRecording(); restoreRecordingDuration(&recovered)
                let existing = valid.firstIndex { $0.id == recovered.id }
                if existing == nil || (recovered.revision ?? 0) > (valid[existing!].revision ?? 0) {
                    if let existing { valid[existing] = recovered } else { valid.append(recovered) }
                    unsavedProjects[recovered.id] = recovered; durableRecovery.insert(recovered.id)
                }
            }
        }
        projects = valid.sorted { $0.updated > $1.updated }
        if !durableRecovery.isEmpty { recoveryMessage = "已找回 \(durableRecovery.count) 个未完成保存的草稿。打开后可继续编辑并重试保存。" }
        let missing = valid.filter { (try? verifyAudio($0)) == nil }
        if !missing.isEmpty { error = "\(missing.count) 个草稿的原声附件缺失或不完整。工程与原文件仍保留；请从完整备份恢复录音。" }
        if rejected > 0 { error = "有 \(rejected) 个草稿暂时无法读取；原文件仍保留在应用文件夹中。" }
    }
    @discardableResult func save(_ snapshot: MusicProject, expectedRevision: Int? = nil, openRecording: String? = nil) throws -> MusicProject {
        var project = snapshot.migratingLegacyRecording(); restoreRecordingDuration(&project)
        try project.validate()
        let current = projects.first { $0.id == project.id }
        if let expectedRevision, expectedRevision != (current?.revision ?? 0) { throw MusicError.staleRevision }
        var dependencyFailure: Error?
        do { try verifyAudio(project, openRecording: openRecording) } catch { dependencyFailure = error }
        project.revision = max(current?.revision ?? 0, unsavedProjects[project.id]?.revision ?? 0) + 1
        let data = try encoder.encode(project)
        let name = project.id.uuidString + ".json", primary = projectDirectory.appendingPathComponent(name)
        do { try data.write(to: recoveryDirectory.appendingPathComponent(name), options: .atomic); durableRecovery.insert(project.id) }
        catch { durableRecovery.remove(project.id) } // A full disk may also prevent the recovery write.
        do {
            if let dependencyFailure { throw dependencyFailure }
            if let old = try? Data(contentsOf: primary), (try? decoder.decode(MusicProject.self, from: old).validate()) != nil { try? old.write(to: previousDirectory.appendingPathComponent(name), options: .atomic) }
            try data.write(to: primary, options: .atomic)
        } catch {
            unsavedProjects[project.id] = project
            recoveryMessage = durableRecovery.contains(project.id) ? "有未完成保存的编辑，已保留恢复快照。请打开后重试或导出。" : "有修改仅保留在本次运行的内存中，请立即导出最新项目包。"
            throw error
        }
        unsavedProjects.removeValue(forKey: project.id)
        durableRecovery.remove(project.id)
        if unsavedProjects.isEmpty { recoveryMessage = nil }
        if let i = projects.firstIndex(where: { $0.id == project.id }) { projects[i] = project } else { projects.append(project) }
        projects.sort { $0.updated > $1.updated }
        return project
    }
    func verifyAudio(_ project: MusicProject, openRecording: String? = nil) throws {
        var total: Int64 = 0
        for file in project.audioFiles {
            let url = recordingDirectory.appendingPathComponent(file)
            guard FileManager.default.fileExists(atPath: url.path) else { throw MusicError.missingAudio(file) }
            if file != openRecording {
                guard let audio = try? AVAudioFile(forReading: url), audio.length > 0 else { throw MusicError.operation("原声附件不完整：\(file)。请保留原文件并从备份恢复") }
            }
            total += Int64((try url.resourceValues(forKeys: [.fileSizeKey])).fileSize ?? 0)
            guard total <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
        }
    }
    func update(_ project: MusicProject, _ change: (inout MusicProject) -> Void) {
        var p = unsavedProjects[project.id] ?? projects.first(where: { $0.id == project.id }) ?? project; change(&p); p.updated = Date()
        do { try save(p) } catch { self.error = error.localizedDescription }
    }
    func duplicate(_ snapshot: MusicProject) throws {
        let p = (unsavedProjects[snapshot.id] ?? snapshot).migratingLegacyRecording()
        try p.validate()
        var copy = p; copy.id = UUID(); copy.name = MusicProject.projectName(p.name, suffix: " · 副本"); copy.sample = false; copy.updated = Date(); copy.created = Date()
        copy.tracks = copy.tracks.map { track in
            var t = track; t.id = UUID(); t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; return t
        }
        var replacements: [String: String] = [:], created: [URL] = []
        var complete = false
        defer { if !complete { for url in created { try? FileManager.default.removeItem(at: url) }; discardFailedProject(copy.id) } }
        try verifyAudio(p)
        let files = p.audioFiles
        for file in files {
            let newName = UUID().uuidString + "." + URL(fileURLWithPath: file).pathExtension
            let target = recordingDirectory.appendingPathComponent(newName); created.append(target)
            try FileManager.default.copyItem(at: recordingDirectory.appendingPathComponent(file), to: target)
            replacements[file] = newName
        }
        copy.recordingFile = p.recordingFile.flatMap { replacements[$0] }
        for index in copy.tracks.indices { copy.tracks[index].recordingFile = p.tracks[index].recordingFile.flatMap { replacements[$0] }; copy.tracks[index].sourceHistory = p.tracks[index].sourceHistory?.compactMap { replacements[$0] }; for n in copy.tracks[index].notes.indices { copy.tracks[index].notes[n].sourceFile = p.tracks[index].notes[n].sourceFile.flatMap { replacements[$0] } } }

        try save(copy); complete = true
    }
    func recordingURL(_ p: MusicProject, trackID: UUID? = nil) -> URL? {
        if let id = trackID, !p.tracks.contains(where: { $0.id == id }) { return nil }
        let canonical = p.migratingLegacyRecording()
        let owner = trackID.flatMap { id in canonical.tracks.first { $0.id == id } } ?? canonical.tracks.first
        let file = owner?.recordingFile
        return file.map { recordingDirectory.appendingPathComponent($0) }
    }
    func noteRecordingURL(_ project: MusicProject, trackID: UUID, note: MusicNote) -> URL? {
        if let file = note.sourceFile { return recordingDirectory.appendingPathComponent(file) }
        return recordingURL(project, trackID: trackID)
    }
    private func restoreRecordingDuration(_ project: inout MusicProject) {
        for i in project.tracks.indices where project.tracks[i].recordingSeconds == nil {
            if let name = project.tracks[i].recordingFile, MusicProject.validRecordingName(name), let file = try? AVAudioFile(forReading: recordingDirectory.appendingPathComponent(name)), file.processingFormat.sampleRate > 0 {
                project.tracks[i].recordingSeconds = Double(file.length) / file.processingFormat.sampleRate
            }
        }
        project.syncLegacyRecording()
    }
    func package(_ snapshot: MusicProject, preferRecovery: Bool = true) throws -> URL {
        let p = preferRecovery ? unsavedProjects[snapshot.id] ?? snapshot : snapshot
        try p.validate(); try verifyAudio(p)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".starmusic")
        try ProjectArchive.write(p, recordings: recordingDirectory, to: url); return url
    }
    func packageAsync(_ snapshot: MusicProject, preferRecovery: Bool = true) async throws -> URL {
        let p = preferRecovery ? unsavedProjects[snapshot.id] ?? snapshot : snapshot
        try p.validate(); try verifyAudio(p)
        let directory = recordingDirectory
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".starmusic")
        let worker = Task.detached(priority: .userInitiated) { try ProjectArchive.write(p, recordings: directory, to: url); return url }
        return try await withTaskCancellationHandler(operation: { try await worker.value }, onCancel: { worker.cancel() })
    }
    func discardFailedProject(_ id: UUID) {
        unsavedProjects.removeValue(forKey: id); durableRecovery.remove(id)
        for folder in [recoveryDirectory, previousDirectory] { try? FileManager.default.removeItem(at: folder.appendingPathComponent(id.uuidString + ".json")) }
    }
    func importPackage(_ url: URL) throws -> MusicProject {
        guard (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) <= 512 * 1024 * 1024 else { throw MusicError.tooLarge }
        guard try ProjectArchive.header(from: url) != nil else { return try importPackage(Data(contentsOf: url)) }
        let staging = root.appendingPathComponent("ImportStaging/" + UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: staging) }
        let header = try ProjectArchive.extract(url, to: staging)
        var p = header.project.migratingLegacyRecording(); p.id = UUID(); p.revision = nil; p.deleted = false; p.sample = false; p.updated = Date(); p.created = Date()
        p.tracks = p.tracks.map { var t = $0; t.id = UUID(); t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; return t }
        var replacements: [String: String] = [:], created: [URL] = []; var complete = false
        defer { if !complete { for file in created { try? FileManager.default.removeItem(at: file) }; discardFailedProject(p.id) } }
        for item in header.attachments {
            let name = UUID().uuidString + "." + URL(fileURLWithPath: item.name).pathExtension
            let target = recordingDirectory.appendingPathComponent(name)
            try FileManager.default.moveItem(at: staging.appendingPathComponent(item.name), to: target); created.append(target); replacements[item.name] = name
        }
        p.recordingFile = p.recordingFile.flatMap { replacements[$0] }
        for i in p.tracks.indices {
            p.tracks[i].recordingFile = p.tracks[i].recordingFile.flatMap { replacements[$0] }
            p.tracks[i].sourceHistory = p.tracks[i].sourceHistory?.compactMap { replacements[$0] }
            for n in p.tracks[i].notes.indices { p.tracks[i].notes[n].sourceFile = p.tracks[i].notes[n].sourceFile.flatMap { replacements[$0] } }
        }
        p = try save(p); complete = true; return p
    }
    func importPackage(_ data: Data) throws -> MusicProject {
        guard data.count <= 512 * 1024 * 1024 else { throw MusicError.tooLarge }
        if data.starts(with: ProjectArchive.magic) {
            let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".starmusic")
            defer { try? FileManager.default.removeItem(at: file) }
            try data.write(to: file, options: .atomic); return try importPackage(file)
        }
        var pack = (try? decoder.decode(ProjectPackage.self, from: data))
        if pack == nil { pack = try WebProjectImport.decode(data) }
        if let version = pack?.version, version > 2 { throw MusicError.unsupportedVersion(version) }
        guard let pack, pack.format == "StarMusicNative", (1...2).contains(pack.version) else { throw MusicError.invalidProject }
        try pack.project.validate()
        var p = pack.project.migratingLegacyRecording(); p.id = UUID(); p.deleted = false; p.sample = false; p.updated = Date(); p.created = Date()
        p.tracks = p.tracks.map { var t = $0; t.id = UUID(); t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; return t }
        var originals = pack.recordings ?? [:]
        if let old = pack.recording { originals[pack.project.recordingFile ?? "original.wav"] = old }
        // Validate all names, required assets and byte budgets before writing any file.
        let required = Set(p.tracks.flatMap { ($0.sourceHistory ?? []) + [$0.recordingFile].compactMap { $0 } + $0.notes.compactMap(\.sourceFile) } + [p.recordingFile].compactMap { $0 })
        guard required.isSubset(of: Set(originals.keys)) else { throw MusicError.invalidProject }
        var total = 0
        for (file, recording) in originals { guard MusicProject.validRecordingName(file) else { throw MusicError.invalidProject }; total += recording.count; guard total <= 256 * 1024 * 1024 else { throw MusicError.tooLarge } }
        var replacements: [String: String] = [:], created: [URL] = []
        var complete = false
        defer { if !complete { for url in created { try? FileManager.default.removeItem(at: url) }; discardFailedProject(p.id) } }
        for (file, recording) in originals {
            let name = UUID().uuidString + "." + URL(fileURLWithPath: file).pathExtension
            let target = recordingDirectory.appendingPathComponent(name); created.append(target)
            try recording.write(to: target, options: .atomic); replacements[file] = name
        }
        p.recordingFile = p.recordingFile.flatMap { replacements[$0] }
        for i in p.tracks.indices { p.tracks[i].recordingFile = p.tracks[i].recordingFile.flatMap { replacements[$0] }; p.tracks[i].sourceHistory = p.tracks[i].sourceHistory?.compactMap { replacements[$0] }; for n in p.tracks[i].notes.indices { p.tracks[i].notes[n].sourceFile = p.tracks[i].notes[n].sourceFile.flatMap { replacements[$0] } } }
        p = try save(p); complete = true; return p
    }

}

@MainActor final class EditorSession: ObservableObject {
    @Published var project: MusicProject
    @Published var saveStatus = "已保存到本地"
    @Published var selectedNote: UUID?
    @Published var trackIndex = 0
    @Published private(set) var undoHistory: [MusicProject] = []
    @Published private(set) var redoHistory: [MusicProject] = []
    @Published var recognitionCandidates: [RecognitionCandidate] = []
    private var analysisTickets: [UUID: UUID] = [:]
    private var trackRevisions: [UUID: Int] = [:]
    private var committedRevision: Int
    let store: ProjectStore
    init(_ project: MusicProject, store: ProjectStore) {
        self.project = (store.unsavedProjects[project.id] ?? store.projects.first(where: { $0.id == project.id }) ?? project).migratingLegacyRecording(); self.store = store
        committedRevision = store.projects.first(where: { $0.id == project.id })?.revision ?? 0
        if store.unsavedProjects[project.id] != nil { saveStatus = "保存失败 · 请重试或导出" }
    }
    @discardableResult func edit(_ operation: (inout MusicProject) -> Void) -> Bool {
        var candidate = project; operation(&candidate); candidate.updated = Date(); candidate.syncLegacyRecording()
        // All edit entry points share the same validation before mutating history or data.
        do { try candidate.validate() } catch { store.error = error.localizedDescription; return false }
        for i in candidate.tracks.indices {
            if let old = project.tracks.first(where: { $0.id == candidate.tracks[i].id }), old.sourceStartBeat == candidate.tracks[i].sourceStartBeat, !MusicEdits.sameTimedMusic(old.notes, candidate.tracks[i].notes, oldBPM: project.bpm, newBPM: candidate.bpm) { candidate.tracks[i].useOriginalAudio = false }
        }
        updateTrackRevisions(from: project, to: candidate)
        undoHistory.append(project); if undoHistory.count > 256 { undoHistory.removeFirst() }; redoHistory = []
        project = candidate; persist(); return true
    }
    @discardableResult func persist() -> Bool {
        saveStatus = "保存中…"
        do { project = try store.save(project, expectedRevision: committedRevision); committedRevision = project.revision ?? 0; saveStatus = "已保存到本地"; return true }
        catch { saveStatus = store.durableRecovery.contains(project.id) ? "保存失败 · 已保留恢复快照" : "保存失败 · 最新改动仅在内存"; store.error = error.localizedDescription; return false }
    }
    func undo() { guard let p = undoHistory.popLast() else { return }; redoHistory.append(project); updateTrackRevisions(from: project, to: p); project = p; clampTrack(); persist() }
    func redo() { guard let p = redoHistory.popLast() else { return }; undoHistory.append(project); updateTrackRevisions(from: project, to: p); project = p; clampTrack(); persist() }
    private func updateTrackRevisions(from old: MusicProject, to new: MusicProject) {
        for track in new.tracks where old.tracks.first(where: { $0.id == track.id }) != track { trackRevisions[track.id, default: 0] += 1 }
    }
    func acceptRecording(_ recorded: MusicProject) {
        guard recorded.id == project.id, let latest = store.projects.first(where: { $0.id == project.id }), latest.revision == recorded.revision else { store.error = MusicError.staleRevision.localizedDescription; return }
        // The modal owns this project while open; bring its committed revision into
        // this editor as one undoable operation, never re-save an older parent copy.
        undoHistory.append(project); redoHistory = []; updateTrackRevisions(from: project, to: recorded); project = store.unsavedProjects[recorded.id] ?? recorded; committedRevision = latest.revision ?? 0
        clampTrack(); saveStatus = store.unsavedProjects[recorded.id] == nil ? "已保存到本地" : "保存失败 · 请重试或导出"
    }
    func beginAnalysis(trackID: UUID) throws -> AnalysisTicket {
        guard let track = project.tracks.first(where: { $0.id == trackID }), track.recordingFile != nil else { throw MusicError.invalidProject }
        let ticket = AnalysisTicket(project: project, track: track, revision: trackRevisions[trackID, default: 0]); analysisTickets[trackID] = ticket.id; return ticket
    }
    func cancelAnalysis(_ ticket: AnalysisTicket) { if analysisTickets[ticket.track.id] == ticket.id { analysisTickets.removeValue(forKey: ticket.track.id) } }
    func cancelAllAnalysis() { analysisTickets = [:] }
    @discardableResult func finishAnalysis(_ ticket: AnalysisTicket, result: RecognitionResult, engine: String, transcriptOnly: Bool = false) -> AnalysisDisposition {
        guard ticket.projectID == project.id, analysisTickets[ticket.track.id] == ticket.id else { return .discarded }
        analysisTickets.removeValue(forKey: ticket.track.id)
        guard let index = project.tracks.firstIndex(where: { $0.id == ticket.track.id }) else { return .discarded }
        let candidate = RecognitionCandidate(ticket: ticket, result: result, engine: engine, transcriptOnly: transcriptOnly)
        if trackRevisions[ticket.track.id, default: 0] != ticket.trackRevision || project.tracks[index] != ticket.track || project.bpm != ticket.bpm || project.freeRhythm != ticket.freeRhythm {
            recognitionCandidates.append(candidate); return .candidate
        }
        let bpm = project.bpm
        return edit { candidate.apply(to: &$0.tracks[index], bpm: bpm) } ? .applied : .discarded
    }
    func keepCandidateAsTrack(_ candidate: RecognitionCandidate) {
        var track = candidate.ticket.track; track.id = UUID(); track.name = MusicProject.projectName(track.name, suffix: " · 识谱候选")
        candidate.apply(to: &track, bpm: project.bpm)
        if edit({ $0.tracks.append(track) }) { trackIndex = project.tracks.count - 1; recognitionCandidates.removeAll { $0.id == candidate.id } }
    }
    private func clampTrack() { trackIndex = min(trackIndex, project.tracks.count - 1) }
    var track: MusicTrack { project.tracks[min(trackIndex, project.tracks.count - 1)] }
    var selected: MusicNote? { track.notes.first { $0.id == selectedNote } }
    func editNote(_ operation: (inout MusicNote) -> Void) {
        guard let i = track.notes.firstIndex(where: { $0.id == selectedNote }) else { return }
        let t = trackIndex; edit { operation(&$0.tracks[t].notes[i]); $0.tracks[t].useOriginalAudio = false }
    }
    func deleteNote() {
        let id = selectedNote; let t = trackIndex; edit { $0.tracks[t].notes.removeAll { $0.id == id } }; selectedNote = nil
    }
    func addNote(midi: Int?, start: Double, duration: Double = 1) {
        let note = MusicNote(midi: midi, start: max(0, start), duration: duration); let t = trackIndex
        edit { $0.tracks[t].notes.append(note) }; selectedNote = note.id
    }
}
