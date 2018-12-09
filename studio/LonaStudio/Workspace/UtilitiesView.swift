//
//  UtilitiesView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class UtilitiesView: NSBox {

    enum Tab: String {
        case details = "Details"
        case devices = "Devices"
        case parameters = "Parameters"
        case examples = "Examples"
        case logic = "Logic"
    }

    // MARK: Lifecycle

    public init(currentTab: Tab = .devices) {
        self.currentTab = currentTab

        super.init(frame: .zero)

        self.tabMap = [
            .details: metadataEditorView,
            .devices: canvasListView,
            .parameters: parameterListEditorView,
            .examples: caseListView.editor,
            .logic: logicListView.editor
        ]

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var currentTab: Tab {
        didSet {
            if oldValue != currentTab {
                update()
            }
        }
    }

    public var onChangeParameterList: (([CSParameter]) -> Void) {
        get { return parameterListEditorView.onChange }
        set { parameterListEditorView.onChange = newValue }
    }

    public var onChangeLogicList: (([LogicNode]) -> Void) {
        get { return logicListView.onChange }
        set { logicListView.onChange = newValue }
    }

    public var onChangeCaseList: (([CSCase]) -> Void) {
        get { return caseListView.onChange }
        set { caseListView.onChange = newValue }
    }

    public var metadata: CSData {
        get { return metadataEditorView.data }
        set { metadataEditorView.data = newValue }
    }

    public var onChangeMetadata: ((CSData) -> Void) {
        get { return metadataEditorView.onChangeData }
        set { metadataEditorView.onChangeData = newValue }
    }

    public var canvasLayout: StaticCanvasRenderer.Layout {
        get { return canvasListView.canvasLayout }
        set { canvasListView.canvasLayout = newValue }
    }

    public var onChangeCanvasList: (([Canvas]) -> Void) {
        get { return canvasListView.onChange }
        set { canvasListView.onChange = newValue }
    }

    public var onChangeCanvasLayout: ((StaticCanvasRenderer.Layout) -> Void) {
        get { return canvasListView.onChangeLayout ?? { _ in } }
        set { canvasListView.onChangeLayout = newValue }
    }

    public var component: CSComponent? {
        didSet {
            update()
        }
    }

    public func reloadData() {
        logicListView.editor?.reloadData()

        // We need to update this when any parameters change at least. For now,
        // update all editors at once for simplicity... optimize if necessary later.
        caseListView.editor?.reloadData()
    }

    // MARK: Private

    private var canvasListView = CanvasListView(frame: .zero)
    private var logicListView = LogicListView(frame: .zero)
    private var parameterListEditorView = ParameterListEditorView(frame: .zero)
    private var caseListView = CaseList(frame: .zero)
    private var metadataEditorView = MetadataEditorView()

    private var tabMap: [Tab: NSView?] = [:]

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        for (tab, view) in tabMap {
            guard let view = view else { continue }

            if tab == currentTab {
                if view.superview != self {
                    self.addSubviewStretched(subview: view)
                }
            } else {
                if view.superview == self {
                    view.removeFromSuperview()
                }
            }
        }

        switch currentTab {
        case .logic:
            logicListView.component = component
            logicListView.list = component?.logic ?? []
            logicListView.editor?.reloadData()
        case .examples:
            caseListView.component = component
            caseListView.list = component?.cases ?? []
            caseListView.editor?.reloadData()
        case .devices:
            canvasListView.editorView.component = component
            canvasListView.canvasList = component?.canvas ?? []
            canvasListView.canvasLayout = component?.canvasLayoutAxis ?? StaticCanvasRenderer.Layout.canvasXcaseY
        case .parameters:
            parameterListEditorView.parameterList = component?.parameters ?? []
        case .details:
            metadata = component?.metadata ?? .Null
        }
    }
}
