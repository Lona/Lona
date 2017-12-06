//
//  ViewController.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa
import MASPreferences

class ViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    static let CHECKBOX_TAG = 20
    
    @IBOutlet weak var bottom: NSView!
    @IBOutlet weak var left: NSView!
    @IBOutlet weak var drawingSurface: NSView!
    @IBOutlet weak var right: NSView!
    @IBOutlet weak var verticalSplitter: SectionSplitter!
    
    var selectedLayer: CSLayer? {
        return outlineView!.item(atRow: outlineView!.selectedRow) as! CSLayer?
    }
    
    var selectedLayerOrRoot: CSLayer {
        return selectedLayer ?? dataRoot
    }
    
    func addLayer(layer newLayer: CSLayer) {
        let targetLayer = selectedLayerOrRoot
        
        if targetLayer === dataRoot {
            targetLayer.appendChild(newLayer)
        } else {
            let parent = outlineView!.parent(forItem: targetLayer) as! CSLayer
            let index = outlineView!.childIndex(forItem: targetLayer)
            parent.insertChild(newLayer, at: index + 1)
        }
        
        renderLayerList()
        
        let newLayerIndex = outlineView!.row(forItem: newLayer)
        let selection: IndexSet = [newLayerIndex]
        
//        outlineView!.editColumn(0, row: newLayerIndex, with: nil, select: true)
        
        outlineView!.selectRowIndexes(selection, byExtendingSelection: false)
        
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
    
    var preferencesWindow: MASPreferencesWindowController? = nil
    
    @IBAction func showPreferences(_ sender: AnyObject) {
        let workspace = WorkspacePreferencesViewController()
        workspace.viewDidLoad()
        
        let controllers = [workspace]
        
        let preferencesWindow = MASPreferencesWindowController(viewControllers: controllers, title: "Preferences")
        preferencesWindow!.showWindow(sender)
        
        self.preferencesWindow = preferencesWindow
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        CSUserTypes.reload()
        CSColors.reload()
        CSTypography.reload()
        CSGradients.reload()
        CSShadows.reload()
        
        component.layers
            .filter({ $0 is CSComponentLayer })
            .forEach({ layer in
                let layer = layer as! CSComponentLayer
                layer.reload()
            })
        
        renderLayerList()
        render()
    }
    
    @IBAction func addComponent(_ sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .component file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["component"];
        
        if dialog.runModal() == NSModalResponseOK {
            let result = dialog.url
            
            if result != nil {
                let newLayer = outlineView!.createComponentLayer(from: result!)
                
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
        let newLayer = CSLayer(name: "Children", type: "Children", parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])
        
        addLayer(layer: newLayer)
    }
    
    @IBAction func addImage(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Image")
        
        let newLayer = CSLayer(name: name, type: "Image", parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])
        
        addLayer(layer: newLayer)
    }
    
    @IBAction func addAnimation(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Animation")
        
        let newLayer = CSLayer(name: name, type: "Animation", parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])
        
        addLayer(layer: newLayer)
    }
    
    @IBAction func addView(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "View")
        
        let newLayer = CSLayer(name: name, type: "View", parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])
        
        addLayer(layer: newLayer)
    }
    
    @IBAction func addText(_ sender: AnyObject) {
        let name = component.getNewLayerName(startingWith: "Text")

        let newLayer = CSLayer(name: name, type: "Text", parameters: [
            "text": "Text goes here".toData(),
            "widthSizingRule": "Shrink".toData(),
            "heightSizingRule": "Shrink".toData(),
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
        
        if dialog.runModal() == NSModalResponseOK {
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
        
        return dialog.runModal() == NSModalResponseOK ? dialog.url : nil
    }
    
    @IBAction func exportToAnimation(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }
        
        RenderSurface.renderToAnimations(component: component, directory: url)
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
                outputFile.path,
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
    
    var component: CSComponent = CSComponent(
        name: "Component",
        canvas: [
            Canvas(visible: true, name: "iPhone SE", width: 320, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white"),
            Canvas(visible: true, name: "iPhone 7", width: 375, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white"),
            Canvas(visible: true, name: "iPhone 7+", width: 414, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white"),
        ],
        rootLayer: CSLayer(name: "View", type: "View", parameters: [
            "alignSelf": "stretch".toData(),
            "flex": 0.toData(),
        ]),
        parameters: [],
        cases: [CSCase.defaultCase],
        logic: [],
        config: CSData.Object([:]),
        metadata: CSData.Object([:])
    )
    
    var dataRoot: CSLayer { return component.rootLayer }
    
    var outlineView: LayerList? = nil
    var renderSurface: RenderSurface? = nil
    var canvasCollectionView: CanvasCollectionView? = nil
    
    func render() {
        logicListView?.editor?.reloadData()
        
        let selectLayer: (CSLayer) -> Void = { layer in
            var topLevelLayer: CSLayer? = layer
            while let parent = topLevelLayer?.config?.parentComponentLayer {
                topLevelLayer = parent
            }
            
            self.outlineView!.select(item: topLevelLayer!)
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
    
    func renderLayerList(fullRender: Bool = false) {
        let selection = outlineView!.selectedRow
        
        // Editing during a reload can cause a crash
        outlineView!.stopEditing()
        
        outlineView!.reloadData()
        
        // TODO Is this what we want here? Won't this get rid of all expand/collapse
        outlineView!.expandItem(dataRoot, expandChildren: true)
        
        if fullRender {
            outlineView!.select(row: selection)
        } else {
            makeChangeWithoutRendering {
                // Currently rendering resets the selection, so we set it again manually
                outlineView!.select(row: selection)
            }
        }
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
        
        renderLayerList()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        right.addBorderView(to: .left)
        right.backgroundFill = #colorLiteral(red: 0.9486700892, green: 0.9493889213, blue: 0.9487814307, alpha: 1).cgColor
        
        // Splitter setup
        
        let tabs = SegmentedControlField(frame: NSRect(x: 0, y: 0, width: 500, height: 24), values: ["Details", "Canvases", "Parameters", "Logic", "Cases"])
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
        
        let scrollView = NSScrollView()

        let outlineView = createOutlineView()
        scrollView.addSubview(outlineView)
        scrollView.backgroundColor = NSColor.parse(css: "rgb(240,240,240)")!
        scrollView.documentView = outlineView
        
        left.addSubviewStretched(subview: scrollView)
        
        // Tab switching
        
        let tabMap: [String: NSView?] = [
            "Details": metadataEditorView,
            "Canvases": canvasListView,
            "Parameters": parameterListEditorView,
            "Cases": caseList.editor,
            "Logic": logicListView.editor,
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
        
        tabs.value = "Canvases"
        
        // Init with data
        
        setComponent(component: component)
    }
    
    func createOutlineView() -> NSOutlineView {
        let column = NSTableColumn(identifier: "layer")
        column.resizingMask = .autoresizingMask
        let visibleColumn = NSTableColumn(identifier: "visible")
        visibleColumn.maxWidth = 20
        
        column.title = "Song title"
        
        let outlineView = LayerList()
        outlineView.onChange = {_ in
            self.renderLayerList()
            self.render()
        }
        
        outlineView.backgroundColor = NSColor.clear
        outlineView.wantsLayer = true
        outlineView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        
        self.outlineView = outlineView
        
        outlineView.addTableColumn(column)
        outlineView.addTableColumn(visibleColumn)
        outlineView.outlineTableColumn = column
        
        outlineView.rowSizeStyle = NSTableViewRowSizeStyle.small
        
        outlineView.dataSource = self
        outlineView.delegate = self
        
        outlineView.reloadData()
        outlineView.expandItem(dataRoot)
        
        outlineView.focusRingType = .none
//        outlineView.usesAlternatingRowBackgroundColors = true
        outlineView.intercellSpacing = NSSize(width: 10, height: 10)
        
        outlineView.register(forDraggedTypes: ["component.layer"])
        
        outlineView.headerView = nil
        
        outlineView.doubleAction = #selector(doubleClick(sender:))
        
        return outlineView
    }
    
    func doubleClick(sender: AnyObject) {
        outlineView!.editColumn(outlineView!.clickedColumn, row: outlineView!.clickedRow, with: nil, select: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!
        
        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            guard let targetLayer = selectedLayer else { return }
            
            if targetLayer === dataRoot { return }
            
            let parent = outlineView!.parent(forItem: targetLayer) as! CSLayer
            parent.children = parent.children.filter({ $0 !== targetLayer })
            
            clearInspector()
            renderLayerList()
            render()
        } else if characters == String(Character(" ")) {
            canvasCollectionView?.panningEnabled = true
        }
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
        
        if layer.type == "Component", let layer = layer as? CSComponentLayer {
            let views: [(view: NSView, keyView: NSView)] = layer.component.parameters.map({ parameter in
                let data = layer.parameters[parameter.name] ?? CSData.Null
                let value = CSValue(type: parameter.type, data: data)
                var usesYogaLayout = true
                if case .named("URL", .string) = value.type {
                    usesYogaLayout = false
                }
                
                let valueField = CSValueField(value: value, options: [
                    CSValueField.Options.isBordered: true,
                    CSValueField.Options.drawsBackground: true,
//                    CSValueField.Options.submitOnChange: true,
                    CSValueField.Options.submitOnChange: false,
                    CSValueField.Options.usesLinkStyle: false,
                    CSValueField.Options.usesYogaLayout: usesYogaLayout,
                ])
                
                valueField.onChangeData = { data in
                    // Handle the empty strings specially - convert to null.
                    // TODO: How can we always allow a null state?
                    if let value = data.string, value == "" {
                        layer.parameters[parameter.name] = CSData.Null
                    } else {
                        layer.parameters[parameter.name] = data
                    }
                    
                    self.renderLayerList()
                    self.render()
                }
                
                valueField.view.translatesAutoresizingMaskIntoConstraints = false
                
                let stackView = NSStackView(views: [
                    NSTextField(labelWithStringCompat: parameter.name),
                ], orientation: .vertical)
                stackView.alignment = .left
                
                stackView.addArrangedSubview(valueField.view, stretched: !(valueField.view is CheckboxField))
                
                return (view: stackView, keyView: valueField.view)
            })
            
            for (index, view) in views.enumerated() {
                if (index == views.count - 1) { continue }
                
                view.keyView.nextKeyView = views[index + 1].keyView
            }
            
            let parametersSection = DisclosureContentRow(title: "Parameters", views: views.map({ $0.view }), stretched: true)
            parametersSection.contentSpacing = 8
            parametersSection.contentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
            
            inspectorView = NSStackView(views: [parametersSection], orientation: .vertical, stretched: true)
            inspectorView.translatesAutoresizingMaskIntoConstraints = false
        } else {
            let layerInspector = LayerInspectorView(frame: NSRect.zero, layer: layer)
            
            layerInspector.onChangeInspector = { changeType in
                switch changeType {
                case .canvas:
                    self.outlineView?.reloadItem(layer)
                    self.render()
                case .full:
                    self.renderLayerList(fullRender: true)
                    self.render()
                }
            }
            
            inspectorView = layerInspector
        }
        
        // Flip the content within the scrollview so it starts at the top
        let flippedView = FlippedView()
        flippedView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.addSubview(inspectorView)
        
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(flippedView)
        scrollView.documentView = flippedView
        scrollView.hasVerticalRuler = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = EdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        right.addSubviewStretched(subview: scrollView)
        
        inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
        inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true
        
        flippedView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
        flippedView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20).isActive = true
        
        // Keep a reference so we can remove it from its superview later
        self.inspectorContent = scrollView
    }
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        
        let pp = NSPasteboardItem()
        
        // working as expected here
        if let _ = item as? DataNode {
            let index = outlineView.row(forItem: item)
            
            pp.setString(String(index), forType: "component.layer")
            
//            print( "pb write \(fi.label)")
            
        } else {
//            print( "pb write, not a file item \(item)")
        }
        
        return pp
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        let sourceIndexString = info.draggingPasteboard().string(forType: "component.layer")
        
        if sourceIndexString != nil, let sourceIndex = Int(sourceIndexString!), let targetLayer = item as? CSLayer? {
            
            // Can't drop before or after the root view
            if targetLayer == nil { return NSDragOperation() }
            
            // Can't move the root
            if sourceIndex == 0 { return NSDragOperation() }
            
            let sourceLayer = outlineView.item(atRow: sourceIndex) as! CSLayer
            
            // Don't allow an item to be dragged into itself
            if targetLayer === sourceLayer { return NSDragOperation() }
            
            // Don't allow an item to be dragged into its own subtree
            var parent = outlineView.parent(forItem: item) as! CSLayer?
            while parent != nil {
                if parent === sourceLayer { return NSDragOperation() }
                
                parent = outlineView.parent(forItem: parent) as! CSLayer?
            }
        }
        
        return NSDragOperation.move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let sourceIndexString = info.draggingPasteboard().string(forType: "component.layer")
        
        if sourceIndexString != nil, let sourceIndex = Int(sourceIndexString!) {
//            print( "accept drop", item, "index", index, "drag index", sourceIndex)

            let sourceLayer = outlineView.item(atRow: sourceIndex) as! CSLayer
            
            let oldIndexWithinParent = sourceLayer.removeFromParent()
            
            let targetLayer = item as! CSLayer
            
            // Index is -1 when item is dropped directly on another item, rather than above or below
            if index == -1 {
                targetLayer.appendChild(sourceLayer)
            } else {
                if sourceLayer.parent === targetLayer && oldIndexWithinParent >= 0 && oldIndexWithinParent < index {
                    targetLayer.insertChild(sourceLayer, at: index - 1)
                } else {
                    targetLayer.insertChild(sourceLayer, at: index)
                }
            }
            
            renderLayerList()
            render()
            
            return true
        }
        
        return false
    }
    
    var previousRow: Int? = nil
    
    var shouldRenderOnSelectionChange = true
    
    func makeChangeWithoutRendering(f: () -> ()) {
        shouldRenderOnSelectionChange = false
        f()
        shouldRenderOnSelectionChange = true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let selectedRow = outlineView?.selectedRow {
            if previousRow != nil && previousRow! >= 0 && previousRow! < outlineView!.numberOfRows {
                let view = outlineView?.view(atColumn: 1, row: previousRow!, makeIfNecessary: true)
                let checkbox = view?.viewWithTag(ViewController.CHECKBOX_TAG)
                if checkbox != nil && !(checkbox!.isHidden) {
                    checkbox?.isHidden = true
                }
            }
            
            if selectedRow == -1 {
                clearInspector()
            } else {
                let item = outlineView?.item(atRow: selectedRow) as! DataNode!
                
                // Don't allow hiding the root layer
                if selectedRow != 0 {
                    let view = outlineView?.view(atColumn: 1, row: selectedRow, makeIfNecessary: true)
                    let checkbox = view?.viewWithTag(ViewController.CHECKBOX_TAG)
                    if checkbox != nil && checkbox!.isHidden {
                        checkbox?.isHidden = false
                    }
                }
                
                if (shouldRenderOnSelectionChange) {
                    renderInspector(item: item!)
                }
            }
            previousRow = selectedRow
            
            if (shouldRenderOnSelectionChange) {
                render()
            }
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        selectedLayer?.name = (obj.object as! NSTextField).stringValue
        
        renderLayerList()
        render()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else {
            let node = item as! DataNode?
            return node!.childCount()
        }
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {

        if item == nil {
            return dataRoot
        } else {
            let node = item as! DataNode
            return node.child(at: index)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 18
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = NSTableCellView()
        
        switch tableColumn!.identifier {
        case "layer":
            if let layer = item as? CSLayer {
                let textField = NSTextField()
                
                textField.isEditable = true
                textField.delegate = self
                textField.isBordered = false
                textField.drawsBackground = false
                textField.stringValue = layer.name
                
                if layer.type == "Component" {
                    textField.textColor = NSColor.parse(css: "rgb(101,53,160)")!
                }
                
                cellView.textField = textField
                cellView.addSubview(textField)
                
                if #available(OSX 10.12, *) {
                    if let image = LayerThumbnail.image(for: layer) {
                        let imageView = NSImageView(image: image)
                        cellView.imageView = imageView
                        cellView.addSubview(imageView)
                    }
                }
            }
        case "visible":
            if let layer = item as? CSLayer {
                let checkbox = CheckboxField(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
                checkbox.value = layer.visible
                checkbox.onChange = { value in
                    layer.visible = value
                    self.render()
                }
                cellView.addSubview(checkbox)
                checkbox.tag = ViewController.CHECKBOX_TAG
                checkbox.isHidden = true
            }
        default:
            break
        }
        
        return cellView
    }
}

