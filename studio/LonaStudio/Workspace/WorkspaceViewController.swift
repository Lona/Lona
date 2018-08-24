//
//  WorkspaceViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import FileTree
import Foundation

private func getDirectory() -> URL? {
    let dialog = NSOpenPanel()

    dialog.title                   = "Choose export directory"
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canCreateDirectories    = true
    dialog.canChooseDirectories    = true
    dialog.canChooseFiles          = false

    return dialog.runModal() == NSApplication.ModalResponse.OK ? dialog.url : nil
}

private func requestSketchFileSaveURL() -> URL? {
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

class ColorVC: NSViewController {

    private let backgroundColor: NSColor

    init(backgroundColor: NSColor) {
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = backgroundColor.cgColor
    }
}

class ComponentEditorViewController: NSSplitViewController {
    private let splitViewResorationIdentifier = "tech.lona.restorationId:componentEditorController"
    private let layerEditorViewResorationIdentifier = "tech.lona.restorationId:layerEditorController"

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUpViews()
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Public

    public var component: CSComponent? = nil { didSet { update() } }
    public var canvasPanningEnabled: Bool {
        get { return canvasCollectionView.panningEnabled }
        set { canvasCollectionView.panningEnabled = newValue }
    }

    public func addLayer(_ layer: CSLayer) {
        layerList.addLayer(layer: layer)
    }

    func zoomToActualSize() {
        canvasCollectionView.zoom(to: 1)
    }

    func zoomIn() {
        canvasCollectionView.zoomIn()
    }

    func zoomOut() {
        canvasCollectionView.zoomOut()
    }

    // MARK: Private

    private lazy var utilitiesView = UtilitiesView()
    private lazy var utilitiesViewController: NSViewController = {
        return NSViewController(view: utilitiesView)
    }()

    private lazy var canvasCollectionView = CanvasCollectionView(frame: .zero)
    private lazy var canvasCollectionViewController: NSViewController = {
        return NSViewController(view: canvasCollectionView)
    }()

    private lazy var layerList = LayerList()
    private lazy var layerListViewController: NSViewController = {
        return NSViewController(view: layerList)
    }()

    private lazy var layerEditorController: NSViewController = {
        let vc = NSSplitViewController(nibName: nil, bundle: nil)

        vc.splitView.isVertical = true
        vc.splitView.dividerStyle = .thin
        vc.splitView.autosaveName = NSSplitView.AutosaveName(rawValue: layerEditorViewResorationIdentifier)
        vc.splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: layerEditorViewResorationIdentifier)

        vc.minimumThicknessForInlineSidebars = 120

        let leftItem = NSSplitViewItem(contentListWithViewController: layerListViewController)
        leftItem.canCollapse = false
//        leftItem.minimumThickness = 120
        vc.addSplitViewItem(leftItem)

        let mainItem = NSSplitViewItem(viewController: canvasCollectionViewController)
        mainItem.minimumThickness = 300
        vc.addSplitViewItem(mainItem)

        return vc
    }()

    private func setUpViews() {
        setUpUtilities()

        layerList.fillColor = .white

        let tabs = SegmentedControlField(
            frame: NSRect(x: 0, y: 0, width: 500, height: 24),
            values: [
                UtilitiesView.Tab.devices.rawValue,
                UtilitiesView.Tab.parameters.rawValue,
                UtilitiesView.Tab.logic.rawValue,
                UtilitiesView.Tab.examples.rawValue,
                UtilitiesView.Tab.details.rawValue
            ])
        tabs.segmentWidth = 97
        tabs.useYogaLayout = true
        tabs.segmentStyle = .roundRect
        tabs.onChange = { value in
            guard let tab = UtilitiesView.Tab(rawValue: value) else { return }
            self.utilitiesView.currentTab = tab
        }
        tabs.value = UtilitiesView.Tab.devices.rawValue

        let splitView = SectionSplitter()
        splitView.addSubviewToDivider(tabs)

        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.autosaveName = NSSplitView.AutosaveName(rawValue: splitViewResorationIdentifier)
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)

        self.splitView = splitView
    }

    func setUpUtilities() {
        utilitiesView.onChangeMetadata = { value in
            self.component?.metadata = value
        }

        utilitiesView.onChangeCanvasList = { value in
            self.component?.canvas = value
        }

        utilitiesView.onChangeCanvasLayout = { value in
            self.component?.canvasLayoutAxis = value
        }

        utilitiesView.onChangeParameterList = { value in
            self.component?.parameters = value
            self.utilitiesView.reloadData()

            let componentParameters = value.filter({ $0.type == CSComponentType })
            let componentParameterNames = componentParameters.map({ $0.name })
            ComponentMenu.shared?.update(componentParameterNames: componentParameterNames)
        }

        utilitiesView.onChangeCaseList = { value in
            self.component?.cases = value
        }

        utilitiesView.onChangeLogicList = { value in
            self.component?.logic = value
        }
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let mainItem = NSSplitViewItem(viewController: layerEditorController)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        let bottomItem = NSSplitViewItem(viewController: utilitiesViewController)
        bottomItem.canCollapse = false
        bottomItem.minimumThickness = 120
        addSplitViewItem(bottomItem)
    }

    private func update() {
        utilitiesView.component = component
        layerList.component = component

        guard let component = component else { return }

        let options = CanvasCollectionOptions(
            layout: component.canvasLayoutAxis,
            component: component,
            selected: nil,
            onSelectLayer: { _ in }
        )

        canvasCollectionView.update(options: options)
    }
}

