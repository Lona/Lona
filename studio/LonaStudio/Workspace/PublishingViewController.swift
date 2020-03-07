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

// MARK: - Types

public struct LonaOrganization: Equatable {
    let id: GraphQLID
    let name: String
}

public struct LonaRepository: Equatable {
    let url: URL
    let activated: Bool
}

public enum PublishingState: Equatable {
    case needsAuth
    case chooseOrg(organizations: [LonaOrganization])
    case needsRepo(organization: LonaOrganization)
    case createRepo(organization: LonaOrganization, githubOrganizations: [LonaOrganization])
    case needsRepoScope(organizationId: String, githubOrganizationId: GraphQLID, githubRepositoryName: String, isPrivate: Bool)
    case installLonaApp(repository: LonaRepository)
    case done
    case error(title: String, body: String)
}

public enum PublishingError: Error {
    case insufficientScopes
    case noLocalChanges
    case noGitRoot
    case localRepositoryOutdated
    case localGit(Error)
    case apiResponse(message: String)
    case network(Error)

    var info: (title: String, details: String) {
        switch self {
        case .insufficientScopes:
            return ("Can't create GitHub repository", "Lona doesn't have permission to create a GitHub repository on your behalf.")
        case .noLocalChanges:
            return ("No changes to publish", "You haven't made any changes since the last version of the workspace was published!")
        case .noGitRoot:
            return ("Invalid git configuration", "There must be a git repository in your workspace root (the same directory as the lona.json) before you can publish.")
        case .localRepositoryOutdated:
            return ("Local workspace outdated", "Remote changes have been made to your workspace. You must sync them locally before you can publish your local changes.")
        case .localGit(let error):
            return ("Failed to run git command", "Error: \(error)")
        case .apiResponse(let message):
            return ("Invalid API response", "Error: \(message)")
        case .network(let error):
            return ("Network error", "Are you sure you're connected to the internet?\n\nError: \(error)")
        }
    }

    var publishingState: PublishingState {
        let info = self.info
        return .error(title: info.title, body: info.details)
    }
}

// MARK: - PublishingViewController

class PublishingViewController: NSViewController {

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

    static var shared = PublishingViewController()

    // MARK: Public

    private var history = History<PublishingState>() { didSet { update() } }

