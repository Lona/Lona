//
//  DocumentController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 09/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class DocumentController: NSDocumentController {
    public var didOpenADocument = false
    override public func reopenDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        if FileUtils.fileExists(atPath: contentsURL.path) == .directory {
            guard let newDocument = try? DirectoryDocument(contentsOf: contentsURL, ofType: "Directory Document") else {
                completionHandler(nil, false, NSError(domain: NSCocoaErrorDomain, code: 256, userInfo: [
                    NSLocalizedDescriptionKey: "\(contentsURL) could not be handled because LonaStudio cannot open files of this type.",
                    NSLocalizedFailureReasonErrorKey: "LonaStudio cannot open files of this type."]))
                return
            }

            didOpenADocument = true
            completionHandler(newDocument, false, nil)
        } else {
            super.reopenDocument(for: urlOrNil, withContentsOf: contentsURL, display: displayDocument, completionHandler: { document, alreadyOpened, error in
                if error == nil {
                    self.didOpenADocument = true
                }
                completionHandler(document, alreadyOpened, error)
            })
        }
    }
}
