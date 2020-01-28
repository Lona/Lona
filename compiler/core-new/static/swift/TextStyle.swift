import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public class TextStyle {
  public let fontFamily: String?
  public let fontName: String?
  public let fontWeight: Font.Weight
  public let fontSize: CGFloat
  public let lineHeight: CGFloat?
  public let kerning: Double
  public let color: Color?
  public let alignment: NSTextAlignment

  public init(
    fontFamily: String? = nil,
    fontName: String? = nil,
    fontSize: CGFloat? = nil,
    fontWeight: Font.Weight? = nil,
    lineHeight: CGFloat? = nil,
    kerning: Double? = nil,
    color: Color? = nil,
    alignment: NSTextAlignment? = nil) {
    self.fontFamily = fontFamily
    self.fontName = fontName
    self.fontWeight = fontWeight ?? FontWeight.w400
    self.fontSize = fontSize ?? Font.systemFontSize
    self.lineHeight = lineHeight
    self.kerning = kerning ?? 0
    self.color = color
    self.alignment = alignment ?? NSTextAlignment.left
  }

  public func with(
    fontFamily: String? = nil,
    fontName: String? = nil,
    fontSize: CGFloat? = nil,
    fontWeight: Font.Weight? = nil,
    lineHeight: CGFloat? = nil,
    kerning: Double? = nil,
    color: Color? = nil,
    alignment: NSTextAlignment? = nil
    ) -> TextStyle {
    return TextStyle(
      fontFamily: fontFamily ?? self.fontFamily,
      fontName: fontName ?? self.fontName,
      fontSize: fontSize ?? self.fontSize,
      fontWeight: fontWeight ?? self.fontWeight,
      lineHeight: lineHeight ?? self.lineHeight,
      kerning: kerning ?? self.kerning,
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

  public lazy var fontDescriptor: FontDescriptor = {
    var attributes: [FontDescriptor.AttributeName: Any] = [:]
    var fontFamily = self.fontFamily

    if fontFamily == nil && fontName == nil {
      fontFamily = Font.systemFont(ofSize: Font.systemFontSize).familyName
    }

    if let fontFamily = fontFamily {
      attributes[FontDescriptor.AttributeName.family] = fontFamily
    }

    if let fontName = fontName {
      attributes[FontDescriptor.AttributeName.name] = fontName
    }

    attributes[FontDescriptor.AttributeName.traits] = [
      FontDescriptor.TraitKey.weight: fontWeight
    ]

    return FontDescriptor(fontAttributes: attributes)
  }()

  public lazy var font: Font = {
    #if os(iOS) || os(tvOS) || os(watchOS)
      return Font(descriptor: fontDescriptor, size: fontSize)
    #elseif os(macOS)
      // NSFont can return nil as opposed to UIFont
      return Font(descriptor: fontDescriptor, size: fontSize) ??
        Font.systemFont(ofSize: fontSize, weight: fontWeight)
    #endif
  }()

  public lazy var attributeDictionary: [NSAttributedString.Key: Any] = {
    var attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .kern: kerning,
      .paragraphStyle: paragraphStyle
    ]

    if let lineHeight = lineHeight {
      attributes[.baselineOffset] = (lineHeight - font.ascender + font.descender) / 2
    }

    if let color = color {
      attributes[.foregroundColor] = color
    }

    return attributes
  }()

  public func apply(to string: String) -> NSAttributedString {
    return NSAttributedString(
      string: string,
      attributes: attributeDictionary)
  }

  public func apply(to attributedString: NSAttributedString) -> NSAttributedString {
    let styledString = NSMutableAttributedString(attributedString: attributedString)
    styledString.addAttributes(
      attributeDictionary,
      range: NSRange(location: 0, length: styledString.length))
    return styledString
  }

  public func apply(to attributedString: NSMutableAttributedString, at range: NSRange) {
    attributedString.addAttributes(
      attributeDictionary,
      range: range)
  }
}

// MARK: - Equatable

extension TextStyle: Equatable {
  public static func == (lhs: TextStyle, rhs: TextStyle) -> Bool {
    return (
      lhs.fontFamily == rhs.fontFamily &&
      lhs.fontName == rhs.fontName &&
      lhs.fontWeight == rhs.fontWeight &&
      lhs.fontSize == rhs.fontSize &&
      lhs.lineHeight == rhs.lineHeight &&
      lhs.kerning == rhs.kerning &&
      lhs.color == rhs.color &&
      lhs.alignment == rhs.alignment)
  }
}
