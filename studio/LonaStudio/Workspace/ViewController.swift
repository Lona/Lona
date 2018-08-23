//
//  ViewController.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa
import MASPreferences

class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    var component: CSComponent = CSComponent.makeDefaultComponent()
//
//    var inspectorContent: NSView?
//
//    func renderInspector(item: DataNode) {
//        clearInspector()
//        guard let layer = item as? CSLayer else { return }
//
//        let inspectorView: NSView
//        if case CSLayer.LayerType.custom = layer.type, let layer = layer as? CSComponentLayer {
//            let componentInspectorView = CustomComponentInspectorView(componentLayer: layer)
//            componentInspectorView.onChangeData = {[unowned self] (data, parameter) in
//                layer.parameters[parameter.name] = data
//
//                self.outlineView.render()
//                self.render()
//                componentInspectorView.reload()
//            }
//            inspectorView = componentInspectorView
//        } else {
//            let layerInspector = LayerInspectorView(layer: layer)
//            layerInspector.onChangeInspector = {[unowned self] changeType in
//                switch changeType {
//                case .canvas:
//                    self.outlineView?.reloadItem(layer)
//                    self.render()
//                case .full:
//                    self.outlineView.render(fullRender: true)
//                    self.render()
//                }
//            }
//            inspectorView = layerInspector
//        }
//
//        let scrollView = InspectorContentView(inspectorView: inspectorView)
//        right.addSubviewStretched(subview: scrollView)
//
//        // Keep a reference so we can remove it from its superview later
//        self.inspectorContent = scrollView
//    }
}

