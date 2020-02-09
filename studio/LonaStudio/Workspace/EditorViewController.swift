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

    public var breadcrumbs: [Breadcrumb] {
        get { return breadcrumbView.breadcrumbs }
        set { breadcrumbView.breadcrumbs = newValue }
    }

    public var onClickBreadcrumb: ((UUID) -> Void)? {
        get { return breadcrumbView.onClickBreadcrumb }
        set { breadcrumbView.onClickBreadcrumb = newValue }
    }

    public var contentView: NSView? {
        didSet {
            if let contentView = contentView {
                if contentView != oldValue {
                    oldValue?.removeFromSuperview()

                    contentView.removeFromSuperview()

                    contentContainerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.topAnchor.constraint(equalTo: breadcrumbView.bottomAnchor).isActive = true
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

    // MARK: Private

    private let contentContainerView = NSBox(frame: .zero)

    private let breadcrumbView = NavigationBar()

    private func updateHistory(_ history: History) {
        breadcrumbView.isBackEnabled = history.canGoBack()
        breadcrumbView.isForwardEnabled = history.canGoForward()

        breadcrumbView.menuForBackItem = {
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

        breadcrumbView.menuForForwardItem = {
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

        breadcrumbView.onClickBack = {
            _ = DocumentController.shared.navigateBack()
        }

        breadcrumbView.onClickForward = {
            _ = DocumentController.shared.navigateForward()
        }
    }

    private func setUpViews() {
        contentContainerView.fillColor = Colors.contentBackground
        contentContainerView.boxType = .custom
        contentContainerView.borderType = .noBorder
        contentContainerView.contentViewMargins = .zero

        DocumentController.shared.historyEmitter.addListener { [unowned self] history in self.updateHistory(history) }

        self.view = contentContainerView
    }

    private func setUpConstraints() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbView.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.addSubview(breadcrumbView)

        breadcrumbView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        breadcrumbView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 8).isActive = true
        breadcrumbView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -8).isActive = true
        breadcrumbView.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }

    private func update() {}
}
