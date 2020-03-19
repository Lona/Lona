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
        switch history.current {
        case .done, .error:
            flowView.showsNavigationControl = false
        default:
            flowView.showsNavigationControl = true
        }

        flowView.isBackEnabled = history.canGoBack()
        flowView.isForwardEnabled = history.canGoForward()

        let newContentView = makeViewFromState()

        flowView.screenView = newContentView

        self.view.window?.setContentSize(.init(width: flowView.frame.width, height: 0))
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
                if !NSWorkspace.shared.open(GITHUB_SIGNIN_URL(scopes: GITHUB_BASIC_AND_REPO_SCOPES)) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickGoogleButton = {
                if !NSWorkspace.shared.open(GOOGLE_SIGNIN_URL()) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickRemoteButton = {
                let promise = PublishingViewController.fetchRepositoriesAndOrganizations()

                self.flowView.withProgress(promise)

                promise.finalResult({ result in
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
            let screen = OpenSyncLocation(workspaceName: repository.url.lastPathComponent, localPath: "", submitButtonTitle: "")
            let updateSubmitButtonTitle: () -> Void = { [unowned screen] in
                if let url = URL(string: screen.localPath) {
                    screen.submitButtonTitle = "Sync \(url.lastPathComponent)"
                } else {
                    screen.submitButtonTitle = "Sync"
                }
            }
            updateSubmitButtonTitle()
            screen.onChangeLocalPath = { value in
                screen.localPath = value
                updateSubmitButtonTitle()
            }
            screen.onClickChooseDirectory = {
                let dialog = NSOpenPanel()

                dialog.title = "Workspace sync directory"
                dialog.message = "Choose a directory to sync this workspace into"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canChooseFiles = false
                dialog.canChooseDirectories = true
                dialog.canCreateDirectories = true
                dialog.allowsMultipleSelection = false

                if dialog.runModal() != NSApplication.ModalResponse.OK { return }
                guard let localURL = dialog.url else { return }

                screen.localPath = localURL.appendingPathComponent(repository.url.deletingPathExtension().lastPathComponent).path
                updateSubmitButtonTitle()
            }
            screen.onClickSubmitButton = {
                guard let sshURL = Git.URL.format(repository.url, as: .ssh) else {
                    Alert.runInformationalAlert(messageText: "Invalid workspace", informativeText: "Faile to create SSH URL from \(repository.url).")
                    return
                }

                let result = Git.client.clone(repository: sshURL, localDirectoryPath: screen.localPath)
                switch result {
                case .failure(let error):
                    Alert.runInformationalAlert(messageText: "Failed to sync \(repository.url.lastPathComponent)", informativeText: "Git clone failed. Error: \(error)")
                case .success:
                    let initialDocumentURL = URL(fileURLWithPath: screen.localPath).appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)
                    DocumentController.shared.openDocument(withContentsOf: initialDocumentURL, display: true, completionHandler: { [unowned self] document, _, _ in
                        if let _ = document {
                            self.onRequestClose?()
                        }
                    })
                }
            }
            return screen
        case .error(title: let title, body: let body):
            let screen = PublishInfo(
                titleText: title,
                bodyText: body,
                showsCancelButton: false,
                doneButtonTitle: "OK",
                cancelButtonTitle: ""
            )
            screen.onClickDoneButton = self.onRequestClose
            return screen
        case .done:
            let screen = PublishDone(workspaceName: "")
            screen.onClickDoneButton = self.onRequestClose
            return screen
        }
    }
}
