//
//  History.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/2/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

// MARK: - History

public struct History<Item: Equatable> {
    public var back: [Item] = []
    public var current: Item?
    public var forward: [Item] = []
    public var maxLength: Int = 20
    public var allowsConsecutiveDuplicates = false

    public init(_ current: Item? = nil) {
        self.current = current
    }

    public mutating func navigateTo(_ item: Item) {
        if let current = current {
            if current == item && !allowsConsecutiveDuplicates {
                return
            }

            back.insert(current, at: 0)
        }

        current = item
        forward.removeAll()

        evict()
    }

    public mutating func goBack(offset: Int = 0) {
        for _ in 0..<offset + 1 {
            goBack()
        }
    }

    public mutating func goBack() {
        if let current = current {
            forward.insert(current, at: 0)
        }

        if let first = back.first {
            current = first
            back.remove(at: 0)
        }

        evict()
    }

    public mutating func goForward(offset: Int = 0) {
        for _ in 0..<offset + 1 {
            goForward()
        }
    }

    public mutating func goForward() {
        if let current = current {
            back.insert(current, at: 0)
        }

        if let first = forward.first {
            current = first
            forward.remove(at: 0)
        }

        evict()
    }

    public func canGoBack(offset: Int = 0) -> Bool {
        return back.count > offset
    }

    public func canGoForward(offset: Int = 0) -> Bool {
        return forward.count > offset
    }

    public mutating func reset() {
        current = nil
        back.removeAll()
        forward.removeAll()
    }

    private mutating func evict() {
        if back.count > maxLength {
            back = Array(back.prefix(upTo: maxLength))
        }

        if forward.count > maxLength {
            forward = Array(forward.prefix(upTo: maxLength))
        }
    }
}
