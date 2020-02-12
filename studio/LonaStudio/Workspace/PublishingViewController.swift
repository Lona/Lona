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
        case createRepo(organizationName: String, githubOrganizations: [String])
        case done
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
        history = .init()
        history.navigateTo(Account.token != nil ? State.needsOrg : State.needsAuth)
        workspaceName = CSWorkspacePreferences.workspaceName
        update()
    }

    // MARK: Private

    private var history = History<State>() {
        didSet {
            update()
        }
    }

    private var workspaceName: String = ""

    private let containerView = NSBox()

    private let navigationControl = NavigationControl()

    private var contentViewTopAnchor: NSLayoutConstraint?

    private var contentView: NSView? {
        didSet {
            if oldValue != contentView {
                oldValue?.removeFromSuperview()

                if let contentView = contentView {
                    containerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: showNavigationControl ? 80 : 40).isActive = true
                    contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40).isActive = true
                    contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40).isActive = true
                    contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40).isActive = true
                }
            }
        }
    }

    private func makeContentView() -> NSView {
        guard let state = history.current else { return NSView() }

        switch state {
        case .needsAuth:
            let screen = PublishNeedsAuth(workspaceName: workspaceName)
            screen.onClickGithubButton = {
                let url = URL(string: "https://github.com/login/oauth/authorize?scope=user:email&client_id=\(GITHUB_CLIENT_ID)&redirect_uri=\(encodeURIComponent("\(API_BASE_URL)/oauth/github/\(encodeURIComponent("lonastudio://oauth-callback"))"))")!
                if !NSWorkspace.shared.open(url) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickGoogleButton = {
                let url = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(GITHUB_CLIENT_ID)&response_type=code&scope=openid%20email%20profile&redirect_uri=\(encodeURIComponent("\(API_BASE_URL)/oauth/github/\(encodeURIComponent("lonastudio://oauth-callback"))"))")!
                if !NSWorkspace.shared.open(url) {
                    print("couldn't open the  browser")
                }
            }
            return screen
        case .needsOrg:
            let screen = PublishNeedsOrg(workspaceName: workspaceName, organizationName: "")
            screen.onChangeTextValue = { [unowned screen] value in
                screen.organizationName = value
            }
            screen.onClickSubmit = { [unowned self] in
                self.history.navigateTo(.needsRepo(organizationName: screen.organizationName))
            }
            return screen
        case .needsRepo(let organizationName):
            let screen = PublishNeedsRepo(workspaceName: workspaceName, organizationName: organizationName)
            screen.onClickCreateRepository = { [unowned self] in
                self.history.navigateTo(.createRepo(organizationName: screen.organizationName, githubOrganizations: ["dabbott", "Lona"]))
            }
            return screen
        case .createRepo(let organizationName, let githubOrganizations):
            let screen = PublishCreateRepo(
                workspaceName: workspaceName,
                organizationName: organizationName,
                githubOrganizations: githubOrganizations,
                githubOrganizationIndex: 0,
                repositoryName: "",
                submitButtonTitle: ""
            )
            let updateSubmitButtonTitle: () -> Void = { [unowned screen] in
                screen.submitButtonTitle = "Create \(githubOrganizations[screen.githubOrganizationIndex])/\(screen.repositoryName)"
            }
            screen.onChangeRepositoryName = { [unowned screen] value in
                screen.repositoryName = value
                updateSubmitButtonTitle()
            }
            screen.onChangeGithubOrganizationsIndex = { [unowned screen] index in
                screen.githubOrganizationIndex = index
                updateSubmitButtonTitle()
            }
            screen.onClickSubmitButton = { [unowned self] in
                // TODO: Actually create everything
                self.history = .init(.done)
            }
            updateSubmitButtonTitle()
            return screen
        case .done:
            let screen = PublishDone(workspaceName: workspaceName)
            screen.onClickDoneButton = { [unowned self] in
                self.dismiss(nil)
            }
            return screen
        }
    }

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero
        containerView.fillColor = Colors.windowBackground

        containerView.addSubview(navigationControl)

        navigationControl.onClickBack = { [unowned self] in self.history.goBack() }
        navigationControl.onClickForward = { [unowned self] in self.history.goForward() }

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

        navigationControl.isBackEnabled = history.canGoBack()
        navigationControl.isForwardEnabled = history.canGoForward()
        navigationControl.isHidden = !showNavigationControl
    }

    private var showNavigationControl: Bool {
        guard let state = history.current else { return false }

        switch state {
        case .needsAuth, .done:
            return false
        default:
            return true
        }
    }

    override func viewDidAppear() {
        guard let window = contentView?.window else { return }

        window.title = "Publishing"
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}

