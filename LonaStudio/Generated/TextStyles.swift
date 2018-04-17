import AppKit

class TextStyles {
  public static let title = AttributedFont(
    weight: NSFont.Weight.semibold,
    size: 32,
    lineHeight: 38,
    color: Colors.black)
  public static let versionInfo = AttributedFont(size: 20, lineHeight: 24, color: #colorLiteral(red: 0.509803921569, green: 0.509803921569, blue: 0.509803921569, alpha: 1))
  public static let largeSemibold = AttributedFont(
    weight: NSFont.Weight.medium,
    size: 15,
    lineHeight: 17,
    color: Colors.black)
  public static let large = AttributedFont(size: 15, lineHeight: 17, color: Colors.black)
  public static let regular = AttributedFont(size: 13, lineHeight: 15, color: Colors.black)
  public static let regularMuted = AttributedFont(size: 13, lineHeight: 15, color: #colorLiteral(red: 0.509803921569, green: 0.509803921569, blue: 0.509803921569, alpha: 1))
}
