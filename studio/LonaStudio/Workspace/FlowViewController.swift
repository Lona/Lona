//
//  FlowViewController.swift
//
//  Created by Devin Abbott on 2/11/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar

// MARK: - FlowViewController

class FlowViewController<State: Equatable>: NSViewController {

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

    public var history = History<State>() { didSet { update() } }

    public var flowTitle: String {
        get { contentView?.window?.title ?? "" }
        set { contentView?.window?.title = newValue }
    }

    public var showsProgressIndicator = false {
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

    public var contentView: NSView? {
        didSet {
            if oldValue != contentView {
                oldValue?.removeFromSuperview()

                if let contentView = contentView {
                    scrollView.documentView = contentView

                    scrollViewMinimumHeightConstraint = scrollView.heightAnchor.constraint(greaterThanOrEqualTo: contentView.heightAnchor, constant: 80)
                    scrollViewMinimumHeightConstraint?.priority = .required - 1
                    scrollViewMinimumHeightConstraint?.isActive = true

                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.widthAnchor.constraint(equalToConstant: 720 - 80).isActive = true
                }
            }
        }
    }

    public func forceUpdate() {
        update()
    }

    public var makeContentView: () -> NSView = { return NSView() }

    // MARK: Private

    private let containerView = NSBox()

    private let navigationControl = NavigationControl()

    private let progressIndicator = NSProgressIndicator()

    private var scrollViewMinimumHeightConstraint: NSLayoutConstraint?
    private var contentViewTopAnchorConstraint: NSLayoutConstraint?

    private var showNavigationControl: Bool = false

    private let scrollView = FlippedScrollView()

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero
        containerView.fillColor = Colors.windowBackground

        containerView.addSubview(navigationControl)

        containerView.addSubview(progressIndicator)

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = .init(top: 40, left: 40, bottom: 40, right: 40)
        scrollView.scrollerInsets = .init(top: -40, left: -40, bottom: -40, right: -40)

        containerView.addSubview(scrollView)

        navigationControl.fillColor = Colors.contentBackground
        navigationControl.cornerRadius = 2
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        containerView.widthAnchor.constraint(equalToConstant: 720).isActive = true
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        containerView.heightAnchor.constraint(lessThanOrEqualToConstant: 816).isActive = true

        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        progressIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 44).isActive = true
        progressIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        progressIndicator.controlSize = .small
    }

    private func update() {
        let newContentView = makeContentView()

        // A small hack to prevent transitioning between the same State twice.
        // This allows us to store screen variables (i.e. user input values) directly on the screen instance.
        // If we need to allow transitions between the same State, a better approach could be to store screens variables
        // in the State object, and update the old screen instance as needed, without unmounting.
        if newContentView.className != contentView?.className {
            contentView = newContentView
        }

        progressIndicator.isHidden = !showsProgressIndicator

        navigationControl.isBackEnabled = history.canGoBack()
        navigationControl.isForwardEnabled = history.canGoForward()
        navigationControl.isHidden = !showNavigationControl

        navigationControl.removeFromSuperview()
        containerView.addSubview(navigationControl)
        navigationControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32).isActive = true

        let topInset: CGFloat = showNavigationControl ? 80 : 40

        scrollView.contentInsets = .init(top: topInset, left: 40, bottom: 40, right: 40)
        scrollView.scrollerInsets = .init(top: -topInset, left: -40, bottom: -40, right: -40)
        scrollViewMinimumHeightConstraint?.constant = topInset + 40
        contentViewTopAnchorConstraint?.constant = topInset + 40

        if let contentView = self.contentView, let window = contentView.window {
            // Try to set the window dimensions to zero.
            // Autolayout will snap it back to the minimum size allowed based on the contentView's contraints.
            window.setContentSize(.zero)
        }
    }

    override func viewDidAppear() {
        guard let window = contentView?.window else { return }

        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
