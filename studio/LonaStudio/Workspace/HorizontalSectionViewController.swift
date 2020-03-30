//
//  HorizontalSectionViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/24/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

class HorizontalSectionViewController: NSSplitViewController {

    private let splitViewRestorationIdentifier = "tech.lona.restorationId:layerEditorController"

    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Public

    public var leftView: NSView? {
        didSet {
            if let topView = leftView {
                if topView != oldValue {
                    oldValue?.removeFromSuperview()

                    leftContainerView.addSubview(topView)

                    topView.translatesAutoresizingMaskIntoConstraints = false

                    topView.topAnchor.constraint(equalTo: leftContainerView.topAnchor).isActive = true
                    topView.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor).isActive = true
                    topView.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor).isActive = true
                    topView.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    public var rightView: NSView? {
        didSet {
            if let bottomView = rightView {
                if bottomView != oldValue {
                    oldValue?.removeFromSuperview()

                    rightContainerView.addSubview(bottomView)

                    bottomView.translatesAutoresizingMaskIntoConstraints = false

                    bottomView.topAnchor.constraint(equalTo: rightContainerView.topAnchor).isActive = true
                    bottomView.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor).isActive = true
                    bottomView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor).isActive = true
                    bottomView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    // MARK: Private

    private lazy var leftContainerView = NSView()

    private lazy var rightContainerView = NSView()

    private lazy var leftItem: NSSplitViewItem = {
        return .init(viewController: NSViewController(view: leftContainerView))
    }()

    private lazy var rightItem: NSSplitViewItem = {
        return .init(viewController: NSViewController(view: rightContainerView))
    }()

    private func setUpLayout() {
//        minimumThicknessForInlineSidebars = 120

//        leftItem.canCollapse = true
        leftItem.minimumThickness = 120
        addSplitViewItem(leftItem)

        rightItem.minimumThickness = 300
        addSplitViewItem(rightItem)
    }

    private func setUpViews() {
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        splitView.autosaveName = splitViewRestorationIdentifier
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewRestorationIdentifier)

        self.splitView = splitView
    }
}
