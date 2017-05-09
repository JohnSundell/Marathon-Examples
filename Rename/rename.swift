import Foundation
import Files

let target = CommandLine.arguments[1]
let replacement = CommandLine.arguments[2]

for file in Folder.current.makeFileSequence(recursive: true) {
    guard let fileExtension = file.extension else {
        continue
    }

    switch fileExtension {
    case "swift", "pbxproj":
        var code = try file.readAsString()
        code = code.replacingOccurrences(of: target, with: replacement)
        try file.write(string: code)

        var fileName = file.nameExcludingExtension
        fileName = fileName.replacingOccurrences(of: target, with: replacement)
        try file.rename(to: fileName)
    default:
        break
    }
}
