import Foundation
import CoreGraphics

// Arguments: imagePath cropWidth cropHeigth outputName
let arguments = CommandLine.arguments

guard arguments.count >= 4 else {
      print("❌ Arguments: imagePath cropWidth cropHeight outputName")
      exit(1)
}
// width n height
guard let cropWidth = Int(arguments[2]),
      let cropHeight = Int(arguments[3]) else {
  print("❌ Arguments are not valid!")
  exit(1)
}


let imageURL = URL(fileURLWithPath: arguments[1])
guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
      var image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
  print("❌ Cannot find image at \(imageURL)!")
  exit(1)
        
}

guard let output = String(arguments[4]) else {
  print("❌ Missing the output name...")
  exit(1)
}

print("✨✨ TRUDRUQUE ✨✨")

// Create the rects for each image n save it!
var count = 0
let defaultImage = image

for lines in 0..<image.height/cropHeight{
  for columns in stride(from: cropWidth, to: image.width, by: cropWidth) {
    var imageRef = image.cropping(to: CGRect(x: columns, y: cropHeight * lines, width: cropWidth, height: cropHeight))
    
    let imageData = CFDataCreateMutable(nil, 0)
    let imageDestination = CGImageDestinationCreateWithData(imageData!, kUTTypePNG, 1, nil)!
    CGImageDestinationAddImage(imageDestination, imageRef!, nil)
    CGImageDestinationFinalize(imageDestination)
    
    let newURL = URL(string: "\(output)_\(count).png", relativeTo: imageURL)

    try (imageData! as Data).write(to: newURL!)
    
    count += 1
    image = defaultImage
  }
}

print("😬 All done! *I hope so...* 😬")




