import Foundation
import Files

let arguments = CommandLine.arguments

private func resolveSourceFiles() throws -> FileSystemSequence<File> {
    let sourcesFolder = FileSystem().currentFolder
    let sourceFiles = sourcesFolder.makeFileSequence(recursive: true)
    return sourceFiles
}

private extension Array {
    func element(at index: Int) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}

private func countLines(in file: File) throws -> Int {
    var lineCount: Int = 0
    for line in try file.readAsString().components(separatedBy: "\n") {
        if line.isEmpty == false {
            lineCount += 1
        }
    }
    return lineCount
}

private func conclude(with count: Int, for fileExtension: String? = nil) {
    let word = (count == 1) ? "line" : "lines"
    var feedback = ""
    if count == 0 {
        feedback.append("🤷‍♂️ zero \(word)")
    } else {
        feedback.append("👍 \(count) nonempty \(word)")
    }
    if let fileExtension = fileExtension {
        feedback.append(" ")
        feedback.append("found for files with file extension '.\(fileExtension)'")
    }
    print(feedback)
}

if let fileExtension = arguments.element(at: 1) {
    var lineCount: Int = 0
    for file in try resolveSourceFiles() {
        if file.extension != fileExtension {
            continue
        }
        lineCount += try countLines(in: file)
    }
    conclude(with: lineCount, for: fileExtension)
} else {
    var lineCount: Int = 0
    for file in try resolveSourceFiles() {
        lineCount += try countLines(in: file)
    }
    conclude(with: lineCount)
}
