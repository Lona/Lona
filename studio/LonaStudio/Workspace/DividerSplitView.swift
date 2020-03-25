//
//  DividerSplitView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

public class DividerSplitView: NSSplitView {

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

    public var dividerView: NSView? {
        didSet {
            if let splitterView = dividerView {
                if splitterView != oldValue {
                    oldValue?.removeFromSuperview()

                    dividerContainerView.addSubview(splitterView)

                    splitterView.translatesAutoresizingMaskIntoConstraints = false

                    splitterView.centerYAnchor.constraint(equalTo: dividerContainerView.centerYAnchor).isActive = true
                    splitterView.centerXAnchor.constraint(equalTo: dividerContainerView.centerXAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    // MARK: Private

    private var dividerContainerView = NSView()

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
        bottomDividerView.fillColor = Colors.divider

        addSubview(dividerContainerView)
        dividerContainerView.addSubview(topDividerView)
        dividerContainerView.addSubview(bottomDividerView)
    }

    private func setUpConstraints() {
        topDividerView.translatesAutoresizingMaskIntoConstraints = false
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false

        topDividerView.topAnchor.constraint(equalTo: dividerContainerView.topAnchor).isActive = true
        topDividerView.leadingAnchor.constraint(equalTo: dividerContainerView.leadingAnchor).isActive = true
        topDividerView.trailingAnchor.constraint(equalTo: dividerContainerView.trailingAnchor).isActive = true
        topDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        bottomDividerView.bottomAnchor.constraint(equalTo: dividerContainerView.bottomAnchor).isActive = true
        bottomDividerView.leadingAnchor.constraint(equalTo: dividerContainerView.leadingAnchor).isActive = true
        bottomDividerView.trailingAnchor.constraint(equalTo: dividerContainerView.trailingAnchor).isActive = true
        bottomDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    // MARK: Overrides

    override public var dividerThickness: CGFloat { return 32 }

    override public func drawDivider(in rect: NSRect) {
        dividerContainerView.frame = rect
    }

    override public func hitTest(_ point: NSPoint) -> NSView? {
        for view in dividerContainerView.subviews {
            guard let superview = superview, let parent = view.superview else { continue }

            let convertedPoint = parent.convert(point, from: superview)

            if let result = view.hitTest(convertedPoint) {
                return result
            }
        }

        return super.hitTest(point)
    }
}
