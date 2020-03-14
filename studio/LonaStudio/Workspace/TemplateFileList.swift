//
//  TemplateFileList.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/9/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - TemplateFileList

public class TemplateFileList: NSBox {

    // MARK: Lifecycle

    public init(_ parameters: Parameters) {
        self.parameters = parameters

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init(fileNames: [String]) {
        self.init(Parameters(fileNames: fileNames))
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

    public var fileNames: [String] {
        get { return parameters.fileNames }
        set {
            if parameters.fileNames != newValue {
                parameters.fileNames = newValue
            }
        }
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

    private func getFileTitle(url: URL) -> String {
        if url.hasMarkdownExtension() {
            if url.path == "/README.md" {
                return "Index page"
            }

            return "\(url.deletingPathExtension().lastPathComponent) page"
        }

        return url.lastPathComponent
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        fileNames.filter({ $0 != "lona.json" && !$0.hasPrefix(".github") }).forEach { fileName in
            let url = URL(fileURLWithPath: fileName, relativeTo: URL(fileURLWithPath: "/"))
            let title = getFileTitle(url: url)
            let subtitle = String(url.path.dropFirst())
            let organizationView = TemplateFileCard(titleText: title, subtitleText: subtitle)
            stackView.addArrangedSubview(organizationView, stretched: true)
        }
    }
}

// MARK: - Parameters

extension TemplateFileList {
    public struct Parameters: Equatable {
        public var fileNames: [String]

        public init(fileNames: [String]) {
            self.fileNames = fileNames
        }

        public init() {
            self.init(fileNames: [])
        }

        public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
            return lhs.fileNames == rhs.fileNames
        }
    }
}

// MARK: - Model

extension TemplateFileList {
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

        public init(fileNames: [String]) {
            self.init(Parameters(fileNames: fileNames))
        }

        public init() {
            self.init(fileNames: [])
        }
    }
}
