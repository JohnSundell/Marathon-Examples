import Foundation
import Files

// MARK: - Extensions

extension File {
    enum Category: String {
        case images
        case documents
        case movies
        case code
        case sounds
        case other
    }

    var category: Category {
        guard let `extension` = `extension` else {
            return .other
        }

        switch `extension` {
        case "png", "jpg", "jpeg", "gif":
            return .images
        case "pdf", "doc", "rtf", "pages":
            return .documents
        case "mov", "avi", "mkv":
            return .movies
        case "swift", "h", "m":
            return .code
        case "mp3", "acc", "wav":
            return .sounds
        default:
            return .other
        }
    }
}

extension Folder {
    func subfolder(forFileCategory category: File.Category) throws -> Folder {
        return try createSubfolderIfNeeded(withName: category.rawValue.capitalized)
    }
}

// MARK: - Script

let currentFolder = FileSystem().currentFolder

for file in currentFolder.files {
    let targetFolder = try currentFolder.subfolder(forFileCategory: file.category)
    try file.move(to: targetFolder)
}

print("👍  All organized!")
