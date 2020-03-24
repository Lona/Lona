//
//  CaseList.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

class LogicListView {

    var component: CSComponent?
    var editor: ListEditor<LogicNode>?

    var list: [LogicNode] {
        get { return editor?.list ?? [] }
        set { editor?.list = newValue }
    }

    var onChange: ([LogicNode]) -> Void {
        get { return editor?.onChange ?? {_ in}}
        set { editor?.onChange = newValue }
    }

    func scope(for targetNode: LogicNode, component: CSComponent) -> CSScope {
        func performLogicBody(nodes: [LogicNode], in scope: CSScope) -> CSScope? {
            for node in nodes {
                if targetNode === node { return scope }

                let invocation = node.invocation

                if invocation.canBeInvoked {
                    let function = CSFunction.getFunction(declaredAs: invocation.name)

                    function.updateScope(invocation.arguments, scope)

                    if function.hasBody {
                        if let result = performLogicBody(nodes: node.nodes, in: CSScope(parent: scope)) { return result }
                    }
                }
            }

            return nil
        }

        let rootScope = component.rootScope()

        return performLogicBody(nodes: component.logic, in: rootScope) ?? rootScope
    }

    init(frame frameRect: NSRect) {
        editor = ListEditor<LogicNode>(frame: frameRect, options: [
            ListEditor.Option.backgroundColor(NSColor.white),
            ListEditor.Option.onAddElement({ [unowned self] in self.editor?.add(element: LogicNode()) }),
            ListEditor.Option.onContextMenu({ [unowned self] item -> [NSMenuItem] in
                return [
                    NSMenuItem(title: "Duplicate", onClick: { self.editor?.duplicate(element: item) })
                ]
            }),
            ListEditor.Option.onRemoveElement({ [unowned self] item in
                self.editor?.remove(element: item)
            }),
            ListEditor.Option.viewFor({ [unowned self] item -> NSView in
                guard let component = self.component else {
                    return CSStatementView(frame: NSRect.zero, components: [])
                }

                let scope = self.scope(for: item, component: component)
                let cell = CSStatementView.view(for: item.invocation, in: scope)

                cell.onChangeValue = { [unowned self] name, value, keyPath in
                    if name == "functionName" {
                        let function: CSFunction = CSFunction.getFunction(declaredAs: value.data.stringValue)
                        item.invocation.name = function.declaration
                    } else {
                        if keyPath.count == 0 ||
                            keyPath == CSFunction.Argument.customKeyPath ||
                            keyPath == CSFunction.Argument.customValueKeyPath {
                            item.invocation.arguments[name] = CSFunction.Argument.value(value)
                        } else if keyPath == CSFunction.Argument.customTypeKeyPath {
                            let argument = item.invocation.arguments[name] ?? CSFunction.Argument.value(CSUndefinedValue)
                            let newType = CSType(value.data)
                            let newValue = argument.resolve(in: scope).cast(to: newType)
                            item.invocation.arguments[name] = CSFunction.Argument.value(newValue)
                        } else {
                            item.invocation.arguments[name] = CSFunction.Argument.identifier(value.type, keyPath)
                        }

                        item.invocation = CSStatementView.automaticallySetNextArguments(for: item.invocation)
                    }

                    self.onChange(self.list)
                }

                cell.onAddChild = { [unowned self] in self.editor?.add(element: LogicNode(), to: item) }

                return cell
            })
        ])
    }
}
