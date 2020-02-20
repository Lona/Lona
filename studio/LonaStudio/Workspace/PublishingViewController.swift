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

    // MARK: Static

    static var shared = PublishingViewController()

    // MARK: Types

    private enum State: Equatable {
        case needsAuth
        case needsOrg
        case chooseOrg(organizations: [Organization])
        case needsRepo(organization: Organization)
        case createRepo(organization: Organization, githubOrganizations: [Organization])
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
        workspaceName = CSWorkspacePreferences.workspaceName
        update()

//        Git.status()

        if Account.shared.signedIn {
            fetchOrganizations().finalResult({ [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let organizations):
                    if organizations.isEmpty {
                        self.history.navigateTo(.needsOrg)
                    } else {
                        self.history.navigateTo(.chooseOrg(organizations: organizations))
                    }
                case .failure(let error):
                    Swift.print("Failed to fetch organizations:", error)
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
        case .needsOrg:
            let screen = PublishNeedsOrg(workspaceName: workspaceName, organizationName: "")
            screen.onChangeTextValue = { [unowned screen] value in
                screen.organizationName = value
            }
            screen.onClickSubmit = { [unowned self] in
                self.createOrganization(name: screen.organizationName).finalSuccess({ [weak self] organization in
                    self?.history.navigateTo(.needsRepo(organization: organization))
                })
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
                        let sshURL = URL(string: url.appendingPathExtension("git").absoluteString.replacingOccurrences(of: "https://github.com/", with: "git@github.com:"))!

                        let gitResult = Git.client
                            .addRemote(name: "lona", url: sshURL)
//                            .flatMap({ _ in Git.client.push(repository: "lona", refspec: "HEAD") })

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
            let screen = PublishChooseOrg(workspaceName: workspaceName, organizationName: "", organizationIds: organizationIds)
            screen.onChangeTextValue = { [unowned screen] value in
                screen.organizationName = value
            }
            screen.onClickSubmit = { [unowned self] in
                self.createOrganization(name: screen.organizationName).finalResult({ [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let organization):
                        self.history.navigateTo(.needsRepo(organization: organization))
                    case .failure(let error):
                        Swift.print("Failed to create organization:", error)
                    }
                })
            }
            screen.onSelectOrganizationId = { [unowned self] id in
                guard let organization = organizations.first(where: { $0.id == id }) else { return }

                self.history.navigateTo(.needsRepo(organization: organization))
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

// MARK: - API

extension PublishingViewController {

    private func fetchOrganizations() -> Promise<[Organization], NSError> {
        self.showsProgressIndicator = true
        return Account.shared.me().onSuccess { [weak self] result in
            guard let self = self else { return .failure(NSError("Missing self")) }

            self.showsProgressIndicator = false

            return .success(result.organisations.map { Organization(id: $0.id, name: $0.name) })
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

                    var organisations = [Organization(id: data.id, name: data.login)]

                    data.organizations.nodes?.forEach { org in
                      if let org = org {
                        organisations.append(Organization(id: org.id, name: org.login))
                      }
                    }

                    complete(.success(organisations))
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
                organisationId: organizationId,
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

            Network.shared.lona.perform(mutation: CreateOrganisationMutation(name: organizationName)) { [weak self] result in
                guard let self = self else { return }

                self.showsProgressIndicator = false

                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        complete(.failure(NSError(errors.description)))
                        return
                    }

                    guard
                        let organizationName = graphQLResult.data?.createOrganisation.organisation?.name,
                        let organizationId = graphQLResult.data?.createOrganisation.organisation?.id
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
