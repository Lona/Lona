import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public let primary: Color = #colorLiteral(red: 0.27058823529411763, green: 0.796078431372549, blue: 1, alpha: 1)
public let accent: Color = primary
