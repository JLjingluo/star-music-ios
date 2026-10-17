import Foundation
import AVFoundation

/// Version 3 is a single document with a small JSON header and streamed binary
/// attachments. Versions 1/2 JSON remain readable, but are no longer generated.
enum ProjectArchive {
    static let magic = Data("STARPK3\n".utf8)
    struct Attachment: Codable { var name: String; var bytes: Int }
    struct Header: Codable { var format = "StarMusicNative"; var version = 3; var project: MusicProject; var attachments: [Attachment] }
    static func write(_ project: MusicProject, recordings: URL, to output: URL) throws {
        let attachments = try project.audioFiles.sorted().map { name -> Attachment in
            let url = recordings.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else { throw MusicError.missingAudio(name) }
            return Attachment(name: name, bytes: try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0)
        }
        guard attachments.reduce(0, { $0 + $1.bytes }) <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
        let header = try JSONEncoder().encode(Header(project: project, attachments: attachments))
        guard header.count <= 16 * 1024 * 1024 else { throw MusicError.tooLarge }
        let staging = output.deletingLastPathComponent().appendingPathComponent(UUID().uuidString + ".partial")
        var complete = false; defer { if !complete { try? FileManager.default.removeItem(at: staging) } }
        FileManager.default.createFile(atPath: staging.path, contents: nil)
        let handle = try FileHandle(forWritingTo: staging); defer { try? handle.close() }
        try handle.write(contentsOf: magic)
        var length = UInt64(header.count).littleEndian
        try withUnsafeBytes(of: &length) { try handle.write(contentsOf: Data($0)) }; try handle.write(contentsOf: header)
        for item in attachments {
            let source = try FileHandle(forReadingFrom: recordings.appendingPathComponent(item.name)); defer { try? source.close() }
            try copy(source, to: handle, bytes: item.bytes)
        }
        try handle.synchronize(); try handle.close()
        if FileManager.default.fileExists(atPath: output.path) { try FileManager.default.removeItem(at: output) }
        try FileManager.default.moveItem(at: staging, to: output); complete = true
    }
    static func header(from url: URL) throws -> Header? {
        let input = try FileHandle(forReadingFrom: url); defer { try? input.close() }
        guard try input.read(upToCount: magic.count) == magic else { return nil }
        return try readHeader(input)
    }
    static func extract(_ url: URL, to directory: URL) throws -> Header {
        let input = try FileHandle(forReadingFrom: url); defer { try? input.close() }
        guard try input.read(upToCount: magic.count) == magic else { throw MusicError.invalidProject }
        let header = try readHeader(input)
        var remaining = (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) - Int(try input.offset())
        let total = header.attachments.reduce(0) { $0 + $1.bytes }
        guard remaining == total else { throw MusicError.invalidProject }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for attachment in header.attachments {
            let target = directory.appendingPathComponent(attachment.name)
            FileManager.default.createFile(atPath: target.path, contents: nil)
            let output = try FileHandle(forWritingTo: target); defer { try? output.close() }
            try copy(input, to: output, bytes: attachment.bytes); try output.synchronize(); try output.close()
            remaining -= attachment.bytes
            // A successful file copy is not proof that it is a decodable audio asset.
            let file = try AVAudioFile(forReading: target)
            guard file.length > 0, file.processingFormat.sampleRate.isFinite, file.processingFormat.sampleRate > 0 else { throw MusicError.invalidProject }
        }
        guard remaining == 0 else { throw MusicError.invalidProject }
        return header
    }
    private static func readHeader(_ input: FileHandle) throws -> Header {
        let bytes = try input.read(upToCount: 8) ?? Data()
        guard bytes.count == 8 else { throw MusicError.invalidProject }
        let count = bytes.enumerated().reduce(UInt64(0)) { $0 | UInt64($1.element) << UInt64($1.offset * 8) }
        guard count > 0, count <= 16 * 1024 * 1024, let data = try input.read(upToCount: Int(count)), data.count == Int(count) else { throw MusicError.invalidProject }
        let header = try JSONDecoder().decode(Header.self, from: data); guard header.version <= 3 else { throw MusicError.unsupportedVersion(header.version) }; try header.project.validate()
        guard header.format == "StarMusicNative", header.version == 3, header.attachments.count <= 20000,
              header.attachments.allSatisfy({ MusicProject.validRecordingName($0.name) && $0.bytes > 0 && $0.bytes <= 256 * 1024 * 1024 }),
              Set(header.attachments.map(\.name)).count == header.attachments.count,
              header.project.audioFiles == Set(header.attachments.map(\.name)),
              header.attachments.reduce(0, { $0 + $1.bytes }) <= 256 * 1024 * 1024 else { throw MusicError.invalidProject }
        return header
    }
    private static func copy(_ input: FileHandle, to output: FileHandle, bytes: Int) throws {
        var remaining = bytes
        while remaining > 0 {
            try Task.checkCancellation()
            guard let chunk = try input.read(upToCount: min(65536, remaining)), !chunk.isEmpty else { throw MusicError.invalidProject }
            try output.write(contentsOf: chunk); remaining -= chunk.count
        }
    }
}
