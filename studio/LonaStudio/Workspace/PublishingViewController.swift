//
//  PublishingViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/11/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar
import Apollo

// MARK: - PublishingViewController

class PublishingViewController: NSViewController {

    public struct Organization: Equatable {
        let id: GraphQLID
        let name: String
    }

    public struct Repository: Equatable {
        let url: URL
        let activated: Bool
    }

    // MARK: Static

    static var shared = PublishingViewController()

    // MARK: Types

    private enum State: Equatable {
        case needsAuth
        case chooseOrg(organizations: [Organization])
        case needsRepo(organization: Organization)
        case createRepo(organization: Organization, githubOrganizations: [Organization])
        case done
        case error(title: String, body: String)
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
        workspaceName = CSWorkspacePreferences.workspaceName
        update()

        switch Git.client.getRootDirectoryPath() {
        case .success(let path) where path == CSUserPreferences.workspaceURL.path:
            break
        case .success:
            self.history = .init(.error(title: "Couldn't publish workspace", body: "Invalid git configuration: there must be a git repository in your workspace root (the same directory as the lona.json) before you can publish."))
            return
        case .failure(let error):
            self.history = .init(.error(title: "Couldn't publish workspace", body: "Failed to find root git directory.\n\(error)"))
            return
        }

        if Account.shared.signedIn {
            fetchRepositoriesAndOrganizations().finalResult({ result in
                switch result {
                case .failure(let error):
                    self.history = .init(.error(title: "Couldn't publish workspace", body: "Failed to connect to Lona API.\n\(error)"))
                case .success(let repositories, let organizations):
                    switch Git.client.getRemoteURL() {
                    case .failure:
                        // We haven't added a remote yet, so this is a new repository
                        break
                    case .success(let url):
                        // Check if the remote repository URL matches a Lona repository URL
                        if repositories.contains(where: {
                            $0.url == Git.URL.format(url, as: .ssh) || $0.url == Git.URL.format(url, as: .https)
                        }) {
                            self.showsProgressIndicator = true

                            // If local and remote repo are out of sync, bail out
                            // TODO: Try to fast-forward local repo
                            Git.client.isLocalBranchUpToDateWithRemote().finalResult({ result in
                                DispatchQueue.main.sync {
                                    self.showsProgressIndicator = false

                                    switch Git.client.hasUncommittedChanges() {
                                    case .failure(let error):
                                        self.history = .init(.error(title: "Couldn't publish workspace", body: error.localizedDescription))
                                    case .success(false):
                                        self.history = .init(.error(title: "No changes to publish", body: "You haven't made any changes since the last version of the workspace was published!"))
                                        return
                                    case .success(true):
                                        break
                                    }

                                    switch result {
                                    case .success(true):
                                        self.showsProgressIndicator = true

                                        _ = Git.client.addAllFiles()
                                        _ = Git.client.commit(message: "Updates")
                                        _ = Git.client.push(repository: Git.defaultOriginName, refspec: "HEAD")

                                        self.showsProgressIndicator = false

                                        self.history = .init(.done)
                                    case .success(false):
                                        self.history = .init(.error(title: "Local workspace outdated", body: "Remote changes have been made to your workspace. You must sync them locally before you can publish your local changes."))
                                    case .failure(let error):
                                        self.history = .init(.error(title: "Couldn't publish workspace", body: error.localizedDescription))
                                    }
                                }
                            })

                            return
                        }

                        // If we don't find a match, then this is a repository not created through Lona Studio
                    }

                    self.history.navigateTo(.chooseOrg(organizations: organizations))
                }
            })
        } else {
            history.navigateTo(State.needsAuth)
        }
    }

    // MARK: Private

    private var history = History<State>() {
        didSet {
            update()
        }
    }

    private var showsProgressIndicator = false {
        didSet {
            if oldValue != showsProgressIndicator {
                if showsProgressIndicator {
                    progressIndicator.startAnimation(nil)
                } else {
                    progressIndicator.stopAnimation(nil)
                }

                update()
            }
        }
    }

    private var workspaceName: String = ""

    private let containerView = NSBox()

    private let navigationControl = NavigationControl()

