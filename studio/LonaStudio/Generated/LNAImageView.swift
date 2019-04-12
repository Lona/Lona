import AppKit

// An image view that supports image resizing modes
public class LNAImageView: NSImageView {
  override public var intrinsicContentSize: CGSize {
    return CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
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

  public var cornerRadius: CGFloat = 0 {
      didSet {
          if oldValue != cornerRadius {
              needsDisplay = true
          }
      }
  }

  public override func draw(_ dirtyRect: NSRect) {
      let clipPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
      clipPath.setClip()

      super.draw(dirtyRect)
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
