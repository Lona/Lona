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
            .data(CSShadows.shadows),
            .didSelectItem({(picker, item) in
                picker?.popover.close()
                onChange(item)
            }),
            .placeholderText("Search shadow style ..."),
            .selected(selected),
            .sizeForRow({(textStyle) -> NSSize in
                return NSSize(width: Constant.widthRow, height: Constant.heightRow)
            }),
            .viewForItem({ (tableView, item, selected) -> PickerRowViewType in
                return ShadowStyleRowView(shadow: item, selected: selected)
            })
        ]
        self.init(options: options)
    }
}
