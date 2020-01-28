import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  public typealias Color = UIColor
#elseif os(macOS)
  import Cocoa
  public typealias Color = NSColor
#endif
