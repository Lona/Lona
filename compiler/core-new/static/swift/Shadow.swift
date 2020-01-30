import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public struct Shadow {
  let color: Color
  let offset: CGSize
  let blur: CGFloat

  // radius is not supported on swift
  public init(x: CGFloat, y: CGFloat, blur: CGFloat, radius: CGFloat, color: Color) {
    self.color = color
    self.offset = CGSize(width: x, height: y)
    self.blur = blur
  }

  func apply(to layer: CALayer) {
    layer.shadowColor = color.cgColor
    layer.shadowOffset = offset
    layer.shadowRadius = blur
    layer.shadowOpacity = 1
  }
}
