import Foundation
import CoreGraphics

// MARK: - Extensions

private extension CGContext {
    static func make(width: Int, height: Int) -> CGContext {
        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )!
    }
}

// MARK: - Parsing arguments

let arguments = ProcessInfo.processInfo.arguments

guard arguments.count > 3 else {
    print("👮  Expected 3 arguments: image path, target width & target height")
    exit(1)
}

let imagePath = arguments[1]

guard let targetWidth = Int(arguments[2]) else {
    print("👮  '\(arguments[2])' is not a valid width")
    exit(1)
}

guard let targetHeight = Int(arguments[3]) else {
    print("👮  '\(arguments[2])' is not a valid height")
    exit(1)
}

// MARK: - Performing image resize

let imageURL = URL(fileURLWithPath: imagePath)

guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    print("💥  Cannot find image at '\(imagePath)'")
    exit(1)
}

let context = CGContext.make(width: targetWidth, height: targetHeight)
context.draw(image, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

guard let resizedImage = context.makeImage() else {
    print("💥  Failed to resize image")
    exit(1)
}

// MARK: - Writing out resized image

let imageData = CFDataCreateMutable(nil, 0)!
let imageDestination = CGImageDestinationCreateWithData(imageData, kUTTypePNG, 1, nil)!
CGImageDestinationAddImage(imageDestination, resizedImage, nil)
CGImageDestinationFinalize(imageDestination)

try (imageData as Data).write(to: imageURL)
