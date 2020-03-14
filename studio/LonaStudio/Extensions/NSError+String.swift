//
//  NSError+String.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/18/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(_ string: String) {
        self.init(domain: string, code: 0, userInfo: nil)
    }
}
