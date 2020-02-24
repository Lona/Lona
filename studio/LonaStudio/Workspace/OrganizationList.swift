//
//  OrganizationList.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/18/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Apollo

// MARK: - OrganizationList

public class OrganizationList: NSBox {

    // MARK: Lifecycle

    public init(_ parameters: Parameters) {
        self.parameters = parameters

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init(organizationIds: [String]) {
        self.init(Parameters(organizationIds: organizationIds))
    }

    public convenience init() {
        self.init(Parameters())
    }

    public required init?(coder aDecoder: NSCoder) {
        self.parameters = Parameters()

        super.init(coder: aDecoder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var organizationIds: [String] {
        get { return parameters.organizationIds }
        set {
            if parameters.organizationIds != newValue {
                parameters.organizationIds = newValue
            }
        }
    }

    public var onSelectOrganizationId: ((String) -> Void)? {
        get { return parameters.onSelectOrganizationId }
        set { parameters.onSelectOrganizationId = newValue }
    }

    public var parameters: Parameters {
        didSet {
            if parameters != oldValue {
                update()
            }
        }
    }

    // MARK: Private

    private var organizations: [PublishingViewController.Organization] = [] {
        didSet {
            update()
        }
    }

    private var stackView = NSStackView()
    private let scrollView = NSScrollView()
    private let flippedView = FlippedView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        stackView.orientation = .vertical

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.documentView = flippedView

        flippedView.addSubview(stackView)

        addSubview(scrollView)

        Network.shared.lona.fetch(query: GetMeQuery()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print(errors)
                    return
                }

                guard let organizations = graphQLResult.data?.getMe?.organizations else { return }

                self.organizations = organizations.map { PublishingViewController.Organization(id: $0.id, name: $0.name) }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        scrollView.contentView.leadingAnchor.constraint(equalTo: flippedView.leadingAnchor).isActive = true
        scrollView.contentView.trailingAnchor.constraint(equalTo: flippedView.trailingAnchor).isActive = true

        flippedView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        flippedView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        flippedView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        flippedView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true

        let scrollViewMinimumHeightConstraint = scrollView.heightAnchor.constraint(greaterThanOrEqualTo: stackView.heightAnchor)
        scrollViewMinimumHeightConstraint.priority = .defaultHigh
        scrollViewMinimumHeightConstraint.isActive = true

        stackView.setHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        organizationIds.forEach { id in
            let organizationView = PrimaryButton(titleText: organizations.first(where: { $0.id == id })?.name ?? "", disabled: false)
            organizationView.onClick = { [unowned self] in self.onSelectOrganizationId?(id) }

            stackView.addArrangedSubview(organizationView, stretched: true)
        }
    }

    private func handleOnSelectOrganizationId(_ arg0: String) {
        onSelectOrganizationId?(arg0)
    }
}

// MARK: - Parameters

extension OrganizationList {
    public struct Parameters: Equatable {
        public var organizationIds: [String]
        public var onSelectOrganizationId: ((String) -> Void)?

        public init(organizationIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
            self.organizationIds = organizationIds
            self.onSelectOrganizationId = onSelectOrganizationId
        }

        public init() {
            self.init(organizationIds: [])
        }

        public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
            return lhs.organizationIds == rhs.organizationIds
        }
    }
}

// MARK: - Model

extension OrganizationList {
    public struct Model: LonaViewModel, Equatable {
        public var id: String?
        public var parameters: Parameters
        public var type: String {
            return "OrganizationList"
        }

        public init(id: String? = nil, parameters: Parameters) {
            self.id = id
            self.parameters = parameters
        }

        public init(_ parameters: Parameters) {
            self.parameters = parameters
        }

        public init(organizationIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
            self.init(Parameters(organizationIds: organizationIds, onSelectOrganizationId: onSelectOrganizationId))
        }

        public init() {
            self.init(organizationIds: [])
        }
    }
}
