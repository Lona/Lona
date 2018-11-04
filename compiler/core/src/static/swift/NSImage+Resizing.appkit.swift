import AppKit

extension NSImage {
  func resized(
    within destination: CGSize,
    usingCroppingMode croppingMode: CGSize.ResizingMode = .scaleAspectFit
    ) -> NSImage {
    let scaledImage = NSImage(size: destination)

    guard destination.width > 0 && destination.height > 0 else { return scaledImage }

    scaledImage.lockFocus()

    draw(in: size.resized(within: destination, usingResizingMode: croppingMode))

    scaledImage.unlockFocus()

    return scaledImage
  }
}
