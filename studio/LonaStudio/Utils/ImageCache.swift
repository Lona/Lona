//
//  ImageCache.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/14/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class ImageCache<Item>: LRUCache<String, Item> {
    func getKey(for url: URL, at scale: CGFloat) -> String {
        return url.absoluteString + String(describing: scale)
    }

    func add(contents: Item, for url: URL, at scale: CGFloat) {
        let key = getKey(for: url, at: scale)

        add(item: contents, for: key)
    }

    func contents(for url: URL, at scale: CGFloat) -> Item? {
        let key = getKey(for: url, at: scale)

        return item(for: key)
    }
}
