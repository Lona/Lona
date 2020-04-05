//
//  ComponentEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/24/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import NavigationComponents
import Foundation

class ComponentEditorViewController: NSSplitViewController {
    private let splitViewRestorationIdentifier = "tech.lona.restorationId:componentEditorController"
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

    public var component: CSComponent? = nil { didSet { update(withoutModifyingSelection: false) } }
    public var showsAccessibilityOverlay: Bool = false { didSet { update(withoutModifyingSelection: true) } }
    public var selectedLayerName: String? = nil { didSet { update(withoutModifyingSelection: true) } }
    public var selectedCanvasHeaderItem: Int? {
        get { return canvasAreaView.selectedHeaderItem }
        set { canvasAreaView.selectedHeaderItem = newValue }
    }

    public var canvasPanningEnabled: Bool {
        get { return canvasAreaView.panningEnabled }
        set { canvasAreaView.panningEnabled = newValue }
    }

    public var utilitiesViewVisible: Bool {
        get { return bottomItem.isCollapsed }
        set { setBottomItemVisibility(to: newValue) }
    }

    public var onChangeUtilitiesViewVisible: ((Bool) -> Void)?

    public var onInspectLayer: ((CSLayer?) -> Void)?
    public var onChangeInspectedLayer: (() -> Void)?
    public var onChangeInspectedCanvas: ((Int) -> Void)?
    public var onDeleteCanvas: ((Int) -> Void)?
    public var onAddCanvas: (() -> Void)?
    public var onMoveCanvas: ((Int, Int) -> Void)?

    public func updateCanvas() {
        updateCanvasCollectionView()
    }

    public func reloadLayerListWithoutModifyingSelection() {
        update(withoutModifyingSelection: true)
    }

    public func addLayer(_ layer: CSLayer) {
        layerList.addLayer(layer: layer)
    }

    func zoomToActualSize() {
        canvasAreaView.zoom(to: 1)
    }

    func zoomIn() {
        canvasAreaView.zoomIn()
    }

    func zoomOut() {
        canvasAreaView.zoomOut()
    }

    // MARK: Private

    private lazy var utilitiesView = UtilitiesView()
    private lazy var utilitiesViewController: NSViewController = {
        return NSViewController(view: utilitiesView)
    }()

    private lazy var canvasAreaView = CanvasAreaView()
    private lazy var canvasAreaViewController: NSViewController = {
        return NSViewController(view: canvasAreaView)
    }()

    private lazy var layerList = LayerList()
    private lazy var layerListViewController: NSViewController = {
        return NSViewController(view: layerList)
    }()

    private lazy var layerEditorController: NSViewController = {
        let vc = NSSplitViewController(nibName: nil, bundle: nil)

        vc.splitView.isVertical = true
        vc.splitView.dividerStyle = .thin
        vc.splitView.autosaveName = layerEditorViewResorationIdentifier
        vc.splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: layerEditorViewResorationIdentifier)

        vc.minimumThicknessForInlineSidebars = 120

        let leftItem = NSSplitViewItem(contentListWithViewController: layerListViewController)
        leftItem.canCollapse = false
        //        leftItem.minimumThickness = 120
        vc.addSplitViewItem(leftItem)

        let mainItem = NSSplitViewItem(viewController: canvasAreaViewController)
        mainItem.minimumThickness = 300
        vc.addSplitViewItem(mainItem)

