//
//  LayerContentsCache.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/14/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class LayerContentsCache {
    var maxEntries: Int
    var data: [String: Any] = [:]
    var lru: [String] = []
    
    init(maxEntries: Int = 100) {
        self.maxEntries = maxEntries
    }
    
    func getKey(for url: URL, at scale: CGFloat) -> String {
        return url.absoluteString + String(describing: scale)
    }
    
    func evict() {
        if lru.count > maxEntries {
            lru.removeLast(lru.count - maxEntries)
        }
    }
    
    func push(entry: String) {
        lru.insert(entry, at: 0)
        evict()
    }
    
    func refresh(entry: String) {
        guard let index = lru.index(of: entry) else { return }
        lru.remove(at: index)
        lru.insert(entry, at: 0)
    }
    
    func add(contents: Any, for url: URL, at scale: CGFloat) {
        let key = getKey(for: url, at: scale)
        
        if data[key] == nil {
            push(entry: key)
        } else {
            refresh(entry: key)
        }
        
        data[key] = contents
    }
    
    func contents(for url: URL, at scale: CGFloat) -> Any? {
        let key = getKey(for: url, at: scale)
        return data[key]
    }
}
