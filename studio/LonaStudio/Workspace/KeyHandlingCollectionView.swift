//
//  KeyHandlingCollectionView.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 05/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class KeyHandlingCollectionView: NSCollectionView {
    public var onDeleteItem: ((Int) -> Void)?
    public var onCopy: ((Int) -> Void)?

    @IBAction func copy(_ sender: AnyObject) {
        guard let item = selectionIndexPaths.first?.item else { return }

        onCopy?(item)
    }

    override func keyDown(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers,
            let item = selectionIndexPaths.first?.item else { return }

        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            onDeleteItem?(item)
        }
    }
}
