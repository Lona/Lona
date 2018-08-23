//
//  ComponentDocument.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

class ComponentDocument: NSDocument {

    override init() {
        super.init()

        // Add your subclass-specific initialization here.
        self.hasUndoManager = true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    var name: String = "Component"
    var file: CSComponent?

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var controller: NSWindowController?

    func set(component: CSComponent) {
        file = component

        guard let viewController = self.viewController else { return }
        viewController.component = component
        viewController.fileURL = fileURL
    }

    private let viewControllerId = NSStoryboard.SceneIdentifier(rawValue: "MainWorkspace")
    private let windowControllerId = NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")
    private let storyboardName = NSStoryboard.Name(rawValue: "Main")

    override func makeWindowControllers() {

        // This is a new document, so we need to initialize a component
        if file == nil {
            file = CSComponent.makeDefaultComponent()
        }

        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let workspaceViewController = storyboard.instantiateController(withIdentifier: viewControllerId) as! WorkspaceViewController
        workspaceViewController.component = file
        workspaceViewController.fileURL = fileURL

        let windowController = storyboard.instantiateController(withIdentifier: windowControllerId) as! NSWindowController
        windowController.window?.tabbingMode = .preferred
        windowController.contentViewController = workspaceViewController

        self.addWindowController(windowController)

        controller = windowController
    }

    override func writeSafely(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) throws {
        viewController?.fileURL = url
        try super.writeSafely(to: url, ofType: typeName, for: saveOperation)
    }

    override func data(ofType typeName: String) throws -> Data {
        if let file = file, let json = file.toData(), let data = json.toData() {
            return data
        }

        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        name = url.deletingPathExtension().lastPathComponent

        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions())

            try read(from: data, ofType: typeName)
        } catch {
            Swift.print(error)
        }
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return }

        file = CSComponent(CSData.from(json: json))
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {

        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)

        LonaPlugins.current.trigger(eventType: .onSaveComponent)
    }
}
