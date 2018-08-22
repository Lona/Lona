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

//    @IBOutlet weak var bottom: NSView!
//    @IBOutlet weak var left: NSView!
//    @IBOutlet weak var drawingSurface: NSView!
//    @IBOutlet weak var right: NSView!
//    @IBOutlet weak var verticalSplitter: SectionSplitter!
//    @IBOutlet weak var workspaceSplitView: NSSplitView!
//
    var fileURL: URL?
//
//    var componentCache = [URL: CSComponent]()
//
//    func loadComponent(url: URL) -> CSComponent? {
//        guard let component = CSComponent(url: url) else { return nil }
//
//        return component
//    }
//
//    @IBAction func zoomToActualSize(_ sender: AnyObject) {
//        canvasCollectionView?.zoom(to: 1)
//    }
//
//    @IBAction func zoomIn(_ sender: AnyObject) {
//        canvasCollectionView?.zoomIn()
//    }
//
//    @IBAction func zoomOut(_ sender: AnyObject) {
//        canvasCollectionView?.zoomOut()
//    }
//
//    @IBAction func addComponent(_ sender: AnyObject) {
//        let dialog = NSOpenPanel()
//
//        dialog.title                   = "Choose a .component file"
//        dialog.showsResizeIndicator    = true
//        dialog.showsHiddenFiles        = false
//        dialog.canChooseDirectories    = false
//        dialog.canCreateDirectories    = false
//        dialog.allowsMultipleSelection = false
//        dialog.allowedFileTypes        = ["component"]
//
//        if dialog.runModal() == NSApplication.ModalResponse.OK {
//            if let url = dialog.url {
//                let newLayer = CSComponentLayer.make(from: url)
//
//                // Add number suffix if needed
//                newLayer.name = component.getNewLayerName(startingWith: newLayer.name)
//
//                addLayer(layer: newLayer)
//            }
//        } else {
//            // User clicked on "Cancel"
//            return
//        }
//    }
//
//    @IBAction func addChildren(_ sender: AnyObject) {
//        let newLayer = CSLayer(name: "Children", type: .children, parameters: [
//            "width": 100.toData(),
//            "height": 100.toData(),
//            "backgroundColor": "#D8D8D8".toData()
//        ])
//
//        addLayer(layer: newLayer)
//    }
//
//    @IBAction func addImage(_ sender: AnyObject) {
//        let name = component.getNewLayerName(startingWith: "Image")
//
//        let newLayer = CSLayer(name: name, type: .image, parameters: [
//            "width": 100.toData(),
//            "height": 100.toData(),
//            "backgroundColor": "#D8D8D8".toData()
//        ])
//
//        addLayer(layer: newLayer)
//    }
//
//    @IBAction func addAnimation(_ sender: AnyObject) {
//        let name = component.getNewLayerName(startingWith: "Animation")
//
//        let newLayer = CSLayer(name: name, type: .animation, parameters: [
//            "width": 100.toData(),
//            "height": 100.toData(),
//            "backgroundColor": "#D8D8D8".toData()
//        ])
//
//        addLayer(layer: newLayer)
//    }
//
//    @IBAction func addView(_ sender: AnyObject) {
//        let name = component.getNewLayerName(startingWith: "View")
//
//        let newLayer = CSLayer(name: name, type: .view, parameters: [
//            "width": 100.toData(),
//            "height": 100.toData(),
//            "backgroundColor": "#D8D8D8".toData()
//        ])
//
//        addLayer(layer: newLayer)
//    }
//
//    @IBAction func addText(_ sender: AnyObject) {
//        let name = component.getNewLayerName(startingWith: "Text")
//
//        let newLayer = CSLayer(name: name, type: .text, parameters: [
//            "text": "Text goes here".toData(),
//            "widthSizingRule": "Shrink".toData(),
//            "heightSizingRule": "Shrink".toData()
//        ])
//
//        addLayer(layer: newLayer)
//    }
//
//    func requestSketchFileSaveURL() -> URL? {
//        let dialog = NSSavePanel()
//
//        dialog.title                   = "Export .sketch file"
//        dialog.showsResizeIndicator    = true
//        dialog.showsHiddenFiles        = false
//        dialog.canCreateDirectories    = true
//        dialog.allowedFileTypes        = ["sketch"]
//
//        if dialog.runModal() == NSApplication.ModalResponse.OK {
//            return dialog.url
//        } else {
//            // User clicked on "Cancel"
//            return nil
//        }
//    }
//
//    func getDirectory() -> URL? {
//        let dialog = NSOpenPanel()
//
//        dialog.title                   = "Choose export directory"
//        dialog.showsResizeIndicator    = true
//        dialog.showsHiddenFiles        = false
//        dialog.canCreateDirectories    = true
//        dialog.canChooseDirectories    = true
//        dialog.canChooseFiles          = false
//
//        return dialog.runModal() == NSApplication.ModalResponse.OK ? dialog.url : nil
//    }
//
//    @IBAction func exportToAnimation(_ sender: AnyObject) {
//        guard let url = getDirectory() else { return }
//
//        RenderSurface.renderToAnimations(component: component, directory: url)
//    }
//
//    @IBAction func exportCurrentModuleToImages(_ sender: AnyObject) {
//        guard let url = getDirectory() else { return }
//
//        RenderSurface.renderCurrentModuleToImages(savedTo: url)
//    }
//
//    @IBAction func exportToImages(_ sender: AnyObject) {
//        guard let url = getDirectory() else { return }
//
//        RenderSurface.renderToImages(component: component, directory: url)
//    }
//
//    @IBAction func exportToVideo(_ sender: AnyObject) {
//        guard let url = getDirectory() else { return }
//
//        RenderSurface.renderToVideos(component: component, directory: url)
//    }
//
//    @IBAction func exportToSketch(_ sender: AnyObject) {
//        guard let outputFile = requestSketchFileSaveURL() else { return }
//
//        let mainBundle = Bundle.main
//
//        guard let pathToNode = mainBundle.path(forResource: "node", ofType: "") else { return }
//
//        let dirname = URL(fileURLWithPath: pathToNode).deletingLastPathComponent()
//        let componentToSketch = dirname
//            .appendingPathComponent("Modules", isDirectory: true)
//            .appendingPathComponent("component-to-sketch", isDirectory: true)
//
//        let output = RenderSurface.renderToJSON(layout: component.canvasLayoutAxis, component: component, selected: nil)
//        guard let data = output.toData() else { return }
//
//        guard #available(OSX 10.12, *) else { return }
//
//        DispatchQueue.global().async {
//            let task = Process()
//
//            // Set the task parameters
//            task.launchPath = pathToNode
//            task.arguments = [
//                componentToSketch.appendingPathComponent("index.js").path,
//                outputFile.path
//            ]
//            task.currentDirectoryPath = componentToSketch.path
//
//            let stdin = Pipe()
//            let stdout = Pipe()
//
//            task.standardInput = stdin
//            task.standardOutput = stdout
//
//            // Launch the task
//            task.launch()
//
//            stdin.fileHandleForWriting.write(data)
//            stdin.fileHandleForWriting.closeFile()
//
//            task.waitUntilExit()
//
//            let handle = stdout.fileHandleForReading
//            let data = handle.readDataToEndOfFile()
//            let out = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//
//            Swift.print("result", out ?? "stdout empty")
//        }
//    }

    var component: CSComponent = CSComponent.makeDefaultComponent()

