import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public let heading1: TextStyle = TextStyle(
  fontFamily: "Helvetica",
  fontSize: 28,
  fontWeight: Font.Weight.bold,
  color: #colorLiteral(red: 0, green: 0.5019607843137255, blue: 0.5019607843137255, alpha: 1))
