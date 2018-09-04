//
//  CodeEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/1/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - CodeEditorViewController

class CodeEditorViewController: NSViewController {

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

    public var document: NSDocument? { didSet { update() } }

    // MARK: Private

    private let contentView = NSTextField(frame: .zero)

    private func setUpViews() {
        contentView.focusRingType = .none
        contentView.isBezeled = false
        contentView.isEditable = false
        contentView.isSelectable = true
        contentView.font = TextStyles.monospacedMicro.nsFont

        self.view = contentView
    }

    private func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func update() {
        if let document = document as? JSONDocument {
            if let content = document.content, case .colors = content {
                guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
                guard let data = try? document.data(ofType: "JSONDocument") else { return }

                LonaNode.run(
                    arguments: [compilerPath, "colors", "swift"],
                    inputData: data,
                    onSuccess: { result in
                        guard let result = result else { return }
                        DispatchQueue.main.async {
                            self.contentView.stringValue = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })
            }
        }
    }
}