//    override func keyDown(with event: NSEvent) {
//        let characters = event.charactersIgnoringModifiers!
//
//        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
//            guard let targetLayer = selectedLayer else { return }
//            if targetLayer === dataRoot { return }
//
//            let parent = outlineView!.parent(forItem: targetLayer) as! CSLayer
//
//            // Undo
//            let oldChildren = parent.children
//            let children = parent.children.filter({ $0 !== targetLayer })
//            UndoManager.shared.run(name: "Delete", execute: {[unowned self] in
//                self.updateChildren(children: children, for: parent)
//            }, undo: {[unowned self] in
//                self.updateChildren(children: oldChildren, for: parent)
//            })
//        } else if characters == String(Character(" ")) {
//            canvasCollectionView?.panningEnabled = true
//        }
//    }
//
//    override func keyUp(with event: NSEvent) {
//        let characters = event.charactersIgnoringModifiers!
//
//        if characters == String(Character(" ")) {
//            canvasCollectionView?.panningEnabled = false
//        }
//    }
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

// MARK: - LayerListDelegate

extension ViewController: LayerListDelegate {
    func layerList(_ layerList: LayerListOutlineView, do action: LayerListAction) {
//        switch action {
//        case .clearInspector:
//            clearInspector()
//        case .render:
//            render()
//        case .renderInspector(let node):
//            renderInspector(item: node)
//        }
    }
}
