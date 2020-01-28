import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  public typealias Font = UIFont
  public typealias FontDescriptor = UIFontDescriptor
#elseif os(macOS)
  import AppKit
  public typealias Font = NSFont
  public typealias FontDescriptor = NSFontDescriptor
#endif
