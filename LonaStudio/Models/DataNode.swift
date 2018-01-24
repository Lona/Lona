//
//  DataNode.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/4/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

@objc protocol DataNode {
    func childCount() -> Int
    func child(at index: Int) -> Any
}

protocol DataNodeParent: DataNode {
    func append(_ node: DataNode)
    func insert(_ node: DataNode, at index: Int)
    func remove(at index: Int)
}

protocol DataNodeCopying: DataNode, CSDataSerializable, CSDataDeserializable {}

//protocol MenuProvider {
//    func defaultMenu<Element>(for listEditor: ListEditor<Element>) -> [NSMenuItem]
//}
