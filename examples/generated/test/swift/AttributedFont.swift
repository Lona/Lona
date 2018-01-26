import Foundation
import UIKit

public class AttributedFont {
  public let family: String?
  public let name: String?
  public let weight: UIFont.Weight
  public let size: CGFloat
  public let lineHeight: CGFloat
  public let kerning: Double
  public let color: UIColor

  public init(
    family: String? = nil,
    name: String? = nil,
    weight: UIFont.Weight = UIFont.Weight.regular,
    size: CGFloat = UIFont.systemFontSize,
    lineHeight: CGFloat? = nil,
    kerning: Double = 0,
    color: UIColor = UIColor.black)
  {
    self.family = family
    self.name = name
    self.weight = weight
    self.size = size
    self.lineHeight = lineHeight ?? size * 1.5
    self.kerning = kerning
    self.color = color
  }

  public func with(
    family: String? = nil,
    name: String? = nil,
    weight: UIFont.Weight? = nil,
    size: CGFloat? = nil,
    lineHeight: CGFloat? = nil,
    kerning: Double? = nil,
    color: UIColor? = nil
    ) -> AttributedFont
  {
    return AttributedFont(
      family: family ?? self.family,
      name: name ?? self.name,
      weight: weight ?? self.weight,
      size: size ?? self.size,
      lineHeight: lineHeight ?? self.lineHeight,
      kerning: kerning ?? self.kerning,
      color: color ?? self.color)
  }

  public lazy var paragraphStyle: NSMutableParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.maximumLineHeight = lineHeight
    return paragraphStyle
  }()

  public lazy var uiFontDescriptor: UIFontDescriptor = {
    var attributes: [UIFontDescriptor.AttributeName: Any] = [:]

    if let family = family {
      attributes[UIFontDescriptor.AttributeName.family] = family
    }

    if let name = name {
      attributes[UIFontDescriptor.AttributeName.name] = name
    }

    attributes[UIFontDescriptor.AttributeName.traits] = [
      UIFontDescriptor.TraitKey.weight: weight
    ]

    return UIFontDescriptor(fontAttributes: attributes)
  }()

  public lazy var uiFont: UIFont = {
    return UIFont(descriptor: uiFontDescriptor, size: size)
  }()

  public lazy var attributeDictionary: [NSAttributedStringKey: Any] = {
    return [
      .font: uiFont,
      .foregroundColor: color,
      .kern: kerning,
      .paragraphStyle: paragraphStyle
    ]
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
