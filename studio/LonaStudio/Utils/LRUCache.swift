//
//  LRUCache.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/19/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

public class LRUCache<Key: Hashable, Item> {
    var maxEntries: Int
    var data: [Key: Item] = [:]
    var lru: [Key] = []

    init(maxEntries: Int = 100) {
        self.maxEntries = maxEntries
    }

    // MARK: Public

    func add(item: Item, for key: Key) {
        if data[key] == nil {
            push(entry: key)
        } else {
            refresh(entry: key)
        }

        data[key] = item
    }

    func item(for key: Key) -> Item? {
        return data[key]
    }

    // MARK: Private

    private func evict() {
        if lru.count > maxEntries {
            lru.removeLast(lru.count - maxEntries)
        }
    }

    private func push(entry: Key) {
        lru.insert(entry, at: 0)
        evict()
    }

    private func refresh(entry: Key) {
        guard let index = lru.index(of: entry) else { return }
        lru.remove(at: index)
        lru.insert(entry, at: 0)
    }
}
