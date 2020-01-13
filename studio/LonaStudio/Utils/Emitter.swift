//
//  Emitter.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/13/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

public struct Emitter<Context> {

    // MARK: Private

    private var listeners: [Int: Listener] = [:]

    private var key: Int = 0

    // MARK: Public

    public typealias Listener = (Context) -> Void

    public init() {}

    public mutating func addListener(_ listener: @escaping Listener) -> Int {
        key = key + 1

        listeners[key] = listener

        return key
    }

    public mutating func removeListener(forKey key: Int) {
        listeners.removeValue(forKey: key)
    }

    public func emit(_ context: Context) {
        listeners.forEach { (_, value) in
            value(context)
        }
    }
}
