//
//  Document.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        self.hasUndoManager = true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    var name: String = "Component"
    var data: CSComponent?
    var file: CSComponent?

    var viewController: ViewController? {
        return windowControllers[0].contentViewController as? ViewController
    }

    var controller: NSWindowController?

    func set(component: CSComponent) {
        data = component

        guard let viewController = self.viewController else { return }
        viewController.setComponent(component: component)
        viewController.fileURL = fileURL
    }

    private let windowControllerId = NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")
    private let storyboardName = NSStoryboard.Name(rawValue: "Main")

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let windowController = storyboard.instantiateController(withIdentifier: windowControllerId) as! NSWindowController
        windowController.window?.tabbingMode = .preferred

        self.addWindowController(windowController)

        if data != nil {
            viewController?.setComponent(component: data!)
            viewController?.fileURL = fileURL
        }

        if let file = file {
            viewController?.setComponent(component: file)
            viewController?.fileURL = fileURL
        }

        controller = windowController
    }

    override func writeSafely(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) throws {
        viewController?.fileURL = url
        try super.writeSafely(to: url, ofType: typeName, for: saveOperation)
    }

    override func data(ofType typeName: String) throws -> Data {
        var component: CSComponent? = nil
        if controller != nil {
            let viewController = controller!.contentViewController as! ViewController
            component = viewController.component
        }
        if data != nil {
            component = data
        }
        if let component = component, let json = component.toData(), let data = json.toData() {
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