        return vc
    }()

    private lazy var bottomItem = NSSplitViewItem(viewController: utilitiesViewController)

    private func setUpViews() {
        setUpUtilities()

        layerList.fillColor = layerList.isDarkMode ? NSColor.controlBackgroundColor : .white

        layerList.onClickLayerTemplateType = { [unowned self] type in
            guard let component = self.component else { return }

            let newLayer = component.makeLayer(forType: type)
            self.layerList.addLayer(layer: newLayer)
        }

        canvasAreaView.onSelectCanvasHeaderItem = { [unowned self] index in
            self.onChangeInspectedCanvas?(index)
        }

        canvasAreaView.onDeleteCanvasHeaderItem = { [unowned self] index in
            self.onDeleteCanvas?(index)
        }

        canvasAreaView.onAddCanvas = { [unowned self] in
            self.onAddCanvas?()
        }

        canvasAreaView.onMoveCanvasHeaderItem = { [unowned self] index, newIndex in
            self.onMoveCanvas?(index, newIndex)
        }

        let tabItems = [
            NavigationItem(id: UUID(), title: UtilitiesView.Tab.parameters.rawValue, icon: nil),
            NavigationItem(id: UUID(), title: UtilitiesView.Tab.logic.rawValue, icon: nil),
            NavigationItem(id: UUID(), title: UtilitiesView.Tab.examples.rawValue, icon: nil),
            NavigationItem(id: UUID(), title: UtilitiesView.Tab.types.rawValue, icon: nil)
        ]

        let tabView = NavigationItemStack(items: tabItems, activeItem: tabItems[0].id)
        tabView.style = .tabs
        tabView.onClickItem = { id in
            guard let tabItem = tabItems.first(where: { $0.id == id }),
                let tab = UtilitiesView.Tab(rawValue: tabItem.title) else { return }
            self.utilitiesView.currentTab = tab
            tabView.activeItem = id
        }

        let splitView = DividerSplitView()
        splitView.dividerView = tabView

        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.autosaveName = splitViewRestorationIdentifier
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewRestorationIdentifier)

        self.splitView = splitView
    }

    func setUpUtilities() {
        utilitiesView.onChangeMetadata = { value in
            self.component?.metadata = value
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeParameterList = { value in
            self.component?.parameters = value
            self.utilitiesView.reloadData()
            self.updateCanvasCollectionView()

            // TODO: Revisit parameters of type "Component" at some point
//            let componentParameters = value.filter({ $0.type == CSComponentType })
//            let componentParameterNames = componentParameters.map({ $0.name })
//            ComponentMenu.shared?.update(componentParameterNames: componentParameterNames)
        }

        utilitiesView.onChangeCaseList = { value in
            self.component?.cases = value
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeLogicList = { value in
            self.component?.logic = value

            self.utilitiesView.reloadData()
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeTypes = { value in
            self.component?.types = value
            self.utilitiesView.types = value
        }
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let mainItem = NSSplitViewItem(viewController: layerEditorController)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        bottomItem.canCollapse = true
        bottomItem.minimumThickness = 100
        addSplitViewItem(bottomItem)
    }

    private func update(withoutModifyingSelection flag: Bool = false) {
        updateUtilitiesView()
        updateLayerList(withoutModifyingSelection: flag)
        updateCanvasCollectionView()
    }

    private func updateUtilitiesView() {
        utilitiesView.component = component
        utilitiesView.types = component?.types ?? []
    }

    private func updateLayerList(withoutModifyingSelection: Bool) {
        if withoutModifyingSelection {
            layerList.reloadWithoutModifyingSelection()
        } else {
            layerList.component = component
        }

        layerList.onSelectLayer = { layer in
            self.onInspectLayer?(layer)
        }

        layerList.onChange = {
            self.onChangeInspectedLayer?()
            self.update(withoutModifyingSelection: false)
        }
    }

    private func updateCanvasCollectionView() {
        guard let component = component else { return }

        // We need referential equality to be different
        let rootLayerCopy = component.rootLayer.copy() as! CSLayer

        let columns: [CanvasTableView.Column] = component.computedCanvases().map { canvas in
            CanvasTableView.Column(
                title: canvas.computedName,
                rows: component.computedCases(for: canvas).map { `case` in
                    let config = ComponentConfiguration(
                        component: component,
                        arguments: `case`.value.objectValue,
                        canvas: canvas
                    )

                    return CanvasView.Parameters(
                        canvas: canvas,
                        rootLayer: rootLayerCopy,
                        config: config,
                        options: RenderOptions([
                            .showsAccessibilityOverlay(showsAccessibilityOverlay),
                            .renderCanvasShadow(true),
                            .selectedLayerName(selectedLayerName)
                        ])
                    )
                }
            )
        }

        canvasAreaView.parameters = CanvasAreaView.Parameters(
            columns: columns,
            showsAccessibilityOverlay: showsAccessibilityOverlay,
//            onSelectLayer: { self.onInspectLayer?($0) },
            selectedLayerName: selectedLayerName)
    }

    // Collapsing with an animation doesn't work here currently, since we need to call
    // drawDivider to update the position of views within the divider, and this isn't
    // called during animation. If we draw a custom UI in drawDivider, rather than
    // using subviews within, we can add the animation back.
    private func setBottomItemVisibility(to visible: Bool) {
        if (visible && bottomItem.isCollapsed) || (!visible && !bottomItem.isCollapsed) {
            bottomItem.isCollapsed = !visible
            splitView.needsDisplay = true
        }
    }

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        self.onChangeUtilitiesViewVisible?(self.bottomItem.isCollapsed)
        splitView.needsDisplay = true
    }
}

extension NavigationItemStack.Style {
    public static var tabs: NavigationItemStack.Style = {
        var style = NavigationItemStack.Style.segmentedControl

        style.dividerPadding = 8

        return style
    }()

    public static var roundTabs: NavigationItemStack.Style = {
        let cornerRadius: CGFloat = 13
        let padding = NSEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

        var style = NavigationItemStack.Style.segmentedControl

        style.dividerPadding = 8

        style.itemStyle.backgroundColor = NSColor.textColor.withAlphaComponent(0.03)
        style.itemStyle.cornerRadius = cornerRadius
        style.itemStyle.padding = padding

        style.activeItemStyle.backgroundColor = NSColor.textColor.withAlphaComponent(0.08)
        style.activeItemStyle.cornerRadius = cornerRadius
        style.activeItemStyle.padding = padding

        return style
    }()
}
