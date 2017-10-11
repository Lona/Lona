//
//  CSObject.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/25/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONDeserializable {
    init(_ json: JSON)
}

protocol JSONSerializable {
    func toJSON() -> Any?
}

