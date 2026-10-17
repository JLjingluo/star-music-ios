import Foundation

struct AnalysisTicket {
    let id = UUID()
    let projectID: UUID
    let track: MusicTrack
    let trackRevision: Int
    let bpm: Double
    let freeRhythm: Bool
    init(project: MusicProject, track: MusicTrack, revision: Int = 0) {
        projectID = project.id; self.track = track; trackRevision = revision; bpm = project.bpm; freeRhythm = project.freeRhythm
    }
}
enum AnalysisDisposition: Equatable { case applied, candidate, discarded }
struct RecognitionCandidate: Identifiable {
    var id: UUID { ticket.id }
    let ticket: AnalysisTicket
    let result: RecognitionResult
    let engine: String
    let transcriptOnly: Bool
    func apply(to track: inout MusicTrack, bpm: Double) {
        if !transcriptOnly {
            track.notes = result.notes.map { source in
                var note = source
                // Analysis time is relative to the selected excerpt. rawStart is
                // absolute within the immutable source; the placement offset is separate.
                note.start = source.start * bpm / ticket.bpm + (ticket.track.sourceStartBeat ?? 0)
                note.duration = source.duration * bpm / ticket.bpm
                note.sourceFile = ticket.track.recordingFile; return note
            }
            track.useOriginalAudio = false; track.recognitionSource = engine
        }
        track.transcript = result.transcript
    }
}
