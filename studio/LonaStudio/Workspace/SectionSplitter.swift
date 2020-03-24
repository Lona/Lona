//
//  SectionSplitter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

public class SectionSplitter: NSSplitView {

    // MARK: Lifecycle

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()
        setUpConstraints()
    }

    // MARK: Public

    public var splitterView: NSView? {
        didSet {
            if let splitterView = splitterView {
                if splitterView != oldValue {
                    oldValue?.removeFromSuperview()

                    splitterContainerView.addSubview(splitterView)

                    splitterView.translatesAutoresizingMaskIntoConstraints = false

                    splitterView.centerYAnchor.constraint(equalTo: splitterContainerView.centerYAnchor).isActive = true
                    splitterView.centerXAnchor.constraint(equalTo: splitterContainerView.centerXAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    // MARK: Private

    private var splitterContainerView = NSView()

    private let topDividerView = NSBox()

    private let bottomDividerView = NSBox()

    private func setUpViews() {
        arrangesAllSubviews = false

        topDividerView.boxType = .custom
        topDividerView.borderType = .noBorder
        topDividerView.contentViewMargins = .zero
        topDividerView.fillColor = Colors.divider

        bottomDividerView.boxType = .custom
        bottomDividerView.borderType = .noBorder
        bottomDividerView.contentViewMargins = .zero
//        bottomDividerView.fillColor = Colors.divider

        addSubview(splitterContainerView)
        splitterContainerView.addSubview(topDividerView)
        splitterContainerView.addSubview(bottomDividerView)
    }

    private func setUpConstraints() {
        topDividerView.translatesAutoresizingMaskIntoConstraints = false
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false

        topDividerView.topAnchor.constraint(equalTo: splitterContainerView.topAnchor).isActive = true
        topDividerView.leadingAnchor.constraint(equalTo: splitterContainerView.leadingAnchor).isActive = true
        topDividerView.trailingAnchor.constraint(equalTo: splitterContainerView.trailingAnchor).isActive = true
        topDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        bottomDividerView.bottomAnchor.constraint(equalTo: splitterContainerView.bottomAnchor).isActive = true
        bottomDividerView.leadingAnchor.constraint(equalTo: splitterContainerView.leadingAnchor).isActive = true
        bottomDividerView.trailingAnchor.constraint(equalTo: splitterContainerView.trailingAnchor).isActive = true
        bottomDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    // MARK: Overrides

    override public var dividerThickness: CGFloat { return 44 }

    override public func drawDivider(in rect: NSRect) {
        splitterContainerView.frame = rect
    }

    override public func hitTest(_ point: NSPoint) -> NSView? {
        for view in splitterContainerView.subviews {
            guard let superview = superview, let parent = view.superview else { continue }

            let convertedPoint = parent.convert(point, from: superview)

            if let result = view.hitTest(convertedPoint) {
                return result
            }
        }

        return super.hitTest(point)
    }
}
