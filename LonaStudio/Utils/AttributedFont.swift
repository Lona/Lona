
import Foundation
import AppKit

public enum AttributedFontWeight: Int {
    case standard = 3
    case medium = 4
    case bold = 7
}

public class AttributedFont {
    
    public let fontFamily: String
    public var fontSize: CGFloat
    public let lineHeight: CGFloat
    public let kerning: Double
    public let weight: AttributedFontWeight
    public let color: NSColor
    public let textAlignment: NSTextAlignment
    public let lineBreakMode: NSLineBreakMode
    
    public init(
        fontFamily: String,
        fontSize: CGFloat,
        lineHeight: CGFloat,
        kerning: Double,
        weight: AttributedFontWeight,
        color: NSColor = NSColor.black,
        textAlignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail)
    {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.kerning = kerning
        self.weight = weight
        self.color = color
        self.textAlignment = textAlignment
        self.lineBreakMode = lineBreakMode
    }
    
    public var nsFont: NSFont {
        if let targetFont = NSFontManager.shared().font(withFamily: fontFamily, traits: NSFontTraitMask(rawValue: 0), weight: weight.rawValue, size: fontSize) {
            return targetFont
        }
        
        Swift.print("Could not find font", fontFamily, "with size", fontSize, "and weight", weight.rawValue)
        
        return NSFont.systemFont(ofSize: fontSize, weight: NSFontWeightRegular)
    }
    
    public func apply(to string: String) -> NSAttributedString {
        return NSAttributedString(
            string: string,
            attributes: attributeDictionary())
    }
    
    public func apply(to attributedString: NSAttributedString) -> NSAttributedString {
        let styledString = NSMutableAttributedString(attributedString: attributedString)
        styledString.addAttributes(
            attributeDictionary(),
            range: NSRange(location: 0, length: styledString.length))
        return styledString
    }
    
    public func apply(to attributedString: NSMutableAttributedString, at range: NSRange) {
        attributedString.addAttributes(
            attributeDictionary(),
            range: range)
    }
    
    public var paragraphStyle: NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
//        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        return paragraphStyle
    }
    
    func attributeDictionary() -> [String: Any] {
        return [
            NSFontAttributeName: nsFont,
            NSForegroundColorAttributeName: color,
            NSKernAttributeName: kerning,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
}

extension AttributedFont: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = AttributedFont(fontFamily: fontFamily,
                                  fontSize: fontSize,
                                  lineHeight: lineHeight,
                                  kerning: kerning,
                                  weight: weight,
                                  textAlignment: textAlignment,
                                  lineBreakMode: lineBreakMode)
        return copy
    }
}
