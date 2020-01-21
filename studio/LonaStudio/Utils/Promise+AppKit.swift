//
//  Promise+AppKit.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/14/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

extension NSDocumentController {
    @discardableResult public func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool
    ) -> Promise<NSDocument, NSError> {
        return .result { complete in
            self.openDocument(withContentsOf: url, display: displayDocument, completionHandler: { document, _, error in
                if let error = error {
                    complete(.failure(error as NSError))
                } else {
                    complete(.success(document!))
                }
            })
        }
    }
}

extension NSDocument {
    @discardableResult public func save(
        to url: URL,
        ofType type: String,
        for saveOperation: NSDocument.SaveOperationType
    ) -> Promise<NSDocument, NSError> {
        return Promise<Void, NSError>.result { completed in
            self.save(to: url, ofType: type, for: saveOperation, completionHandler: { error in
                if let error = error {
                    return completed(.failure(error as NSError))
                } else {
                    return completed(.success(self))
                }
            })
        }
    }
}
