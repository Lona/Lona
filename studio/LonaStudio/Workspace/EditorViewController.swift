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
                if contentView.superview != contentContainerView {
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

    private let contentContainerView = NSView(frame: .zero)

    private let breadcrumbView = BreadcrumbBar()

    private func setUpViews() {
        self.view = contentContainerView

        breadcrumbView.fillColor = Colors.contentBackground
    }

    private func setUpConstraints() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbView.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.addSubview(breadcrumbView)

        breadcrumbView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        breadcrumbView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
        breadcrumbView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
        breadcrumbView.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }

    private func update() {}
}
