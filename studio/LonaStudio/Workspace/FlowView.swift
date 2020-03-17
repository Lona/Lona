//
//  FlowView.swift
//
//  Created by Devin Abbott on 2/11/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar

// MARK: - FlowView

class FlowView: NSBox {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

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

    public var onClickBack: (() -> Void)? {
        get { return navigationControl.onClickBack }
        set { navigationControl.onClickBack = newValue }
    }

    public var onClickForward: (() -> Void)? {
        get { return navigationControl.onClickForward }
        set { navigationControl.onClickForward = newValue }
    }

    public var isBackEnabled: Bool {
        get { return navigationControl.isBackEnabled }
        set { navigationControl.isBackEnabled = newValue }
    }

    public var isForwardEnabled: Bool {
        get { return navigationControl.isForwardEnabled }
        set { navigationControl.isForwardEnabled = newValue }
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

    public var showsNavigationControl: Bool = false {
        didSet {
            if oldValue != showsNavigationControl {
                update()
            }
        }
    }

    public var screenView: NSView? {
        didSet {
            if oldValue != screenView {
                oldValue?.removeFromSuperview()

                if let screenView = screenView {
                    scrollView.documentView = screenView

                    scrollViewMinimumHeightConstraint = scrollView.heightAnchor.constraint(greaterThanOrEqualTo: screenView.heightAnchor, constant: 80)
                    scrollViewMinimumHeightConstraint?.priority = .required - 1
                    scrollViewMinimumHeightConstraint?.isActive = true

                    screenView.translatesAutoresizingMaskIntoConstraints = false
                    screenView.widthAnchor.constraint(equalToConstant: 720 - 80).isActive = true
                }

                update()
            }
        }
    }

    public func forceUpdate() {
        update()
    }

    // MARK: Private

    private let navigationControl = NavigationControl()

    private let progressIndicator = NSProgressIndicator()

    private var scrollViewMinimumHeightConstraint: NSLayoutConstraint?
    private var screenViewTopAnchorConstraint: NSLayoutConstraint?

    private let scrollView = FlippedScrollView()

    private func setUpViews() {
        let containerView = self
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

        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = true
    }

    private func setUpConstraints() {
        let containerView = self
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
        let containerView = self

        progressIndicator.isHidden = !showsProgressIndicator

        navigationControl.isHidden = !showsNavigationControl

        navigationControl.removeFromSuperview()
        containerView.addSubview(navigationControl)
        navigationControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32).isActive = true

        let topInset: CGFloat = showsNavigationControl ? 80 : 40

        scrollView.contentInsets = .init(top: topInset, left: 40, bottom: 40, right: 40)
        scrollView.scrollerInsets = .init(top: -topInset, left: -40, bottom: -40, right: -40)
        scrollViewMinimumHeightConstraint?.constant = topInset + 40
        screenViewTopAnchorConstraint?.constant = topInset + 40

        if let screenView = self.screenView, let window = screenView.window {
            // Try to set the window dimensions to zero.
            // Autolayout will snap it back to the minimum size allowed based on the screenView's contraints.
            window.setContentSize(.zero)
        }
    }

    // Prevent the user from taking any action when awaiting an async event
    override func hitTest(_ point: NSPoint) -> NSView? {
        if showsProgressIndicator { return nil }

        return super.hitTest(point)
    }
}

// MARK: - Promise Helper

extension FlowView {
    public func withProgress<S, F>(_ f: () -> Promise<S, F>) -> Promise<S, F> {
        self.showsProgressIndicator = true

        return f().onResult({ result in
            self.showsProgressIndicator = false

            return .result(result)
        })
    }

    public func withProgress<S, F>(_ promise: Promise<S, F>) {
        self.showsProgressIndicator = true

        return promise.finalResult({ _ in
            DispatchQueue.main.async {
                self.showsProgressIndicator = false
            }
        })
    }
}
