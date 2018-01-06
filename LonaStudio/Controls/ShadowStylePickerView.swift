//
//  ShadowStylePickerView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class ShadowStylePickerView: PickerView<CSShadow> {
    
    private struct Constant {
        static let heightRow: CGFloat = 44
        static let widthRow: CGFloat = 300
    }
    
    convenience init(selected: String, onChange: @escaping (CSShadow) -> Void) {
        let options: [PickerView<CSShadow>.Option] = [
            .placeholderText("Search shadow style ..."),
            .sizeForRow({(textStyle) -> NSSize in
                return NSSize(width: Constant.widthRow, height: Constant.heightRow)
            })
        ]
        self.init(data: CSShadows.shadows,
                  selected: selected,
                  viewForItem: { (_, item, selected) -> PickerRowViewType in
                    return ShadowStyleRowView(shadow: item, selected: selected)
        },
                  didSelectItem: { (picker, item) in
                    picker?.popover.close()
                    onChange(item)
        },
                  options: options)
    }
}
