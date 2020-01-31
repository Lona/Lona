import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public let primary: Color = Color(named: "primary")!
public let accent: Color = primary
public let testSaturate: Color = Color(named: "testSaturate")!
