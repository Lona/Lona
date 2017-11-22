//
//  Parameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class LogicNode: DataNodeParent, DataNodeCopying {
    var nodes: [LogicNode] = []
    var invocation: CSFunction.Invocation = CSFunction.Invocation()
    
    required init(_ data: CSData) {
        self.nodes = data.get(key: "nodes").arrayValue.map({ LogicNode($0) })
        self.invocation = CSFunction.Invocation(data.get(key: "function"))
    }
    
    required init() {}
    
    func toData() -> CSData {
        return CSData.Object([
            "nodes": nodes.toData(),
            "function": invocation.toData(),
        ])
    }
    
    func childCount() -> Int { return nodes.count }
    func child(at index: Int) -> Any { return nodes[index] }
    func append(_ node: DataNode) {
        guard let node = node as? LogicNode else { return }
        nodes.append(node)
    }
    func insert(_ node: DataNode, at index: Int) {
        guard let node = node as? LogicNode else { return }
        
        // TODO: Or is there a bug in the node moving code?
        if index >= nodes.count {
            nodes.append(node)
        } else {
            nodes.insert(node, at: index)
        }
    }
    func remove(at index: Int) {
        if index >= nodes.count {
            Swift.print("ERROR: Failed to remove item from LogicNode, index out of range")
            return
        }
        
        nodes.remove(at: index)
    }
    
    func set(variable name: String, to value: CSValue) {}
}

