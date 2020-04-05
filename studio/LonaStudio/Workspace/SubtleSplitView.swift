//
//  SubtleSplitView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/24/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

public class SubtleSplitView: NSSplitView {
    public override var dividerColor: NSColor {
        // We use a slightly lighter divider with in mode
        return Colors.dividerSubtle
    }
}

