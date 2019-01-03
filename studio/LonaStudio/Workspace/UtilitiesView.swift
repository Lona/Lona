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
        case parameters = "Parameters"
        case logic = "Logic"
        case examples = "Examples"
        case details = "Details"
    }

    // MARK: Lifecycle

    public init(currentTab: Tab = .parameters) {
        self.currentTab = currentTab

        super.init(frame: .zero)

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

    public var onChangeParameterList: (([CSParameter]) -> Void)?

    public var onChangeLogicList: (([LogicNode]) -> Void)?

    public var onChangeCaseList: (([CSCase]) -> Void)?

    public var onChangeMetadata: ((CSData) -> Void)?

    public var onChangeCanvasList: (([Canvas]) -> Void)?

    public var onChangeCanvasLayout: ((StaticCanvasRenderer.Layout) -> Void) {
        get { return canvasListView?.onChangeLayout ?? { _ in } }
        set { canvasListView?.onChangeLayout = newValue }
    }

    public var component: CSComponent? {
        didSet {
            update()
        }
    }

    // TODO: This is likely no longer needed, since update() is called when we switch
    // between tabs. But we'll need to test thoroughly after we remove it.
    public func reloadData() {
        logicListView?.editor?.reloadData()

        // We need to update this when any parameters change at least. For now,
        // update all editors at once for simplicity... optimize if necessary later.
        caseListView?.editor?.reloadData()
    }

    // MARK: Private

    private var canvasListView: CanvasListView?
    private var logicListView: LogicListView?
    private var parameterListEditorView: ParameterListEditorView?
    private var caseListView: CaseList?
    private var metadataEditorView: MetadataEditorView?

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        switch currentTab {
        case .logic:
            if logicListView == nil {
                logicListView = LogicListView(frame: .zero)
                logicListView?.onChange = { [unowned self] list in self.onChangeLogicList?(list) }
            }

            logicListView?.component = component
            logicListView?.list = component?.logic ?? []
            logicListView?.editor?.reloadData()
        case .examples:
            if caseListView == nil {
                caseListView = CaseList(frame: .zero)
                caseListView?.onChange = { [unowned self] list in self.onChangeCaseList?(list) }
            }

            caseListView?.component = component
            caseListView?.list = component?.cases ?? []
            caseListView?.editor?.reloadData()
        case .parameters:
            if parameterListEditorView == nil {
                parameterListEditorView = ParameterListEditorView(frame: .zero)
                parameterListEditorView?.onChange = { [unowned self] list in self.onChangeParameterList?(list) }
            }

            parameterListEditorView?.parameterList = component?.parameters ?? []
        case .details:
            if metadataEditorView == nil {
                metadataEditorView = MetadataEditorView()
                metadataEditorView?.onChangeData = { [unowned self] data in self.onChangeMetadata?(data) }
            }

            metadataEditorView?.data = component?.metadata ?? .Null
        }

        let tabMap: [Tab: NSView?] = [
            .details: metadataEditorView,
            .parameters: parameterListEditorView,
            .examples: caseListView?.editor,
            .logic: logicListView?.editor
        ]

        for (tab, view) in tabMap {
            guard let view = view else { continue }

            if tab == currentTab {
                self.addSubviewStretched(subview: view)
            } else {
                view.removeFromSuperview()
            }
        }
    }
}
