//
//  WorkspaceViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

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

    // MARK: Private

    private lazy var utilitiesView = UtilitiesView()
    private lazy var utilitiesViewController: NSViewController = {
        return ViewController(view: utilitiesView)
    }()

    private lazy var canvasCollectionView = CanvasCollectionView(frame: .zero)
    private lazy var canvasCollectionViewController: NSViewController = {
        return ViewController(view: canvasCollectionView)
    }()

    private func setUpViews() {
        setUpUtilities()

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
            self.render()
        }

        utilitiesView.onChangeCanvasList = { value in
            self.component?.canvas = value
            self.render()
        }

        utilitiesView.onChangeCanvasLayout = { value in
            self.component?.canvasLayoutAxis = value
            self.render()
        }

        utilitiesView.onChangeParameterList = { value in
            self.component?.parameters = value
            self.utilitiesView.reloadData()
            self.render()

            let componentParameters = value.filter({ $0.type == CSComponentType })
            let componentParameterNames = componentParameters.map({ $0.name })
            ComponentMenu.shared?.update(componentParameterNames: componentParameterNames)
        }

        utilitiesView.onChangeCaseList = { value in
            self.component?.cases = value
            self.render()
        }

        utilitiesView.onChangeLogicList = { value in
            self.component?.logic = value
            self.render()
        }
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let mainItem = NSSplitViewItem(viewController: canvasCollectionViewController)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        let bottomItem = NSSplitViewItem(viewController: utilitiesViewController)
        bottomItem.canCollapse = false
        bottomItem.minimumThickness = 120
        addSplitViewItem(bottomItem)
    }

    private func update() {
        utilitiesView.component = component

        guard let component = component else { return }

        let options = CanvasCollectionOptions(
            layout: component.canvasLayoutAxis,
            component: component,
            selected: nil,
            onSelectLayer: { _ in }
        )

        canvasCollectionView.update(options: options)
    }

    private func render() {
        // XXX
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
    }

    // MARK: Public

    public var component: CSComponent? = nil { didSet { update() } }
    public var selectedLayer: CSLayer? = nil { didSet { update() } }

    // MARK: Private

    private lazy var layerList = LayerList()
    private lazy var layerListViewController: NSViewController = {
        return ViewController(view: layerList)
    }()

    private lazy var componentEditorViewController = ComponentEditorViewController()

    private lazy var inspectorView = InspectorContentView()
    private lazy var inspectorViewController: NSViewController = {
        return ViewController(view: inspectorView)
    }()

    private func setUpViews() {
        splitView.dividerStyle = .thin
        splitView.autosaveName = NSSplitView.AutosaveName(rawValue: splitViewResorationIdentifier)
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let contentListItem = NSSplitViewItem(contentListWithViewController: layerListViewController)
        //        contentListItem.canCollapse = true
        contentListItem.minimumThickness = 140
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
        layerList.component = component
        componentEditorViewController.component = component
        inspectorView.content = nil

        layerList.onSelectLayer = { layer in
            self.inspectorView.content = layer
        }
    }

    // Subscriptions

    var subscriptions: [() -> Void] = []

    override func viewWillAppear() {
        subscriptions.append( LonaPlugins.current.register(eventType: .onReloadWorkspace) {
            self.component?.layers
                .filter({ $0 is CSComponentLayer })
                .forEach({ layer in
                    let layer = layer as! CSComponentLayer
                    layer.reload()
                })
//            layerList.render()
//            render()
        })
    }

    override func viewWillDisappear() {
        subscriptions.forEach({ sub in sub() })
    }
}
