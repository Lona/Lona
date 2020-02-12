//
//  PublishingViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/11/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar

// MARK: - PublishingViewController

class PublishingViewController: NSViewController {

    // MARK: Static

    static var shared = PublishingViewController()

    // MARK: Types

    private enum State: Equatable {
        case needsAuth
        case needsOrg
        case needsRepo(organizationName: String)
    }

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

    public var image: NSImage? { didSet { update() } }

    public func initializeState() {
        workspaceName = CSWorkspacePreferences.workspaceName
        state = .needsAuth
        update()
    }

    // MARK: Private

    private var workspaceName: String = ""

    private let containerView = NSBox()

    private let navigationControl = NavigationControl()

    private var contentView: NSView? {
        didSet {
            if oldValue != contentView {
                oldValue?.removeFromSuperview()

                if let contentView = contentView {
                    containerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 80).isActive = true
                    contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40).isActive = true
                    contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40).isActive = true
                    contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40).isActive = true
                }
            }
        }
    }

    private var state: State = .needsAuth {
        didSet {
            if oldValue != state {
                update()
            }
        }
    }

    private func makeContentView() -> NSView {
        switch state {
        case .needsAuth:
            let screen = PublishNeedsAuth(workspaceName: workspaceName)
            screen.onClickGithubButton = { [unowned self] in
                self.state = .needsOrg
            }
            return screen
        case .needsOrg:
            let screen = PublishNeedsOrg(workspaceName: workspaceName, organizationName: "")
            screen.onChangeTextValue = { [unowned screen] value in
                screen.organizationName = value
            }
            screen.onClickSubmit = { [unowned self] in
                self.state = .needsRepo(organizationName: screen.organizationName)
            }
            return screen
        case .needsRepo(let organizationName):
            let screen = PublishNeedsRepo(workspaceName: workspaceName, organizationName: organizationName)
            return screen
        }
    }

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero
        containerView.fillColor = Colors.windowBackground

        containerView.addSubview(navigationControl)

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        navigationControl.translatesAutoresizingMaskIntoConstraints = false

        containerView.widthAnchor.constraint(equalToConstant: 720).isActive = true

        navigationControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32).isActive = true
    }

    private func update() {
        contentView = makeContentView()
    }

    override func viewDidAppear() {
        contentView?.window?.title = "Publishing"
    }
}

