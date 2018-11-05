import AppKit

extension CGSize {
  enum ResizingMode {
    case scaleToFill
    case scaleAspectFill
    case scaleAspectFit
  }

  func resized(
    within destination: CGSize,
    usingResizingMode resizingMode: ResizingMode = .scaleAspectFit
    ) -> CGRect {

    let source = self
    var newSize = destination

    let sourceAspectRatio = source.height / source.width
    let destinationAspectRatio = destination.height / destination.width

    let sourceIsWiderThanDestination = sourceAspectRatio < destinationAspectRatio

    switch resizingMode {
    case .scaleAspectFit:
      if sourceIsWiderThanDestination {
        newSize.height = destination.width * sourceAspectRatio
      } else {
        newSize.width = destination.height / sourceAspectRatio
      }
    case .scaleAspectFill:
      if sourceIsWiderThanDestination {
        newSize.width = destination.height / sourceAspectRatio
      } else {
        newSize.height = destination.width * sourceAspectRatio
      }
    case .scaleToFill:
      break
    }

    return CGRect(
      x: (destination.width - newSize.width) / 2.0,
      y: (destination.height - newSize.height) / 2.0,
      width: newSize.width,
      height: newSize.height)
  }
}