    private let progressIndicator = NSProgressIndicator()

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
                if !NSWorkspace.shared.open(GITHUB_SIGNIN_URL(scopes: ["user:email", "read:org", "repo"])) {
                    print("couldn't open the  browser")
                }
            }
            screen.onClickGoogleButton = {
                if !NSWorkspace.shared.open(GOOGLE_SIGNIN_URL()) {
                    print("couldn't open the  browser")
                }
            }
            return screen
        case .needsRepo(let organization):
            let screen = PublishNeedsRepo(workspaceName: workspaceName, organizationName: organization.name)
            screen.onClickCreateRepository = { [unowned self] in
                self.fetchGitHubOrganizations().finalSuccess({ [weak self] organizations in
                    self?.history.navigateTo(.createRepo(organization: organization, githubOrganizations: organizations))
                })
            }
            return screen
        case .createRepo(let organization, let githubOrganizations):
            let screen = PublishCreateRepo(
                workspaceName: workspaceName,
                organizationName: organization.name,
                githubOrganizations: githubOrganizations.map { $0.name },
                githubOrganizationIndex: 0,
                repositoryName: workspaceName,
                submitButtonTitle: ""
            )
            let updateSubmitButtonTitle: () -> Void = { [unowned screen] in
                screen.submitButtonTitle = "Create \(githubOrganizations[screen.githubOrganizationIndex].name)/\(screen.repositoryName)"
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
                self.showsProgressIndicator = true

                self.createRepo(
                    organizationId: organization.id,
                    githubOrganization: githubOrganizations[screen.githubOrganizationIndex],
                    githubRepositoryName: screen.repositoryName
                ).finalResult({ [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let url):
                        let gitResult = Git.client
                            .addRemote(name: Git.defaultOriginName, url: Git.URL.format(url, as: .ssh)!)
                            .flatMap({ _ in Git.client.push(repository: Git.defaultOriginName, refspec: "HEAD") })

                        switch gitResult {
                        case .success:
                            break
                        case .failure(let error):
                            Swift.print("Failed to add git remote", url, error)
                        }

                        self.history = .init(.done)
                    case .failure(let error):
                        Swift.print("Failed to add repo:", error)
                    }
                })
            }
            updateSubmitButtonTitle()
            return screen
        case .chooseOrg(let organizations):
            let organizationIds = organizations.map { $0.id }
            let screen = PublishChooseOrg(
                titleText: "Publish \(workspaceName)",
                bodyText: organizations.isEmpty
                    ? """
First, you’ll need a Lona organization associated with your account.

If your team or company already has a Lona organization, an organization owner can add your account to it. Otherwise, create a new organization below.
"""
                    : "Choose a Lona organization to publish this workspace to, or create a new one.",
                organizationName: "",
                organizationIds: organizationIds,
                showsOrganizationsList: !organizations.isEmpty,
                isSubmitting: false
            )
            screen.onChangeTextValue = { [unowned screen] value in
                screen.organizationName = value
            }
            screen.onClickSubmit = { [unowned self] in
                if screen.isSubmitting { return }

                screen.isSubmitting = true

                self.createOrganization(name: screen.organizationName).finalResult({ [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let organization):
                        self.history.navigateTo(.needsRepo(organization: organization))
                    case .failure(let error):
                        screen.isSubmitting = false

                        Alert.runInformationalAlert(messageText: "Failed to create organization", informativeText: error.description)
                    }
                })
            }
            screen.onSelectOrganizationId = { [unowned self] id in
                guard let organization = organizations.first(where: { $0.id == id }) else { return }

                self.history.navigateTo(.needsRepo(organization: organization))
            }
            return screen
        case .error(title: let title, body: let body):
            let screen = PublishInfo(titleText: title, bodyText: body)
            screen.onClickDoneButton = { [unowned self] in
                self.dismiss(nil)
            }
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

        containerView.addSubview(progressIndicator)

        navigationControl.onClickBack = { [unowned self] in self.history.goBack() }
        navigationControl.onClickForward = { [unowned self] in self.history.goForward() }

        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = true

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        navigationControl.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false

        containerView.widthAnchor.constraint(equalToConstant: 720).isActive = true
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        containerView.heightAnchor.constraint(lessThanOrEqualToConstant: 800).isActive = true

        navigationControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32).isActive = true

        progressIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 44).isActive = true
        progressIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        progressIndicator.controlSize = .small
    }

    private func update() {
        contentView = makeContentView()

        progressIndicator.isHidden = !showsProgressIndicator

        navigationControl.isBackEnabled = history.canGoBack()
        navigationControl.isForwardEnabled = history.canGoForward()
        navigationControl.isHidden = !showNavigationControl
    }

    private var showNavigationControl: Bool {
        guard let state = history.current else { return false }

        switch state {
        case .needsAuth, .done, .error:
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

// MARK: - API

extension PublishingViewController {

    private func fetchRepositoriesAndOrganizations() -> Promise<([Repository], [Organization]), NSError> {
        self.showsProgressIndicator = true

        return Account.shared.me(forceRefresh: true).onSuccess { [weak self] result in
            guard let self = self else { return .failure(NSError("Missing self")) }

            self.showsProgressIndicator = false

            let organizations = result.organizations.map { Organization(id: $0.id, name: $0.name) }

            let repositories: [Repository] = Array(result.organizations.map({ organization in
                return organization.repos.map { Repository(url: URL(string: $0.url)!, activated: $0.activated) }
            }).joined())

            return .success((repositories, organizations))
        }
    }

    private func fetchGitHubOrganizations() -> Promise<[Organization], NSError> {
        return .result { complete in
            self.showsProgressIndicator = true

            Network.shared.github.fetch(query: GetOrganizationsQuery()) { [weak self] result in
                guard let self = self else { return }

                self.showsProgressIndicator = false

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        complete(.failure(NSError(errors.description)))
                        return
                    }

                    guard let data = graphQLResult.data?.viewer else {
                      complete(.failure(NSError("Missing result")))
                      return
                    }

                    var organizations = [Organization(id: data.id, name: data.login)]

                    data.organizations.nodes?.forEach { org in
                      if let org = org {
                        organizations.append(Organization(id: org.id, name: org.login))
                      }
                    }

                    complete(.success(organizations))
                case .failure(let error):
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }

    private func createRepo(organizationId: String, githubOrganization: Organization, githubRepositoryName: String) -> Promise<URL, NSError> {
        return .result { complete in
            self.showsProgressIndicator = true

            let mutation = CreateRepositoryMutation(
                ownerId: githubOrganization.id,
                name: githubRepositoryName,
                description: "Lona Workspace"
            )

            Network.shared.github.perform(mutation: mutation) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        self.showsProgressIndicator = false
                        complete(.failure(NSError(errors.description)))
                        return
                    }

                    guard let urlString = graphQLResult.data?.createRepository?.repository?.url, let url = URL(string: urlString) else {
                        self.showsProgressIndicator = false
                        complete(.failure(NSError("Missing repo url")))
                        return
                    }

                    self.addRepo(organizationId: organizationId, githubRepoURL: url).finalResult { addRepoResult in
                        switch addRepoResult {
                        case .success:
                            complete(.success(url))
                        case .failure(let error):
                            complete(.failure(error))
                        }
                    }
                case .failure(let error):
                    self.showsProgressIndicator = false
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }

    private func addRepo(organizationId: String, githubRepoURL: URL) -> Promise<Void, NSError> {
        return .result { complete in
            self.showsProgressIndicator = true

            let mutation = AddRepoMutation(
                organizationId: organizationId,
                url: githubRepoURL.absoluteString
            )

            Network.shared.lona.perform(mutation: mutation) { [weak self] result in
                guard let self = self else { return }

                self.showsProgressIndicator = false

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        complete(.failure(NSError(errors.description)))
                        return
                    }

                    complete(.success(()))
                case .failure(let error):
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }

    private func createOrganization(name organizationName: String) -> Promise<Organization, NSError> {
        return .result { complete in
            self.showsProgressIndicator = true

            Network.shared.lona.perform(mutation: CreateOrganizationMutation(name: organizationName)) { [weak self] result in
                guard let self = self else { return }

                self.showsProgressIndicator = false

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        complete(.failure(NSError(errors.description)))
                        return
                    }

                    guard
                        let organizationName = graphQLResult.data?.createOrganization.organization?.name,
                        let organizationId = graphQLResult.data?.createOrganization.organization?.id
                        else {
                            complete(.failure(NSError("Missing name or id")))
                            return
                    }

                    complete(.success(Organization(id: organizationId, name: organizationName)))
                case .failure(let error):
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }
}
