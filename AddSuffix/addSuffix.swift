import Foundation
import Files

let arguments = CommandLine.arguments

guard arguments.count > 1 else {
    print("👮  No suffix given")
    exit(1)
}

let suffix = arguments[1]

for file in FileSystem().currentFolder.files {
    let previousName = file.name
    try file.rename(to: file.nameExcludingExtension + suffix)
    print("👉  Renamed \(previousName) to \(file.name)")
}

print("✅  All done!")
