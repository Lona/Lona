//
//  OpenWorkspaceViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/11/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar
import Apollo

// MARK: - Types

public enum OpenWorkspaceState: Equatable {
    case done
    case localOrRemote(isLoggedIn: Bool)
    case chooseRepo(repositories: [LonaRepository])
    case chooseSyncDirectory(repository: LonaRepository)
    case error(title: String, body: String)
}

// MARK: - OpenWorkspaceViewController

class OpenWorkspaceViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()

        update()
    }

    // MARK: Static

    static var shared = OpenWorkspaceViewController()

    // MARK: Public

    public func initializeState() {
        history = .init()

        if Account.shared.signedIn {
            history = .init(.localOrRemote(isLoggedIn: true))
        } else {
            history = .init(.localOrRemote(isLoggedIn: false))
        }
    }

    public var onRequestClose: (() -> Void)?

    // MARK: Private

    private var history = History<OpenWorkspaceState>() { didSet { update() } }

    private var flowView: FlowView = FlowView()

    private func setUpViews() {
        flowView.onClickBack = { [unowned self] in self.history.goBack() }
        flowView.onClickForward = { [unowned self] in self.history.goForward() }

        flowView.showsNavigationControl = true

        self.view = flowView
    }

    private func update() {
        let newContentView = makeViewFromState()

        // A small hack to prevent transitioning between the same State twice.
        // This allows us to store screen variables (i.e. user input values) directly on the screen instance.
        // If we need to allow transitions between the same State, a better approach could be to store screens variables
        // in the State object, and update the old screen instance as needed, without unmounting.
//        if newContentView.className != flowView.screenView?.className {
            flowView.screenView = newContentView
//        }

        if let window = flowView.window {
            // Try to set the window dimensions to zero.
            // Autolayout will snap it back to the minimum size allowed based on the contentView's contraints.
            window.setContentSize(.zero)
        }
    }

    override func viewDidAppear() {
        guard let window = view.window else { return }

        window.title = "Open workspace"
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }

    private func makeViewFromState() -> NSView {
        guard let state = history.current else { return NSView() }

        switch state {
        case .localOrRemote(let isLoggedIn):
            let screen = OpenWorkspace()
            screen.isLoggedIn = isLoggedIn
            screen.onClickGithubButton = {
                if !NSWorkspace.shared.open(GITHUB_SIGNIN_URL(scopes: ["user:email", "read:org", "repo"])) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickGoogleButton = {
                if !NSWorkspace.shared.open(GOOGLE_SIGNIN_URL()) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickRemoteButton = {
                self.flowView.withProgress(PublishingViewController.fetchRepositoriesAndOrganizations).finalResult({ result in
                    switch result {
                    case .failure(let error):
                        Alert.runInformationalAlert(messageText: "Failed to connect to GitHub", informativeText: "Are you connected to the internet? \(error)")
                    case .success(let repositories, _):
                        self.history.navigateTo(.chooseRepo(repositories: repositories))
                    }
                })
            }
            screen.onClickLocalButton = {
                guard let url = WelcomeWindow.openWorkspaceDialog() else { return }

                DocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { [unowned self] document, _, _ in
                    if let _ = document {
                        self.onRequestClose?()
                    }
                })
            }
            return screen
        case .chooseRepo(let repositories):
            let screen = OpenChooseRepo(titleText: "Choose a Lona workspace", bodyText: "Sync one of these workspaces from your account to your hard drive:", repositoryIds: repositories.map({ $0.url.absoluteString }))
            screen.onSelectRepositoryId = { id in
                let url = URL(string: id)!
                let repository = repositories.first(where: { $0.url == url })!
                self.history.navigateTo(.chooseSyncDirectory(repository: repository))
            }
            return screen
        case .chooseSyncDirectory(repository: let repository):
            return PublishDone(workspaceName: "")
        case .error(title: let title, body: let body):
            let screen = PublishInfo(titleText: title, bodyText: body)
            screen.onClickDoneButton = self.onRequestClose
            return screen
        case .done:
            let screen = PublishDone(workspaceName: "")
            screen.onClickDoneButton = self.onRequestClose
            return screen
        }
    }
}