class WorkspaceViewController: NSSplitViewController {
    private let splitViewResorationIdentifier = "tech.lona.restorationId:workspaceViewController2"

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUpViews()
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
        setUpLayout()
    }

    // MARK: Public

    public var component: CSComponent? { didSet { update() } }
    public var fileURL: URL?

    // Called from the ComponentMenu
    public func addLayer(_ layer: CSLayer) {
        componentEditorViewController.addLayer(layer)
    }

    // MARK: Private

    private var selectedLayer: CSLayer?

    private lazy var fileTree: FileTree = {
        return FileTree(rootPath: LonaModule.current.url.path)
    }()
    private lazy var fileTreeViewController: NSViewController = {
        return NSViewController(view: fileTree)
    }()

    private lazy var componentEditorViewController = ComponentEditorViewController()

    private lazy var inspectorView = InspectorContentView()
    private lazy var inspectorViewController: NSViewController = {
        return NSViewController(view: inspectorView)
    }()

    private func setUpViews() {
        splitView.dividerStyle = .thin
        splitView.autosaveName = NSSplitView.AutosaveName(rawValue: splitViewResorationIdentifier)
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)

//        fileTree.defaultThumbnailSize = NSSize(width: 40, height: 24)
        fileTree.defaultFont = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
//        fileTree.defaultRowHeight = 44
        fileTree.displayNameForFile = { path in
            let url = URL(fileURLWithPath: path)
            return url.pathExtension == "component" ? url.deletingPathExtension().lastPathComponent : url.lastPathComponent
        }

        fileTree.imageForFile = { path, size in
            let url = URL(fileURLWithPath: path)

            func defaultImage(for path: String) -> NSImage {
                let image = NSWorkspace.shared.icon(forFile: path)
//                image.size = NSSize(width: size.width, height: size.height)
                return image
            }

            if url.pathExtension == "component" {
                guard let component = LonaModule.current.component(named: url.deletingPathExtension().lastPathComponent),
                    let canvas = component.computedCanvases().first,
                    let caseItem = component.computedCases(for: canvas).first
                    else { return defaultImage(for: path) }

                let config = ComponentConfiguration(
                    component: component,
                    arguments: caseItem.value.objectValue,
                    canvas: canvas
                )

                let canvasView = CanvasView(
                    canvas: canvas,
                    rootLayer: component.rootLayer,
                    config: config,
                    options: [RenderOption.assetScale(1)]
                )

                guard let data = canvasView.dataRepresentation(scaledBy: 0.25),
                    let image = NSImage(data: data)
                    else { return defaultImage(for: path) }
                image.size = NSSize(width: size.width, height: (image.size.height / image.size.width) * size.height)
                return image
            } else {
                return defaultImage(for: path)
            }
        }
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let contentListItem = NSSplitViewItem(contentListWithViewController: fileTreeViewController)
//        let contentListItem = NSSplitViewItem(contentListWithViewController: layerListViewController)
        //        contentListItem.canCollapse = true
