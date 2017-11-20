//
//  JSONExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Array where Element: JSONSerializable {
    func toJSON() -> [Any?] {
        return self.map({ $0.toJSON() })
    }
}
