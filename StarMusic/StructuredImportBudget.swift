import Foundation
import os

enum StructuredImportBudget {
    /// Legacy JSON and MIDI parsers hold more than the file's on-disk bytes.
    /// A conservative preflight is separate from the format's absolute size cap.
    static func validate(fileBytes: Int, availableBytes: UInt64) throws {
        let reserve: UInt64 = 128 * 1024 * 1024
        guard fileBytes >= 0, availableBytes > reserve, UInt64(fileBytes) <= (availableBytes - reserve) / 5 else { throw MusicError.importMemory }
    }
    static func validate(_ url: URL) throws {
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        try validate(fileBytes: size, availableBytes: UInt64(os_proc_available_memory()))
    }
}