    public func initializeState() {
        history = .init()
        workspaceName = CSWorkspacePreferences.workspaceName

        switch Git.client.getRootDirectoryPath() {
        case .success(let path) where path == CSUserPreferences.workspaceURL.path:
            break
        case .success:
            self.history = .init(PublishingError.noGitRoot.publishingState)
            return
        case .failure(let error):
            self.history = .init(PublishingError.localGit(error).publishingState)
            return
        }

        if !Account.shared.signedIn {
            history.navigateTo(PublishingState.needsAuth)
            return
        }

        let initialStatePromise: Promise<PublishingState, PublishingError> = PublishingViewController
            .fetchRepositoriesAndOrganizations()
            .onFailure({ (error: NSError) in
                return .failure(.network(error))
            })
            .onSuccess({ (success: ([LonaRepository], [LonaOrganization])) in
                let (repositories, organizations) = success
                switch Git.client.getRemoteURL() {
                case .success(let url):
                    // Check if the remote repository URL matches a Lona repository URL
                    if repositories.contains(where: { Git.URL.isSameGitRepository($0.url, url) }) {
                        return .success((url, organizations))
                    } else {
                        // This is a repository created outside of Lona Studio
                        return .success((nil, organizations))
                    }
                case .failure:
                    // No remote yet; this is a new repository
                    return .success((nil, organizations))
                }
            })
            .onSuccess({ (success: (URL?, [LonaOrganization])) in
                let (url, organizations) = success

                if url == nil {
                    return .success(.chooseOrg(organizations: organizations))
                }

                // If local and remote repo are out of sync, bail out
                // TODO: Try to fast-forward local repo
                return Git.client.isLocalBranchUpToDateWithRemote().onResult({ result in
                    switch Git.client.hasUncommittedChanges() {
                    case .failure(let error):
                        return .failure(.localGit(error))
                    case .success(false):
                        return .failure(.noLocalChanges)
                    case .success(true):
                        break
                    }

                    switch result {
                    case .success(true):
                        _ = Git.client.addAllFiles()
                        _ = Git.client.commit(message: "Updates")
                        _ = Git.client.push(repository: Git.defaultOriginName, refspec: "HEAD")

                        return .success(.done)
                    case .success(false):
                        return .failure(.localRepositoryOutdated)
                    case .failure(let error):
                        return .failure(.localGit(error))
                    }
                })
            })

        flowView.withProgress(initialStatePromise)

        initialStatePromise.finalResult({ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let state):
                    self.history = .init(state)
                case .failure(let error):
                    let info = error.info
                    self.history = .init(.error(title: info.title, body: info.details))
                }
            }
        })
    }

    public func updateForNewAccountInfo() {
        switch history.current {
        case .needsAuth:
            initializeState()
        case .needsRepoScope(let value):
            createRepoOrRequestPermissions(organizationId: value.organizationId, githubOrganizationId: value.githubOrganizationId, githubRepositoryName: value.githubRepositoryName, isPrivate: value.isPrivate)
        default:
            initializeState()
        }
    }

    // MARK: Private

    private var flowView: FlowView = FlowView()

    private var showsProgressIndicator: Bool {
        get { return flowView.showsProgressIndicator }
        set { flowView.showsProgressIndicator = newValue }
    }

    private var workspaceName: String = ""

    private func setUpViews() {
        flowView.onClickBack = { [unowned self] in self.history.goBack() }
        flowView.onClickForward = { [unowned self] in self.history.goForward() }

        self.view = flowView
    }

    private func update() {
        let newContentView = makeViewFromState()

        switch history.current {
        case .needsAuth, .done, .error:
            flowView.showsNavigationControl = false
        default:
            flowView.showsNavigationControl = true
        }

        flowView.isBackEnabled = history.canGoBack()
        flowView.isForwardEnabled = history.canGoForward()

        // A small hack to prevent transitioning between the same State twice.
        // This allows us to store screen variables (i.e. user input values) directly on the screen instance.
        // If we need to allow transitions between the same State, a better approach could be to store screens variables
        // in the State object, and update the old screen instance as needed, without unmounting.
        if newContentView.className != flowView.screenView?.className {
            flowView.screenView = newContentView
        }

        if let window = flowView.window {
            // Try to set the window dimensions to zero.
            // Autolayout will snap it back to the minimum size allowed based on the contentView's contraints.
            window.setContentSize(.zero)
        }
    }

    override func viewDidAppear() {
        guard let window = view.window else { return }

        window.title = "Publishing"
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }

    private func makeViewFromState() -> NSView {
        guard let state = history.current else { return NSView() }

        switch state {
        case .needsAuth:
            let screen = PublishNeedsAuth(workspaceName: workspaceName)
            screen.onClickGithubButton = {
                if !NSWorkspace.shared.open(GITHUB_SIGNIN_URL(scopes: ["user:email", "read:org"])) {
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
            let repositoryPublic = "Public"
            let repositoryPrivate = "Private"
            let repositoryVisiblities = [repositoryPublic, repositoryPrivate]

            let screen = PublishCreateRepo(
                workspaceName: workspaceName,
                organizationName: organization.name,
                githubOrganizations: githubOrganizations.map { $0.name },
                githubOrganizationIndex: 0,
                repositoryName: workspaceName,
                submitButtonTitle: "",
                repositoryVisibilities: repositoryVisiblities,
                repositoryVisibilityIndex: 0
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
            screen.onChangeRepositoryVisibilityIndex = { [unowned screen] index in
                screen.repositoryVisibilityIndex = index
            }
            screen.onClickSubmitButton = { [unowned self] in
                self.createRepoOrRequestPermissions(
                    organizationId: organization.id,
                    githubOrganizationId: githubOrganizations[screen.githubOrganizationIndex].id,
                    githubRepositoryName: screen.repositoryName,
                    isPrivate: repositoryVisiblities[screen.repositoryVisibilityIndex] == repositoryPrivate
                )
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
        case .installLonaApp(repository: let repository):
            let screen = PublishLonaApp()
            screen.onClickSubmit = { [unowned self] in
                self.flowView.withProgress(PublishingViewController.fetchRepositoriesAndOrganizations).finalResult({ result in
                    switch result {
                    case .failure(let error):
                        Alert.runInformationalAlert(messageText: "Failed to connect to GitHub", informativeText: "Are you connected to the internet? \(error)")
                    case .success(let repositories, _):
                        if repositories.contains(where: { Git.URL.isSameGitRepository($0.url, repository.url) && $0.activated }) {
                            self.addRemoteAndPush(url: repository.url)
                        } else {
                            Alert.runInformationalAlert(messageText: "Lona plugin not installed", informativeText: "Are you sure you installed the Lona GitHub app on the correct repository?")
                        }
                    }
                })
            }
            screen.onClickOpenGithub = {
              let ghApp = API_BASE_URL == "https://api.lona.design/production" ? "lona" : "lona-dev"
              if !NSWorkspace.shared.open(URL(string: "https://github.com/apps/\(ghApp)/installations/new")!) {
                    Swift.print("couldn't open the browser")
                }
            }
            return screen
        case .needsRepoScope:
            let screen = PublishInfo(
                titleText: "Give Lona permission to create a repo?",
                bodyText: "Lona needs an additional permission to create a GitHub repository on your behalf. Press OK to open GitHub in your browser."
            )
            screen.onClickDoneButton = {
                if !NSWorkspace.shared.open(GITHUB_SIGNIN_URL(scopes: ["repo"])) {
                    Alert.runInformationalAlert(messageText: "Failed to open GitHub in your web browser")
                }
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

    private func createRepoOrRequestPermissions(organizationId: String, githubOrganizationId: GraphQLID, githubRepositoryName: String, isPrivate: Bool) {
        self.createRepo(
            organizationId: organizationId,
            githubOrganizationId: githubOrganizationId,
            githubRepositoryName: githubRepositoryName,
            isPrivate: isPrivate
        ).finalResult({ [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let url):
                self.flowView.withProgress(PublishingViewController.fetchRepositoriesAndOrganizations).finalResult({ [weak self] repositoriesAndOrganizations in
                    guard let self = self else { return }

                    switch repositoriesAndOrganizations {
                    case .failure(let error):
                        self.history = .init(.error(title: "Failed to find connected repository", body: "Are you sure you're connected to the internet? \(error)"))
                    case .success(let repositories, _):
                        if let found = repositories.first(where: { Git.URL.isSameGitRepository($0.url, url) }) {
                            if found.activated {
                                self.addRemoteAndPush(url: url)
                            } else {
                                self.history.navigateTo(.installLonaApp(repository: found))
                            }
                        } else {
                            Alert.runInformationalAlert(messageText: "Failed to find repository", informativeText: "This repository doesn't seem to be connected to Lona.")
                        }
                    }
                })
            case .failure(.insufficientScopes):
                self.history.navigateTo(
                    .needsRepoScope(
                        organizationId: organizationId,
                        githubOrganizationId: githubOrganizationId,
                        githubRepositoryName: githubRepositoryName,
                        isPrivate: isPrivate
                    )
                )
            case .failure(let error):
                Alert.runInformationalAlert(messageText: "Failed to create repository", informativeText: "\(error)")
            }
        })
    }
}

// MARK: - Git

extension PublishingViewController {
    private func addRemoteAndPush(url: URL) {
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
    }
}

// MARK: - API

extension PublishingViewController {

    public static func fetchRepositoriesAndOrganizations() -> Promise<([LonaRepository], [LonaOrganization]), NSError> {
        return Account.shared.me(forceRefresh: true).onSuccess { result in
            let organizations = result.organizations.map { LonaOrganization(id: $0.id, name: $0.name) }

            let repositories: [LonaRepository] = Array(result.organizations.map({ organization in
                return organization.repos.map { LonaRepository(url: URL(string: $0.url)!, activated: $0.activated) }
            }).joined())

            return .success((repositories, organizations))
        }
    }

    private func fetchGitHubOrganizations() -> Promise<[LonaOrganization], NSError> {
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

                    var organizations = [LonaOrganization(id: data.id, name: data.login)]

                    data.organizations.nodes?.forEach { org in
                      if let org = org {
                        organizations.append(LonaOrganization(id: org.id, name: org.login))
                      }
                    }

                    complete(.success(organizations))
                case .failure(let error):
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }

    private func createRepo(organizationId: String, githubOrganizationId: GraphQLID, githubRepositoryName: String, isPrivate: Bool) -> Promise<URL, PublishingError> {
        return .result { complete in
            let mutation = CreateRepositoryMutation(
                ownerId: githubOrganizationId,
                name: githubRepositoryName,
                description: "Lona Workspace",
                visibility: isPrivate ? .private : .public
            )

            Network.shared.github.perform(mutation: mutation) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        let isInsufficientScopesError = (errors[0]["type"] as? String) == "INSUFFICIENT_SCOPES"
                        complete(.failure(isInsufficientScopesError ? PublishingError.insufficientScopes : PublishingError.apiResponse(message: "GraphQL Errors: \(errors)")))
                        return
                    }

                    guard let urlString = graphQLResult.data?.createRepository?.repository?.url, let url = URL(string: urlString) else {
                        complete(.failure(.apiResponse(message: "GitHub API Error: No repository URL")))
                        return
                    }

                    self.addRepo(organizationId: organizationId, githubRepoURL: url).finalResult { addRepoResult in
                        switch addRepoResult {
                        case .success:
                            complete(.success(url))
                        case .failure(let error):
                            complete(.failure(.apiResponse(message: "Failed to add repo: \(error)")))
                        }
                    }
                case .failure(let error):
                    complete(.failure(.network(error)))
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

    private func createOrganization(name organizationName: String) -> Promise<LonaOrganization, NSError> {
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

                    complete(.success(LonaOrganization(id: organizationId, name: organizationName)))
                case .failure(let error):
                    complete(.failure(NSError(error.localizedDescription)))
                }
            }
        }
    }
}
