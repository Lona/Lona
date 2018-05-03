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

    @IBOutlet weak var bottom: NSView!
    @IBOutlet weak var left: NSView!
    @IBOutlet weak var drawingSurface: NSView!
    @IBOutlet weak var right: NSView!
    @IBOutlet weak var verticalSplitter: SectionSplitter!
    @IBOutlet weak var workspaceTabsContainer: NSView!
    @IBOutlet weak var workspaceSplitView: NSSplitView!

    var selectedLayer: CSLayer? {
        return outlineView.item(atRow: outlineView.selectedRow) as! CSLayer?
    }

    var selectedLayerOrRoot: CSLayer {
        return selectedLayer ?? dataRoot
    }

    func addLayer(layer newLayer: CSLayer) {
        let targetLayer = selectedLayerOrRoot
        var parent: CSLayer!
        var index: Int!

        if targetLayer === self.dataRoot {
            parent = targetLayer
            index = parent.children.count
        } else {
            parent = self.outlineView!.parent(forItem: targetLayer) as! CSLayer
            index = self.outlineView!.childIndex(forItem: targetLayer) + 1
        }

        // Undo
        let oldChildren = parent.children
        UndoManager.shared.run(name: "Add", execute: {[unowned self] in
            parent.insertChild(newLayer, at: index)
            self.relayoutLayerList(newLayer)
        }, undo: {[unowned self] in
            self.updateChildren(children: oldChildren, for: parent)
            self.relayoutLayerList()
        })
    }

    private func relayoutLayerList(_ newLayer: CSLayer? = nil) {
        outlineView.render()

        // Selection
        if let newLayer = newLayer {
            let newLayerIndex = outlineView!.row(forItem: newLayer)
            let selection: IndexSet = [newLayerIndex]
            outlineView!.selectRowIndexes(selection, byExtendingSelection: false)
        }

        render()
    }

    var fileURL: URL?

    var componentCache = [URL: CSComponent]()

    func loadComponent(url: URL) -> CSComponent? {
//        if (componentCache[url] != nil) {
//            return componentCache[url]
//        }

        guard let component = CSComponent(url: url) else { return nil }
//        componentCache[url] = component

        return component
    }

    @IBAction func zoomToActualSize(_ sender: AnyObject) {
        canvasCollectionView?.zoom(to: 1)
    }

    @IBAction func zoomIn(_ sender: AnyObject) {
        canvasCollectionView?.zoomIn()
    }

    @IBAction func zoomOut(_ sender: AnyObject) {
        canvasCollectionView?.zoomOut()
    }

    @IBAction func refresh(_ sender: AnyObject) {
        CSUserTypes.reload()
        CSColors.reload()
        CSTypography.reload()
        CSGradients.reload()
        CSShadows.reload()
        ComponentMenu.shared?.updateComponentsFromModule()

        component.layers
            .filter({ $0 is CSComponentLayer })
            .forEach({ layer in
                let layer = layer as! CSComponentLayer
                layer.reload()
            })

        outlineView.render()
        render()
    }

    @IBAction func addComponent(_ sender: AnyObject) {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a .component file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["component"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url {
                let newLayer = CSComponentLayer.make(from: url)

                // Add number suffix if needed
                newLayer.name = component.getNewLayerName(startingWith: newLayer.name)

                addLayer(layer: newLayer)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

    @IBAction func addChildren(_ sender: AnyObject) {
        let newLayer = CSLayer(name: "Children", type: .children, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        addLayer(layer: newLayer)
    }

    @IBAction func addImage(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Image")

        let newLayer = CSLayer(name: name, type: .image, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        addLayer(layer: newLayer)
    }

    @IBAction func addAnimation(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Animation")

        let newLayer = CSLayer(name: name, type: .animation, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        addLayer(layer: newLayer)
    }

    @IBAction func addView(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "View")

        let newLayer = CSLayer(name: name, type: .view, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        addLayer(layer: newLayer)
    }

    @IBAction func addText(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Text")

        let newLayer = CSLayer(name: name, type: .text, parameters: [
            "text": "Text goes here".toData(),
            "widthSizingRule": "Shrink".toData(),
            "heightSizingRule": "Shrink".toData()
        ])

        addLayer(layer: newLayer)
    }

    func requestSketchFileSaveURL() -> URL? {
        let dialog = NSSavePanel()

        dialog.title                   = "Export .sketch file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = ["sketch"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            return dialog.url
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }

    func getDirectory() -> URL? {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose export directory"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles          = false

        return dialog.runModal() == NSApplication.ModalResponse.OK ? dialog.url : nil
    }

    @IBAction func exportToAnimation(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        RenderSurface.renderToAnimations(component: component, directory: url)
    }

    @IBAction func exportCurrentModuleToImages(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        RenderSurface.renderCurrentModuleToImages(savedTo: url)
    }

    @IBAction func exportToImages(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        RenderSurface.renderToImages(component: component, directory: url)
    }

    @IBAction func exportToVideo(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        RenderSurface.renderToVideos(component: component, directory: url)
    }

    @IBAction func exportToSketch(_ sender: AnyObject) {
        guard let outputFile = requestSketchFileSaveURL() else { return }

        let mainBundle = Bundle.main

        guard let pathToNode = mainBundle.path(forResource: "node", ofType: "") else { return }

        let dirname = URL(fileURLWithPath: pathToNode).deletingLastPathComponent()
        let componentToSketch = dirname
            .appendingPathComponent("Modules", isDirectory: true)
            .appendingPathComponent("component-to-sketch", isDirectory: true)

        let output = RenderSurface.renderToJSON(layout: component.canvasLayoutAxis, component: component, selected: nil)
        guard let data = output.toData() else { return }

        guard #available(OSX 10.12, *) else { return }

        DispatchQueue.global().async {
            let task = Process()

            // Set the task parameters
            task.launchPath = pathToNode
            task.arguments = [
                componentToSketch.appendingPathComponent("index.js").path,
                outputFile.path
            ]
            task.currentDirectoryPath = componentToSketch.path

            let stdin = Pipe()
            let stdout = Pipe()

            task.standardInput = stdin
            task.standardOutput = stdout

            // Launch the task
            task.launch()

            stdin.fileHandleForWriting.write(data)
            stdin.fileHandleForWriting.closeFile()

            task.waitUntilExit()

            let handle = stdout.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            let out = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

            Swift.print("result", out ?? "stdout empty")
        }
    }

    @IBAction func pushToSketch(_ sender: AnyObject) {
//        let string = component.toJSONString()
//
//        let componentName = fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled"
//
//        let componentPath = "/tmp/\(componentName).component";
//        let url = URL(fileURLWithPath: componentPath)
//        try! string.write(to: url, atomically: true, encoding: String.Encoding.utf8)
//
//        DispatchQueue.global().async {
//            let task = Process()
//
//            // Set the task parameters
//            task.launchPath = "/usr/local/opt/nvm/versions/node/v8.1.3/bin/node"
//            task.arguments = [
//                "/Users/devin_abbott/Projects/ComponentStudio/ComponentStudio/generators/react/index.js",
//                componentPath,
//                "/Users/devin_abbott/Projects/component-picker/sketchapp-demo-plugin/src/components/\(componentName).js",
//                "--primitives",
//            ]
//            task.currentDirectoryPath = "/Users/devin_abbott/Projects/ComponentStudio/ComponentStudio/generators/react"
//
//            // Create a Pipe and make the task
//            // put all the output there
//            let pipe = Pipe()
//            task.standardOutput = pipe
//
//            // Launch the task
//            task.launch()
//        }
    }

    var component: CSComponent = CSComponent.makeDefaultComponent()

    var dataRoot: CSLayer { return component.rootLayer }

    var outlineView: LayerList!
    var renderSurface: RenderSurface?
    var canvasCollectionView: CanvasCollectionView?

    func render() {
        logicListView?.editor?.reloadData()

        let selectLayer: (CSLayer) -> Void = { layer in
//            var topLevelLayer: CSLayer? = layer
//            while let parent = topLevelLayer?.config?.parentComponentLayer {
//                topLevelLayer = parent
//            }

//            self.outlineView.select(item: topLevelLayer!)
        }

        if canvasCollectionView == nil {
            canvasCollectionView = CanvasCollectionView(frame: NSRect.zero)
            drawingSurface.addSubviewStretched(subview: canvasCollectionView!)
        }

        let options = CanvasCollectionOptions(
            layout: component.canvasLayoutAxis,
            component: component,
            selected: selectedLayer?.name,
            onSelectLayer: selectLayer
        )

        canvasCollectionView?.update(options: options)
    }

    func setComponent(component: CSComponent) {
        self.component = component
        self.outlineView?.component = component
        self.logicListView?.component = component
        self.logicListView?.list = component.logic
        self.parameterListEditorView?.parameterList = component.parameters
        self.caseList?.component = component
        self.caseList?.list = component.cases
        self.canvasListView?.canvasList = component.canvas
        self.canvasListView?.canvasLayout = component.canvasLayoutAxis
        self.canvasListView?.editorView.component = component
        self.metadataEditorView?.update(data: component.metadata)

        outlineView.render()
        render()
    }

    func clearInspector() {
        // We do this in order to preserve the border view in the `right` view
        inspectorContent?.removeFromSuperview()
    }

    var canvasListView: CanvasListView?
    var logicListView: LogicListView?
    var parameterListEditorView: ParameterListEditorView?
    var caseList: CaseList?
    var metadataEditorView: MetadataEditorView?
    var documentationView: NSView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let workspaceVerticalTabs = WorkspaceVerticalTabs()
        workspaceVerticalTabs.selectedValue = "layers"
        workspaceVerticalTabs.onClickLayers = {
            workspaceVerticalTabs.selectedValue = "layers"
            self.workspaceSplitView.isHidden = false
            self.documentationView?.isHidden = true
        }

        workspaceVerticalTabs.onClickDocumentation = {
            workspaceVerticalTabs.selectedValue = "documentation"

            self.workspaceSplitView.isHidden = true

            if self.documentationView == nil {
                let documentationView = NSView(frame: .zero)
                documentationView.translatesAutoresizingMaskIntoConstraints = false

                self.view.addSubview(documentationView)

                documentationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60).isActive = true
                documentationView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                documentationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                documentationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

                self.documentationView = documentationView
            }

            self.documentationView?.isHidden = false
        }
        workspaceTabsContainer.addSubview(workspaceVerticalTabs)
        workspaceTabsContainer.constrain(to: workspaceVerticalTabs, [.leading, .top, .trailing, .bottom])

        right.addBorderView(to: .left)
        right.backgroundFill = #colorLiteral(red: 0.9486700892, green: 0.9493889213, blue: 0.9487814307, alpha: 1).cgColor

        // Splitter setup

        let tabs = SegmentedControlField(
            frame: NSRect(x: 0, y: 0, width: 500, height: 24),
            values: ["Devices", "Parameters", "Logic", "Examples", "Details"])
        tabs.segmentWidth = 97
        tabs.useYogaLayout = true
        tabs.segmentStyle = .roundRect

        verticalSplitter.addSubviewToDivider(tabs)

        // Metadata editor setup

        let metadataEditorView = MetadataEditorView(data: component.metadata, onChangeData: { value in
            Swift.print("updated metadata", value)
            self.component.metadata = value
            self.render()
        })

        // Canvas list setup

        let canvasListView = CanvasListView(frame: NSRect.zero)
        canvasListView.canvasList = component.canvas
        canvasListView.onChange = { value in
            self.component.canvas = value
            self.render()
        }
        canvasListView.onChangeLayout = { value in
            self.component.canvasLayoutAxis = value
            self.render()
        }

        bottom.addSubviewStretched(subview: canvasListView)

        // Parameter list setup

        let parameterListEditorView = ParameterListEditorView(frame: bottom.frame)
        parameterListEditorView.parameterList = component.parameters
        parameterListEditorView.onChange = { value in
            self.component.parameters = value
            self.caseList?.editor?.reloadData()
            self.render()
        }

        // Case list setup

        let caseList = CaseList(frame: bottom.frame)
        caseList.list = component.cases
        caseList.onChange = { value in
            self.component.cases = value
            self.render()
        }

        // Logic list setup

        let logicListView = LogicListView(frame: bottom.frame)
        logicListView.list = component.logic
        logicListView.onChange = { value in
            self.component.logic = value
            self.render()
        }

        self.logicListView = logicListView
        self.parameterListEditorView = parameterListEditorView
        self.caseList = caseList
        self.canvasListView = canvasListView
        self.metadataEditorView = metadataEditorView

        // Outline view setup

        setupLayerList()

        // Tab switching

        let tabMap: [String: NSView?] = [
            "Details": metadataEditorView,
            "Devices": canvasListView,
            "Parameters": parameterListEditorView,
            "Examples": caseList.editor,
            "Logic": logicListView.editor
        ]

        tabs.onChange = { value in
            for (tab, view) in tabMap {
                guard let view = view else { continue }

                if tab == value {
                    self.bottom.addSubviewStretched(subview: view)
                } else {
                    view.removeFromSuperview()
                }
            }

            switch value {
            case "Logic":
                logicListView.editor?.reloadData()
            default:
                break
            }
        }

        tabs.value = "Devices"

        // Init with data

        setComponent(component: component)
    }

    func setupLayerList() {
        let outlineView = LayerList(layerDelegate: self)
        outlineView.onChange = {[unowned self] in
            self.outlineView.render()
            self.render()
        }
        outlineView.expandItem(dataRoot)
        outlineView.reloadData()

        let scrollView = NSScrollView()
        scrollView.addSubview(outlineView)
        scrollView.backgroundColor = NSColor.parse(css: "rgb(240,240,240)")!
        scrollView.documentView = outlineView

        left.addSubviewStretched(subview: scrollView)
        self.outlineView = outlineView
    }

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            guard let targetLayer = selectedLayer else { return }
            if targetLayer === dataRoot { return }

            let parent = outlineView!.parent(forItem: targetLayer) as! CSLayer

            // Undo
            let oldChildren = parent.children
            let children = parent.children.filter({ $0 !== targetLayer })
            UndoManager.shared.run(name: "Delete", execute: {[unowned self] in
                self.updateChildren(children: children, for: parent)
            }, undo: {[unowned self] in
                self.updateChildren(children: oldChildren, for: parent)
            })
        } else if characters == String(Character(" ")) {
            canvasCollectionView?.panningEnabled = true
        }
    }

    private func updateChildren(children: [CSLayer], for parent: CSLayer) {

        // Change
        parent.children = children

        // Refresh
        refreshDocument(shouldClearInspector: true)
    }

    private func refreshDocument(shouldClearInspector: Bool = false) {
        if shouldClearInspector {
            clearInspector()
        }
        outlineView.render()
        render()
    }

    override func keyUp(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(" ")) {
            canvasCollectionView?.panningEnabled = false
        }
    }

    var inspectorContent: NSView?

    func renderInspector(item: DataNode) {
        clearInspector()
        guard let layer = item as? CSLayer else { return }

        let inspectorView: NSView
        if case CSLayer.LayerType.custom = layer.type, let layer = layer as? CSComponentLayer {
            let componentInspectorView = ComponentInspectorView(componentLayer: layer)
            componentInspectorView.onChangeData = {[unowned self] (data, parameter) in
                layer.parameters[parameter.name] = data

                self.outlineView.render()
                self.render()
                componentInspectorView.reload()
            }
            inspectorView = componentInspectorView
        } else {
            let layerInspector = LayerInspectorView(layer: layer)
            layerInspector.onChangeInspector = {[unowned self] changeType in
                switch changeType {
                case .canvas:
                    self.outlineView?.reloadItem(layer)
                    self.render()
                case .full:
                    self.outlineView.render(fullRender: true)
                    self.render()
                }
            }
            inspectorView = layerInspector
        }

        let scrollView = InspectorContentView(inspectorView: inspectorView)
        right.addSubviewStretched(subview: scrollView)

        // Keep a reference so we can remove it from its superview later
        self.inspectorContent = scrollView
    }
}

// MARK: - LayerListDelegate

extension ViewController: LayerListDelegate {

    func dataRootForLayerList() -> CSLayer {
        return dataRoot
    }

    func layerList(_ layerList: LayerList, do action: LayerListAction) {
        switch action {
        case .clearInspector:
            clearInspector()
        case .render:
            render()
        case .renderInspector(let node):
            renderInspector(item: node)
        }
    }
}
