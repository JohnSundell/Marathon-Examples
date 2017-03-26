import Foundation
import Files
import Wrap
import Unbox

// MARK: - Constants

let MetadataFileName = "Contents.json"

// MARK: - System Extensions

extension CommandLine {
    static var catalogNameArgument: String? {
        guard arguments.count > 1 else {
            return nil
        }

        return arguments[1]
    }
}

extension File {
    var isImage: Bool {
        guard let `extension` = `extension` else {
            return false
        }

        switch `extension` {
        case "jpg", "jpeg", "png":
            return true
        default:
            return false
        }
    }

    var scaleSuffix: String? {
        let components = nameExcludingExtension.components(separatedBy: "@")

        guard components.count > 1 else {
            return nil
        }

        return components.last
    }

    var nameExcludingScaleSuffix: String {
        let name = nameExcludingExtension

        guard let suffix = scaleSuffix else {
            return name
        }

        let endIndex = name.index(name.endIndex, offsetBy: -suffix.characters.count - 1)
        return name.substring(to: endIndex)
    }
}

extension Folder {
    var imageSetMetadata: ImageSetMetadata? {
        guard let file = try? file(named: MetadataFileName) else {
            return nil
        }

        return try? unbox(data: file.read())
    }
}

// MARK: - Types

struct Info {
    let version = 1
    let author = "Script"
}

struct CatalogMetadata {
    let info = Info()
}

struct ImageSetMetadata {
    let info = Info()
    var images = [Image]()
}

extension ImageSetMetadata: Unboxable {
    init(unboxer: Unboxer) throws {
        images = try unboxer.unbox(key: "images")
    }
}

struct Image {
    let idiom = "universal"
    let filename: String
    let scale: String
}

extension Image: Unboxable {
    init(unboxer: Unboxer) throws {
        filename = try unboxer.unbox(key: "filename")
        scale = try unboxer.unbox(key: "scale")
    }
}

// MARK: - Script

let folder = FileSystem().currentFolder
var catalogName = CommandLine.catalogNameArgument ?? folder.name

if !catalogName.hasSuffix(".xcassets") {
    catalogName.append(".xcassets")
}

let catalog = try folder.createSubfolderIfNeeded(withName: catalogName)
try catalog.empty()
try catalog.createFile(named: MetadataFileName, contents: wrap(CatalogMetadata()))

for file in folder.files {
    guard file.isImage else {
        continue
    }

    let imageSetName = file.nameExcludingScaleSuffix + ".imageset"
    let imageSet = try catalog.createSubfolderIfNeeded(withName: imageSetName)
    try imageSet.createFile(named: file.name, contents: file.read())

    var metadata = imageSet.imageSetMetadata ?? ImageSetMetadata()
    let image = Image(filename: file.name, scale: file.scaleSuffix ?? "1x")
    metadata.images.append(image)
    try imageSet.createFile(named: MetadataFileName, contents: wrap(metadata))
}
