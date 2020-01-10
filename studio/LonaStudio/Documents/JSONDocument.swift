//
//  JSONDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/25/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class JSONDocument: NSDocument {
    struct TextStylesFile {
        var styles: [CSTextStyle]
        var defaultStyleName: String?
    }

    enum Content {
        case colors([CSColor])
        case textStyles(TextStylesFile)
    }

    override init() {
        super.init()

        self.hasUndoManager = true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var autosavingFileType: String? {
        return nil
    }

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var content: Content?

    override func makeWindowControllers() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)
    }

    override func showWindows() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)

        super.showWindows()
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let content = content else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        switch content {
        case .colors(let colors):
            do {
                let data = CSData.Object(["colors": colors.toData()])

                if let data = data.toData() {
                    return data
                } else {
                    throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
            } catch {
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
        case .textStyles(let textStylesFile):
            do {
                var data = CSData.Object([
                    "styles": CSData.Array(textStylesFile.styles.map({ $0.toData() }))
                    ])

                if let defaultStyleName = textStylesFile.defaultStyleName {
                    data["defaultStyleName"] = defaultStyleName.toData()
                }

                if let data = data.toData() {
                    return data
                } else {
                    throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
            } catch {
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let name = url.deletingPathExtension().lastPathComponent

        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions())

            guard let csData = CSData.from(data: data) else {
                throw NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorCannotOpenFile,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to parse \(url)."])
            }

            switch name {
            case "colors":
                content = Content.colors(CSColors.parse(csData))
            case "textStyles":
                let textStyleFile = TextStylesFile(
                    styles: CSTypography.parse(csData),
                    defaultStyleName: CSTypography.parseDefaultName(csData))
                content = Content.textStyles(textStyleFile)
            default:
                content = nil
            }
        } catch {
            Swift.print(error)
        }
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {

        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)

        guard let content = content else {
            return
        }

        switch content {
        case .colors:
            LonaPlugins.current.trigger(eventType: .onSaveColors)
        case .textStyles:
            LonaPlugins.current.trigger(eventType: .onSaveTextStyles)
        }
    }
}
