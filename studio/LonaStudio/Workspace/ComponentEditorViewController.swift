//
//  ComponentEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/24/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

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

    public var component: CSComponent? = nil { didSet { update(withoutModifyingSelection: false) } }
    public var selectedLayerName: String? = nil { didSet { update(withoutModifyingSelection: true) } }

    public var canvasPanningEnabled: Bool {
        get { return canvasAreaView.panningEnabled }
        set { canvasAreaView.panningEnabled = newValue }
    }

    public var onInspectLayer: ((CSLayer?) -> Void)?
    public var onChangeInspectedLayer: (() -> Void)?

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
        vc.splitView.autosaveName = NSSplitView.AutosaveName(rawValue: layerEditorViewResorationIdentifier)
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
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeCanvasList = { value in
            self.component?.canvas = value
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeCanvasLayout = { value in
            self.component?.canvasLayoutAxis = value
            self.updateLayerList(withoutModifyingSelection: true)
            self.updateCanvasCollectionView()
        }

        utilitiesView.onChangeParameterList = { value in
            self.component?.parameters = value
            self.utilitiesView.reloadData()

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
    }

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        let mainItem = NSSplitViewItem(viewController: layerEditorController)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        let bottomItem = NSSplitViewItem(viewController: utilitiesViewController)
        bottomItem.canCollapse = false
        bottomItem.minimumThickness = 0
        addSplitViewItem(bottomItem)
    }

    private func update(withoutModifyingSelection flag: Bool = false) {
        updateUtilitiesView()
        updateLayerList(withoutModifyingSelection: flag)
        updateCanvasCollectionView()
    }

    private func updateUtilitiesView() {
        utilitiesView.component = component
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

        canvasAreaView.parameters = CanvasAreaView.Parameters(
            component: component,
            onSelectLayer: { self.onInspectLayer?($0) },
            selectedLayerName: selectedLayerName)
    }
}
