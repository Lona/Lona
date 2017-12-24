//
//  PickerProtocol.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

protocol Identify {
    
    var id: String { get }
}

protocol Searchable {
    
    var name: String { get }
}

protocol PickerRowViewHoverable {
    func onHover(_ hover: Bool)
}

typealias PickerItemType = Identify & Searchable
typealias PickerRowViewType = PickerRowViewHoverable
