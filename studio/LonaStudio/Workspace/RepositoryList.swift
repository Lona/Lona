//
//  RepositoryList.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/4/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Apollo

// MARK: - RepositoryList

public class RepositoryList: NSBox {

    // MARK: Lifecycle

    public init(_ parameters: Parameters) {
        self.parameters = parameters

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init(repositoryIds: [String]) {
        self.init(Parameters(repositoryIds: repositoryIds))
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

    public var repositoryIds: [String] {
        get { return parameters.repositoryIds }
        set {
            if parameters.repositoryIds != newValue {
                parameters.repositoryIds = newValue
            }
        }
    }

    public var onSelectRepositoryId: ((String) -> Void)? {
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

    private var repositories: [LonaRepository] = [] {
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

        heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        repositoryIds.forEach { id in
            let organizationView = PrimaryButton(titleText: id, disabled: false)
            organizationView.onClick = { [unowned self] in self.onSelectRepositoryId?(id) }

            stackView.addArrangedSubview(organizationView, stretched: true)
        }
    }

    private func handleOnSelectOrganizationId(_ arg0: String) {
        onSelectRepositoryId?(arg0)
    }
}

// MARK: - Parameters

extension RepositoryList {
    public struct Parameters: Equatable {
        public var repositoryIds: [String]
        public var onSelectOrganizationId: ((String) -> Void)?

        public init(repositoryIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
            self.repositoryIds = repositoryIds
            self.onSelectOrganizationId = onSelectOrganizationId
        }

        public init() {
            self.init(repositoryIds: [])
        }

        public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
            return lhs.repositoryIds == rhs.repositoryIds
        }
    }
}

// MARK: - Model

extension RepositoryList {
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

        public init(repositoryIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
            self.init(Parameters(repositoryIds: repositoryIds, onSelectOrganizationId: onSelectOrganizationId))
        }

        public init() {
            self.init(repositoryIds: [])
        }
    }
}
