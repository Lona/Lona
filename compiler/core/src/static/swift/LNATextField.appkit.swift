//
//  LNATextField.swift
//  LonaStudio
//
//  Created by Devin Abbott on 11/1/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// This NSTextField subclass draws strings with a .baselineOffset attribute correctly.
//
// OSX 10.14 fixes a layout issue when using the .baselineOffset attribute, but we use
// this subclass in order to support 10.12 and 10.13. This isn't a general-purpose replacement
// for NSTextField; it should only be used for non-editable labels. Whenever we drop support
// for pre-10.14 we can remove this and use NSTextField directly instead.
public class LNATextField: NSTextField {
  override open class var cellClass: AnyClass? {
    get { return LNATextFieldCell.self }
    set {}
  }

  // Determine the baseline offset from the attributed string value. We store it as a member variable,
  // then we remove it from the attributed string.
  override public var attributedStringValue: NSAttributedString {
    get { return super.attributedStringValue }
    set {
      baselineOffset = newValue.baselineOffset

      let string = NSMutableAttributedString(attributedString: newValue)
      string.removeAttribute(.baselineOffset, range: NSRange(location: 0, length: string.length))
      super.attributedStringValue = string
    }
  }

  fileprivate var baselineOffset: CGFloat?
}

private class LNATextFieldCell: NSTextFieldCell {
  override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    if let textView = controlView as? LNATextField,
      let baselineOffset = textView.baselineOffset,
      let lineHeight = attributedStringValue.lineHeight {

      var rect = cellFrame.insetBy(dx: 2, dy: 0)

      rect.origin.y -= baselineOffset

      let truncatesLastVisibleLine = textView.maximumNumberOfLines > 0 &&
        cellFrame.height / lineHeight >= CGFloat(textView.maximumNumberOfLines)

      let options: NSString.DrawingOptions = truncatesLastVisibleLine
        ? [.usesLineFragmentOrigin, .truncatesLastVisibleLine]
        : [.usesLineFragmentOrigin]

      attributedStringValue.draw(with: rect, options: options)
    } else {
      super.drawInterior(withFrame: cellFrame, in: controlView)
    }
  }
}

private extension NSAttributedString {
  var lineHeight: CGFloat? {
    guard
      length > 0,
      let paragraphStyle = attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    else { return nil }

    let lineHeight = paragraphStyle.minimumLineHeight

    if lineHeight <= 0 { return nil }

    return lineHeight
  }

  var baselineOffset: CGFloat? {
    guard
      length > 0,
      let lineHeight = lineHeight,
      let font = attribute(.font, at: 0, effectiveRange: nil) as? NSFont
    else { return nil }

    return (lineHeight - font.ascender + font.descender) / 2
  }
}
