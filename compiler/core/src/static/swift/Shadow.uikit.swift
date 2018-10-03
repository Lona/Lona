import UIKit

public struct Shadow {
  let color: UIColor
  let offset: CGSize
  let blur: CGFloat

  public init(color: UIColor, offset: CGSize, blur: CGFloat) {
    self.color = color
    self.offset = offset
    self.blur = blur
  }

  func apply(to layer: CALayer) {
    layer.shadowColor = color.cgColor
    layer.shadowOffset = offset
    layer.shadowRadius = blur
    layer.shadowOpacity = 1
  }
}