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

    // MARK: Private

    private lazy var layerList = LayerList()
    private lazy var layerListViewController: NSViewController = {
        return ViewController(view: layerList)
    }()

    private lazy var vcB = ColorVC(backgroundColor: .green)
    private lazy var vcC = ColorVC(backgroundColor: .blue)

    private func update() {
        layerList.component = component
    }
}

extension WorkspaceViewController {

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

        let mainItem = NSSplitViewItem(viewController: vcB)
        mainItem.minimumThickness = 300
        addSplitViewItem(mainItem)

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: vcC)
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 200
        addSplitViewItem(sidebarItem)
    }

}
