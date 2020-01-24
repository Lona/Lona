import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  public typealias Image = UIImage
#elseif os(macOS)
  import Cocoa
  public typealias Image = NSImage
#endif
