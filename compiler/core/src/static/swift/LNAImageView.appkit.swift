import AppKit

// An image view that supports image resizing modes
public class LNAImageView: NSImageView {
  override public var intrinsicContentSize: CGSize {
    return .zero
  }

  private var originalImage: NSImage?

  override public var image: NSImage? {
    didSet {
      originalImage = image
    }
  }

  var resizingMode = CGSize.ResizingMode.scaleAspectFill {
    didSet {
      if resizingMode != oldValue {
        setNeedsDisplay()
      }
    }
  }

  override public func viewWillDraw() {
    if let image = image,
      let originalImage = originalImage,
      image.size != originalImage.size.resized(within: bounds.size, usingResizingMode: resizingMode).size {

      super.image = originalImage.resized(within: bounds.size, usingCroppingMode: resizingMode)
    }

    super.viewWillDraw()
  }
}
