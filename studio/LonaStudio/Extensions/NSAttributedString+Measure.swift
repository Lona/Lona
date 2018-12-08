//
//  NSAttributedString+Measure.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/8/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit

extension NSAttributedString {
    func measure(width: CGFloat, maxNumberOfLines: Int = -1) -> NSSize {
        let textContainer = NSTextContainer(containerSize: NSSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineBreakMode = .byTruncatingTail
        textContainer.lineFragmentPadding = 0.0
        if maxNumberOfLines > -1 {
            textContainer.maximumNumberOfLines = maxNumberOfLines
        }

        let textStorage = NSTextStorage(attributedString: self)

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.glyphRange(for: textContainer)

        return layoutManager.usedRect(for: textContainer).size
    }
}
