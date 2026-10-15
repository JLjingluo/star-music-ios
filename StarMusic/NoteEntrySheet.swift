import SwiftUI

struct NoteEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var audio: AudioController
    @EnvironmentObject private var store: ProjectStore
    var bpm: Double
    var professional: Bool
    var onAdd: (Int, Double, Double) -> Void
    @State private var pitch = 64
    @State private var start: Double
    @State private var duration = 0.5
    init(bpm: Double, startBeat: Double, professional: Bool, onAdd: @escaping (Int, Double, Double) -> Void) {
        self.bpm = bpm; self.professional = professional; self.onAdd = onAdd; _start = State(initialValue: startBeat * 60 / bpm)
    }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(professional ? MusicNote(midi: pitch, start: 0, duration: 1).pitchName : "声音高低：\(pitch + 1)", value: $pitch, in: 0...127).accessibilityIdentifier("noteEntry.pitch")
                    Button("听听这个声音") { Task { do { try await audio.preview(.piano, midi: pitch) } catch { store.error = error.localizedDescription } } }
                } header: { Text("声音") } footer: { Text("数字越大，声音越高。可以先试听，再添加。") }
                Section("位置与长度") {
                    Stepper("从 \(start, specifier: "%.1f") 秒开始", value: $start, in: 0...600, step: 0.1)
                    Stepper("持续 \(duration, specifier: "%.1f") 秒", value: $duration, in: 0.1...20, step: 0.1)
                }
            }.navigationTitle("添加一个声音").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("添加") { audio.stopPlayback(); onAdd(pitch, start * bpm / 60, duration * bpm / 60); dismiss() }.accessibilityIdentifier("noteEntry.add") }
                }
        }.onDisappear { audio.stopPlayback() }
    }
}
