import AppKit

class TextStyles {
  public static let title = TextStyle(weight: NSFont.Weight.semibold, size: 32, color: Colors.black)
  public static let versionInfo = TextStyle(size: 20, color: #colorLiteral(red: 0.509803921569, green: 0.509803921569, blue: 0.509803921569, alpha: 1))
  public static let largeSemibold = TextStyle(weight: NSFont.Weight.medium, size: 15, color: Colors.black)
  public static let large = TextStyle(size: 15, color: Colors.textColor)
  public static let regular = TextStyle(size: 13, color: Colors.textColor)
  public static let small = TextStyle(size: 11, color: Colors.textColor)
  public static let regularMuted = TextStyle(size: 13, color: #colorLiteral(red: 0.509803921569, green: 0.509803921569, blue: 0.509803921569, alpha: 1))
  public static let smallMuted = TextStyle(size: 11, color: #colorLiteral(red: 0.509803921569, green: 0.509803921569, blue: 0.509803921569, alpha: 1))
  public static let regularDisabled = TextStyle(size: 13, color: #colorLiteral(red: 0.666666666667, green: 0.666666666667, blue: 0.666666666667, alpha: 1))
  public static let smallDisabled = TextStyle(size: 11, color: #colorLiteral(red: 0.666666666667, green: 0.666666666667, blue: 0.666666666667, alpha: 1))
  public static let largeInverse = TextStyle(size: 15, color: Colors.white)
  public static let regularInverse = TextStyle(size: 13, color: Colors.white)
  public static let smallInverse = TextStyle(size: 11, color: Colors.white)
  public static let monospacedMicro = TextStyle(family: "Menlo", weight: NSFont.Weight.bold, size: 10, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85))
  public static let monospacedMicroInverse = TextStyle(family: "Menlo", weight: NSFont.Weight.bold, size: 10, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.85))
  public static let sectionTitle = TextStyle(weight: NSFont.Weight.medium, size: 12, color: Colors.labelText)
  public static let sectionTitleInverse = TextStyle(weight: NSFont.Weight.semibold, size: 12, color: Colors.white)
}
