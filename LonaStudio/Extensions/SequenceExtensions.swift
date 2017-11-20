//
//  SequenceExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/15/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

extension Sequence {
    func key<T, U>(_ f: (Iterator.Element) -> (key: T, value: U)) -> [T: U] {
        var empty: [T: U] = [:]
        
        forEach { element in
            let result = f(element)
            empty[result.key] = result.value
        }
        
        return empty
    }
}

extension Array {
    func keyBy<T>(_ f: (Element) -> T) -> [T: Element] {
        var empty: [T: Element] = [:]
        
        forEach { element in
            empty[f(element)] = element
        }
        
        return empty
    }
}
