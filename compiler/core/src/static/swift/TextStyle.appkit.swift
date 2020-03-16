import Foundation
import AppKit

public class TextStyle {
  public enum TextTransform: String {
    case none, uppercase, lowercase, capitalize
  }

  public let family: String?
  public let name: String?
  public let weight: NSFont.Weight
  public let size: CGFloat
  public let lineHeight: CGFloat?
  public let kerning: Double
  public let textTransform: TextTransform
  public let color: NSColor?
  public let alignment: NSTextAlignment

  public init(
    family: String? = nil,
    name: String? = nil,
    weight: NSFont.Weight = NSFont.Weight.regular,
    size: CGFloat = NSFont.systemFontSize,
    lineHeight: CGFloat? = nil,
    kerning: Double = 0,
    textTransform: String = "",
    color: NSColor? = nil,
    alignment: NSTextAlignment = .left) {
    self.family = family
    self.name = name
    self.weight = weight
    self.size = size
    self.lineHeight = lineHeight
    self.kerning = kerning
    self.textTransform = TextTransform(rawValue: textTransform) ?? TextTransform.none
    self.color = color
    self.alignment = alignment
  }

  public func with(
    family: String? = nil,
    name: String? = nil,
    weight: NSFont.Weight? = nil,
    size: CGFloat? = nil,
    lineHeight: CGFloat? = nil,
    kerning: Double? = nil,
    textTransform: String? = nil,
    color: NSColor? = nil,
    alignment: NSTextAlignment? = nil
    ) -> TextStyle {
    return TextStyle(
      family: family ?? self.family,
      name: name ?? self.name,
      weight: weight ?? self.weight,
      size: size ?? self.size,
      lineHeight: lineHeight ?? self.lineHeight,
      kerning: kerning ?? self.kerning,
      textTransform: textTransform ?? self.textTransform.rawValue,
      color: color ?? self.color,
      alignment: alignment ?? self.alignment)
  }

  public lazy var paragraphStyle: NSMutableParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    if let lineHeight = lineHeight {
      paragraphStyle.minimumLineHeight = lineHeight
      paragraphStyle.maximumLineHeight = lineHeight
    }
    paragraphStyle.alignment = alignment
    return paragraphStyle
  }()

  public lazy var nsFontDescriptor: NSFontDescriptor = {
    var attributes: [NSFontDescriptor.AttributeName: Any] = [:]
    var family = self.family

    if family == nil && name == nil {
      family = NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName
    }

    if let family = family {
      attributes[NSFontDescriptor.AttributeName.family] = family
    }

    if let name = name {
      attributes[NSFontDescriptor.AttributeName.name] = name
    }

    attributes[NSFontDescriptor.AttributeName.traits] = [
      NSFontDescriptor.TraitKey.weight: weight
    ]

    return NSFontDescriptor(fontAttributes: attributes)
  }()

  public lazy var nsFont: NSFont = {
    return NSFont(descriptor: nsFontDescriptor, size: size) ??
        NSFont.systemFont(ofSize: size, weight: weight)
  }()

  public lazy var attributeDictionary: [NSAttributedString.Key: Any] = {
    var attributes: [NSAttributedString.Key: Any] = [
      .font: nsFont,
      .kern: kerning,
      .paragraphStyle: paragraphStyle
    ]

    if let lineHeight = lineHeight {
      attributes[.baselineOffset] = (lineHeight - nsFont.ascender + nsFont.descender) / 2
    }

    if let color = color {
      attributes[.foregroundColor] = color
    }

    return attributes
  }()

  public func apply(to string: String) -> NSAttributedString {
    let transformedString = apply(textTransform: textTransform, to: string)

    return NSAttributedString(
      string: transformedString,
      attributes: attributeDictionary)
  }

  public func apply(to attributedString: NSAttributedString) -> NSAttributedString {
    let styledString = NSMutableAttributedString(attributedString: attributedString)

    let transformedString = apply(textTransform: textTransform, to: styledString.mutableString as String)
    styledString.mutableString.setString(transformedString)

    styledString.addAttributes(
      attributeDictionary,
      range: NSRange(location: 0, length: styledString.length))
    return styledString
  }

  public func apply(to attributedString: NSMutableAttributedString, at range: NSRange) {
    let substring = attributedString.mutableString.substring(with: range)
    let transformedSubstring = apply(textTransform: textTransform, to: substring)
    attributedString.mutableString.replaceCharacters(in: range, with: transformedSubstring)
    
    attributedString.addAttributes(
      attributeDictionary,
      range: range)
  }

  private func apply(textTransform: TextTransform, to string: String) -> String {
    switch textTransform {
      case .none:
        return string
      case .uppercase:
        return string.uppercased()
      case .lowercase: 
        return string.lowercased()
      case .capitalize:
        return string.capitalized
      }
  }
}

// MARK: - Equatable

extension TextStyle: Equatable {
  public static func == (lhs: TextStyle, rhs: TextStyle) -> Bool {
    return (
      lhs.family == rhs.family &&
      lhs.name == rhs.name &&
      lhs.weight == rhs.weight &&
      lhs.size == rhs.size &&
      lhs.lineHeight == rhs.lineHeight &&
      lhs.kerning == rhs.kerning &&
      lhs.textTransform == rhs.textTransform &&
      lhs.color == rhs.color &&
      lhs.alignment == rhs.alignment)
  }
}
