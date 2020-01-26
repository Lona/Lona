import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  typealias Image = UIColor
#elseif os(macOS)
  import Cocoa
  typealias Image = NSColor
#endif