//        contentListItem.minimumThickness = 140
        addSplitViewItem(contentListItem)

        let mainItem = NSSplitViewItem(viewController: componentEditorViewController)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        let sidebarItem = NSSplitViewItem(viewController: inspectorViewController)
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 280
        sidebarItem.maximumThickness = 280
        addSplitViewItem(sidebarItem)
    }

    private func update() {
        componentEditorViewController.component = component
        inspectorView.content = selectedLayer

//        layerList.onSelectLayer = { layer in
//            self.selectedLayer = layer
//            self.inspectorView.content = layer
//        }
//
//        layerList.onChange = {
//            self.componentEditorViewController.component = self.component
//            self.inspectorView.content = self.selectedLayer
//        }

        inspectorView.onChangeContent = { layer, changeType in
            self.componentEditorViewController.component = self.component
//            self.layerList.reloadWithoutModifyingSelection()
        }
    }

    // Subscriptions

    var subscriptions: [() -> Void] = []

    override func viewWillAppear() {
        subscriptions.append(LonaPlugins.current.register(eventType: .onReloadWorkspace) {
            self.component?.layers
                .filter({ $0 is CSComponentLayer })
                .forEach({ layer in
                    let layer = layer as! CSComponentLayer
                    layer.reload()
                })

            self.update()
        })
    }

    override func viewWillDisappear() {
        subscriptions.forEach({ sub in sub() })
    }

    // Key handling

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(" ")) {
            componentEditorViewController.canvasPanningEnabled = true
        }

        super.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(" ")) {
            componentEditorViewController.canvasPanningEnabled = false
        }

        super.keyUp(with: event)
    }
}

// MARK: - IBActions

extension WorkspaceViewController {
    @IBAction func zoomToActualSize(_ sender: AnyObject) {
        componentEditorViewController.zoomToActualSize()
    }

    @IBAction func zoomIn(_ sender: AnyObject) {
        componentEditorViewController.zoomIn()
    }

    @IBAction func zoomOut(_ sender: AnyObject) {
        componentEditorViewController.zoomOut()
    }

    @IBAction func exportToAnimation(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        RenderSurface.renderToAnimations(component: component, directory: url)
    }

    @IBAction func exportCurrentModuleToImages(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        RenderSurface.renderCurrentModuleToImages(savedTo: url)
    }

    @IBAction func exportToImages(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        RenderSurface.renderToImages(component: component, directory: url)
    }

    @IBAction func exportToVideo(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        RenderSurface.renderToVideos(component: component, directory: url)
    }

    @IBAction func exportToSketch(_ sender: AnyObject) {
        guard let component = component, let outputFile = requestSketchFileSaveURL() else { return }

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

    @IBAction func addComponent(_ sender: AnyObject) {
        guard let component = component else { return }

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

                componentEditorViewController.addLayer(newLayer)
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

        componentEditorViewController.addLayer(newLayer)
    }

    @IBAction func addImage(_ sender: AnyObject) {
        guard let component = component else { return }

        let name = component.getNewLayerName(startingWith: "Image")

        let newLayer = CSLayer(name: name, type: .image, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        componentEditorViewController.addLayer(newLayer)
    }

    @IBAction func addAnimation(_ sender: AnyObject) {
        guard let component = component else { return }

        let name = component.getNewLayerName(startingWith: "Animation")

        let newLayer = CSLayer(name: name, type: .animation, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        componentEditorViewController.addLayer(newLayer)
    }

    @IBAction func addView(_ sender: AnyObject) {
        guard let component = component else { return }

        let name = component.getNewLayerName(startingWith: "View")

        let newLayer = CSLayer(name: name, type: .view, parameters: [
            "width": 100.toData(),
            "height": 100.toData(),
            "backgroundColor": "#D8D8D8".toData()
        ])

        componentEditorViewController.addLayer(newLayer)
    }

    @IBAction func addText(_ sender: AnyObject) {
        guard let component = component else { return }

        let name = component.getNewLayerName(startingWith: "Text")

        let newLayer = CSLayer(name: name, type: .text, parameters: [
            "text": "Text goes here".toData(),
            "widthSizingRule": "Shrink".toData(),
            "heightSizingRule": "Shrink".toData()
        ])

        componentEditorViewController.addLayer(newLayer)
    }

}
