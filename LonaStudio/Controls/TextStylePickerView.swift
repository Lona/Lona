//
//  TextStylePickerView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class TextStylePickerView: PickerView<CSTextStyle> {
    
    private struct Constant {
        static let maxWidth: CGFloat = 1000
        static let minHeightRow: CGFloat = 32.0
        static let maxHeightRow: CGFloat = 200.0
    }
    
    convenience init(selected: String, onChange: @escaping (CSTextStyle) -> Void) {
        let options: [PickerView<CSTextStyle>.Option] = [
            .placeholderText("Search text style ..."),
            .sizeForRow({(textStyle) -> NSSize in
                let text = textStyle.font.apply(to: textStyle.name)
                return TextStylePickerView.fitTextSize(text)
            })
        ]
        self.init(data: CSTypography.styles,
                  selected: selected,
                  viewForItem: { (_, item, selected) -> PickerRowViewType in
                    return TextStyleRowView(textStyle: item, selected: selected)
        },
                  didSelectItem: { (picker, item) in
                    picker?.popover.close()
                    onChange(item)
        },
                  options: options)
    }
    
    private class func fitSize(with attributeString: NSAttributedString) -> NSSize {
        let fixedSize = NSSize(width: Constant.maxWidth, height: Constant.maxHeightRow)
        return attributeString.boundingRect(with: fixedSize,
                                            options: NSString.DrawingOptions.usesFontLeading).size
    }
    
    private class func fitTextSize(_ attributeText: NSAttributedString) -> NSSize {
        let size = fitSize(with: attributeText)
        var height = size.height
        height = min(height, Constant.maxHeightRow)
        height = max(height, Constant.minHeightRow)
        return NSSize(width: size.width, height: height)
    }
}
