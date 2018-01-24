//
//  CSControl.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/4/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
//
//  CheckboxField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/16/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

protocol CSControl {
    typealias Handler = (CSData) -> Void

    var data: CSData { get set }
    var onChangeData: Handler { get set }
}
