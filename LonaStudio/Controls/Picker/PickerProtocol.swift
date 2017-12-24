//
//  PickerProtocol.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

protocol Identify {
    
    var ID: String { get }
}

protocol Searchable {
    
    var name: String { get }
}

typealias PickerItemType = Identify & Searchable
