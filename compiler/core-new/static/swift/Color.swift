import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  public typealias Image = UIColor
#elseif os(macOS)
  import Cocoa
  public typealias Image = NSColor
#endif
