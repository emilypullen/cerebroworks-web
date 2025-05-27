import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct ExportedCSV: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var fileURL: URL?

    // MARK: - Initializers

    init(fileURL: URL?) {
        self.fileURL = fileURL
    }

    init(configuration: ReadConfiguration) throws {
        self.fileURL = nil
    }

    // MARK: - File Writing

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let url = fileURL else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        return FileWrapper(regularFileWithContents: data)
    }
}
