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
//    var wc: NSWindowController? = nil

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

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
        if data != nil {
            let viewController = windowController.contentViewController as! ViewController
            viewController.setComponent(component: data!)
            viewController.fileURL = fileURL
        }

        if let file = file {
            let viewController = windowController.contentViewController as! ViewController
            viewController.setComponent(component: file)
            viewController.fileURL = fileURL
        }

        self.addWindowController(windowController)

        if #available(OSX 10.12, *) {
            let windows = self.windowControllers.map({ $0.window })
            windows.forEach({ $0?.mergeAllWindows(self) })
        } else {
            // Fallback on earlier versions
        }

        controller = windowController

        Swift.print("Created window controller", windowController)
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
        Swift.print("url", url)

        name = url.deletingPathExtension().lastPathComponent

        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions())

            try read(from: data, ofType: "DocumentType")
        } catch {
            Swift.print(error)
        }
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return }

        file = CSComponent(CSData.from(json: json))

        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {

        LonaPlugins.current.pluginFilesActivatingOn(eventType: .onSaveComponent).forEach({
            $0.run(onSuccess: {_ in })
        })

        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
    }
}
