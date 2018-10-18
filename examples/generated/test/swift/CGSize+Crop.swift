import UIKit

extension CGSize {
  func crop(within destination: CGSize) -> CGRect {
    let source = self
    var newSize = destination

    let sourceAspectRatio = source.height / source.width
    let destinationAspectRatio = destination.height / destination.width

    if sourceAspectRatio < destinationAspectRatio {
      // Source is wider than destination
      newSize.height = destination.width * sourceAspectRatio
    } else {
      // Source is taller than destination
      newSize.width = destination.height / sourceAspectRatio
    }

    return CGRect(
      x: (destination.width - newSize.width) / 2.0,
      y: (destination.height - newSize.height) / 2.0,
      width: newSize.width,
      height: newSize.height)
  }
}