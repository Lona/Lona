//
//  MainSectionViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/24/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

class MainSectionViewController: NSSplitViewController {

    private let splitViewRestorationIdentifier = "tech.lona.restorationId:componentEditorController"

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

    public var topView: NSView? {
        didSet {
            if let topView = topView {
                if topView != oldValue {
                    oldValue?.removeFromSuperview()

                    topContainerView.addSubview(topView)

                    topView.translatesAutoresizingMaskIntoConstraints = false

                    topView.topAnchor.constraint(equalTo: topContainerView.topAnchor).isActive = true
                    topView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true
                    topView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor).isActive = true
                    topView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    public var bottomView: NSView? {
        didSet {
            if let bottomView = bottomView {
                if bottomView != oldValue {
                    oldValue?.removeFromSuperview()

                    bottomContainerView.addSubview(bottomView)

                    bottomView.translatesAutoresizingMaskIntoConstraints = false

                    bottomView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true
                    bottomView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor).isActive = true
                    bottomView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor).isActive = true
                    bottomView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    public var dividerView: NSView? {
        get { return (splitView as? DividerSplitView)?.dividerView }
        set { (splitView as? DividerSplitView)?.dividerView = newValue }
    }

    // MARK: Private

    private lazy var topContainerView = NSView()

    private lazy var bottomContainerView = NSView()

    private lazy var topItem: NSSplitViewItem = {
        return .init(viewController: NSViewController(view: topContainerView))
    }()

    private lazy var bottomItem: NSSplitViewItem = {
        return .init(viewController: NSViewController(view: bottomContainerView))
    }()

    private func setUpLayout() {
        minimumThicknessForInlineSidebars = 180

        topItem.minimumThickness = 300
        addSplitViewItem(topItem)

        bottomItem.canCollapse = true
        bottomItem.minimumThickness = 100
        addSplitViewItem(bottomItem)
    }

    private func setUpViews() {
        let splitView = DividerSplitView()

        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.autosaveName = splitViewRestorationIdentifier
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewRestorationIdentifier)

        self.splitView = splitView
    }
}
