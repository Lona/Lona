import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public let small: Shadow = Shadow(
  x: 0,
  y: 2,
  blur: 2,
  radius: 0,
  color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
