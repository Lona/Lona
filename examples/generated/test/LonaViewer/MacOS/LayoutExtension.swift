//
//  LayoutExtension.swift
//
//  Created by Jason Zurita on 3/2/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import AppKit

typealias Constraint = (_ child: NSBox, _ parent: NSBox) -> NSLayoutConstraint

func constant<Anchor>(_ keyPath: KeyPath<NSBox, Anchor>, constant: CGFloat) -> Constraint where Anchor: NSLayoutDimension {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<NSBox, Anchor>, _ to: KeyPath<NSBox, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<NSBox, Anchor>, constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, keyPath, constant: constant)
}

extension NSBox {
    func addSubview(_ child: NSBox, constraints: [Constraint]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { $0(child, self) })
    }
}


