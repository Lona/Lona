import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

struct FontWeight {
  static let w100 = Font.Weight.ultraLight
  static let w200 = Font.Weight.thin
  static let w300 = Font.Weight.regular
  static let w400 = Font.Weight.ultraLight
  static let w500 = Font.Weight.medium
  static let w600 = Font.Weight.semibold
  static let w700 = Font.Weight.bold
  static let w800 = Font.Weight.heavy
  static let w900 = Font.Weight.black
}
