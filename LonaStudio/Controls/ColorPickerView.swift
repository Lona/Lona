//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

class ColorPickerView: PickerView<CSColor> {
    
    private struct Constant {
        static let heightRow: CGFloat = 37
        static let widthRow: CGFloat = 200
    }
    
    convenience init(selected: String, onChange: @escaping (CSColor) -> Void) {
        let options: [PickerView<CSColor>.Option] = [
            .data(CSColors.colors),
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
                return ColorSwatchRowView(color: item, selected: selected)
            })
        ]
        self.init(options: options)
    }
}

