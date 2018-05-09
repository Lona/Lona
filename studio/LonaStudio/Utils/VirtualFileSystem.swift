//
//  MemoryFileSystem.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

protocol VirtualNode {
    var name: String { get }
}

struct VirtualFile: VirtualNode {
    let name: String
    let contents: Data

    init(name: String, contents: Data) {
        self.name = name
        self.contents = contents
    }

    init(name: String, data: CSData) {
        self.init(name: name, contents: data.toData() ?? Data())
    }
}

struct VirtualDirectory: VirtualNode {
    let name: String
    let children: [VirtualNode]

    init(name: String, children: [VirtualNode]) {
        self.name = name
        self.children = children
    }

    init(name: String) {
        self.init(name: name, children: [])
    }
}

enum VirtualFileSystem {
    static func write(node: VirtualNode, relativeTo: URL) throws {
        if let file = node as? VirtualFile {
            let url = relativeTo.appendingPathComponent(file.name)
            FileManager.default.createFile(atPath: url.path, contents: file.contents)
        } else if let directory = node as? VirtualDirectory {
            let url = relativeTo.appendingPathComponent(directory.name, isDirectory: true)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
            try directory.children.forEach {
                try write(node: $0, relativeTo: url)
            }
        }
    }
}
