import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  typealias Image = UIImage
#elseif os(macOS)
  import Cocoa
  typealias Image = NSImage
#endif
