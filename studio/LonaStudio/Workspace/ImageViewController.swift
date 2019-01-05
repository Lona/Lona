//
//  ImageViewController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 05/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - ImageViewController

class ImageViewController: NSViewController {

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

    // MARK: Private

    private let contentView = ImageViewer()

    private func setUpViews() {
        self.view = contentView
    }

    private func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        if let image = image {
            contentView.imageData = image
            contentView.dimensions = "\(image.size.width)px * \(image.size.height)px"
        } else {
            contentView.imageData = nil
            contentView.dimensions = ""
        }
    }
}
