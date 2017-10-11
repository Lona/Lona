//
//  Button.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class Button: NSButton {
    
    var onPress: () -> Void = {_ in}
    
    func handlePress() {
        onPress()
    }
    
    func setup() {
        action = #selector(handlePress)
        target = self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    init(title: String) {
        super.init(frame: NSRect.zero)
        setup()
        setButtonType(.momentaryPushIn)
        imagePosition = .noImage
        alignment = .left
        bezelStyle = .rounded
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
