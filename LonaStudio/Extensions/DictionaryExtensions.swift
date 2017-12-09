//
//  DictionaryExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/23/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

extension Dictionary {
    func filterValues(f: (Value) -> Bool) -> [Key: Value] {
        var result: [Key: Value] = [:]
        
        for pair in self {
            if f(pair.value) {
                result[pair.key] = pair.value
            }
        }
        
        return result
    }
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
}

