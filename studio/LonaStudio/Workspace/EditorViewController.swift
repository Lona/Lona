//
//  EditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/1/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar
import Foundation

// MARK: - EditorViewController

class EditorViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var showsHeaderDivider: Bool = false {
        didSet {
            if showsHeaderDivider != oldValue {
                update()
            }
        }
    }

    public var breadcrumbs: [Breadcrumb] {
        get { return navigationBar.breadcrumbs }
        set { navigationBar.breadcrumbs = newValue }
    }

    public var onClickBreadcrumb: ((UUID) -> Void)? {
        get { return navigationBar.onClickBreadcrumb }
        set { navigationBar.onClickBreadcrumb = newValue }
    }

    public var onClickPublish: (() -> Void)? {
        get { return publishButton.onClick }
        set { publishButton.onClick = newValue }
    }

    public var contentView: NSView? {
        didSet {
            if let contentView = contentView {
                if contentView != oldValue {
                    oldValue?.removeFromSuperview()

                    contentView.removeFromSuperview()

                    contentContainerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false

                    contentView.topAnchor.constraint(equalTo: dividerView.bottomAnchor).isActive = true

                    contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
                    contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
                    contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }

            update()
        }
    }

    public static var navigationBarHeight: CGFloat = 38

    // MARK: Private

    private let contentContainerView = NSBox(frame: .zero)

    private let navigationBar = NavigationBar()

    private let dividerView = NSBox()

    private let publishButton = BreadcrumbItem(titleText: "Publish", icon: nil, isEnabled: true)

    private let accessoryButtonContainer = NSStackView()

    private func updateHistory(_ history: History<URL>) {
        navigationBar.isBackEnabled = history.canGoBack()
        navigationBar.isForwardEnabled = history.canGoForward()

        navigationBar.menuForBackItem = {
            return NSMenu(items: history.back.enumerated().map({ index, url in
                let item = NSMenuItem(title: url.lastPathComponent, onClick: {
                    _ = DocumentController.shared.navigateBack(offset: index)
                })
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = .init(width: 16, height: 16)
                item.image = icon
                return item
            }))
        }

        navigationBar.menuForForwardItem = {
            return NSMenu(items: history.forward.enumerated().map({ index, url in
                let item = NSMenuItem(title: url.lastPathComponent, onClick: {
                    _ = DocumentController.shared.navigateForward(offset: index)
                })
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = .init(width: 16, height: 16)
                item.image = icon
                return item
            }))
        }

        navigationBar.onClickBack = {
            _ = DocumentController.shared.navigateBack()
        }

        navigationBar.onClickForward = {
            _ = DocumentController.shared.navigateForward()
        }
    }

    private func setUpViews() {
        contentContainerView.fillColor = Colors.contentBackground
        contentContainerView.boxType = .custom
        contentContainerView.borderType = .noBorder
        contentContainerView.contentViewMargins = .zero

        dividerView.boxType = .custom
        dividerView.borderType = .noBorder
        dividerView.contentViewMargins = .zero

        contentContainerView.addSubview(dividerView)
        contentContainerView.addSubview(navigationBar)

        accessoryButtonContainer.addArrangedSubview(publishButton)
        accessoryButtonContainer.edgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)

        navigationBar.accessoryView = accessoryButtonContainer

        DocumentController.shared.historyEmitter.addListener { [unowned self] history in self.updateHistory(history) }

        self.view = contentContainerView
    }

    private func setUpConstraints() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false

        navigationBar.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 8).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -8).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: EditorViewController.navigationBarHeight).isActive = true

        dividerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true

        dividerView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    private func update() {
        if showsHeaderDivider {
            dividerView.fillColor = NSSplitView.defaultDividerColor
        } else {
            dividerView.fillColor = .clear
        }
    }
}
