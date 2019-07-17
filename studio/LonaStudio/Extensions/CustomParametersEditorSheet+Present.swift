//
//  CustomParametersEditorSheet+Present.swift
//  LonaStudio
//
//  Created by Devin Abbott on 7/11/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

extension CustomParametersEditorSheet {
    func present(
        contentView: NSView,
        in parentViewController: NSViewController,
        onSubmit: (() -> Void)?,
        onCancel: (() -> Void)?) {

        customContentView.addSubview(contentView)

        contentView.topAnchor.constraint(equalTo: customContentView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor).isActive = true

        let viewController = NSViewController(view: self)

        parentViewController.presentAsSheet(viewController)

        self.onSubmit = {
            parentViewController.dismiss(viewController)
            onSubmit?()
        }

        self.onCancel = {
            parentViewController.dismiss(viewController)
            onCancel?()
        }
    }
}
