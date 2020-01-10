//
//  AppDelegate.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa
import LetsMove
import MASPreferences

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var applicationDidLaunch = false

    let documentController = DocumentController()

    func applicationWillFinishLaunching(_ notification: Notification) {
//        if #available(OSX 10.14, *) {
//            NSApp.appearance = NSAppearance(named: .aqua)
//        }
        #if DEBUG
        #else
            PFMoveToApplicationsFolderIfNecessary()
        #endif
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !documentController.didOpenADocument {
            showWelcomeWindow(self)
        }

        applicationDidLaunch = true
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showWelcomeWindow(self)
            return true
        }
        return false
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filename)

        DocumentController.shared.openDocument(withContentsOf: fileURL, display: true, completionHandler: { document, _, error in
            Swift.print(document, error)
        })

        return true
    }

    private static var preferencesWindow: MASPreferencesWindowController?

    public static func reloadPreferencesWindow() {
        preferencesWindow?.viewControllers.forEach { viewController in
            if let workspacePreferences = viewController as? WorkspacePreferencesViewController {
                workspacePreferences.render()
            }
        }
    }

    @IBAction func showPreferences(_ sender: AnyObject) {
        if AppDelegate.preferencesWindow == nil {
            let workspace = WorkspacePreferencesViewController()
            workspace.viewDidLoad()

            AppDelegate.preferencesWindow = MASPreferencesWindowController(viewControllers: [workspace], title: "Preferences")
        }

        AppDelegate.reloadPreferencesWindow()

        AppDelegate.preferencesWindow?.showWindow(sender)
    }

    @IBAction func showWorkspaceWindow(_ sender: AnyObject) {
        if let document = openWorkspaceDocument() {
            showComponentBrowser(document)
        }
    }

    func showComponentBrowser(_ document: NSDocument?) {
        let windowController = WorkspaceWindowController.create(andAttachTo: document)

        // Throws an exception related to _NSDetectedLayoutRecursion without async here.
        // With async, it becomes a warning.
        DispatchQueue.main.async {
            windowController.showWindow(self)
        }
    }

    private static func createSheetWindow(size: NSSize) -> NSWindow {
        let sheetWindow = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled],
            backing: .buffered,
            defer: false,
            screen: nil)

        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .ultraDark
        visualEffectView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        sheetWindow.contentView = visualEffectView

        return sheetWindow
    }

    var welcomeWindow: NSWindow?

    @IBAction func showWelcomeWindow(_ sender: AnyObject) {
        if welcomeWindow == nil {
            let size = NSSize(width: 720, height: 460)
            let initialRect = NSRect(origin: .zero, size: size)
            let window = NSWindow(contentRect: initialRect, styleMask: [.closable, .titled, .fullSizeContentView], backing: .buffered, defer: false)
            window.center()
            window.title = "Welcome"
            window.isReleasedWhenClosed = false
            window.minSize = size
            window.isMovableByWindowBackground = true
            window.hasShadow = true
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = NSColor.white
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.closeButton)?.backgroundFill = CGColor.clear

            let view = NSBox()
            view.boxType = .custom
            view.borderType = .noBorder
            view.contentViewMargins = .zero
            view.translatesAutoresizingMaskIntoConstraints = false

            window.contentView = view

            // Set up welcome screen

            let welcome = Welcome()

            view.addSubview(welcome)

            welcome.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            welcome.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            welcome.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            welcome.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

            welcome.onCreateProject = {
                let sheetWindow = AppDelegate.createSheetWindow(size: .init(width: 924, height: 635))
                let templateBrowser = TemplateBrowser()
                sheetWindow.contentView = templateBrowser

                templateBrowser.onClickDone = {
                    guard let url = self.createWorkspaceDialog() else { return }

                    if !DocumentController.shared.createWorkspace(url: url, workspaceTemplate: .designTokens) {
                        Swift.print("Failed to create workspace")
                        return
                    }

                    DocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { document, _, _ in
                        if let _ = document {
                            window.close()
                        }
                    })
                }

                templateBrowser.onClickCancel = {
                    self.welcomeWindow?.endSheet(sheetWindow)
                }

                self.welcomeWindow?.beginSheet(sheetWindow)
            }

            welcome.onOpenProject = {
                guard let url = self.openWorkspaceDialog() else { return }

                DocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { document, _, _ in
                    if let _ = document {
                        window.close()
                    }
                })
            }

            welcome.onOpenExample = {
                guard let url = URL(string: "https://github.com/airbnb/Lona/tree/master/examples/material-design") else { return }
                NSWorkspace.shared.open(url)
            }

            welcome.onOpenDocumentation = {
                guard let url = URL(string: "https://github.com/airbnb/Lona/blob/master/README.md") else { return }
                NSWorkspace.shared.open(url)
            }

            welcomeWindow = window
        }

        welcomeWindow?.makeKeyAndOrderFront(nil)
    }

    /*  Create a new component by duplicating the contents of an existing component
        into a blank document, and opening the document.
    */
    @IBAction func newFromTemplate(_ sender: AnyObject) {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a .component file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["component"]

        guard
            dialog.runModal() == NSApplication.ModalResponse.OK,
            let url = dialog.url
        else { return }

        do {
            guard let document = try NSDocumentController.shared.openUntitledDocumentAndDisplay(true) as? ComponentDocument else { return }

            let componentLayer = CSComponentLayer.make(from: url)
            let component = CSComponent.makeDefaultComponent()
            component.rootLayer = componentLayer

            document.set(component: component)
        } catch {
            Swift.print("Failed to duplicate template", url)
        }

    }

    // MARK: - Opening Workspaces

    private func openWorkspaceDialog() -> URL? {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a workspace"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false

        guard dialog.runModal() == NSApplication.ModalResponse.OK else { return nil }

        return dialog.url
    }

    private func openWorkspaceDocument() -> NSDocument? {
        let url = LonaModule.current.url

        guard let newDocument = try? NSDocumentController.shared.makeDocument(withContentsOf: url, ofType: "DirectoryDocument") else {
            Swift.print("Failed to open", url)
            return nil
        }

        NSDocumentController.shared.addDocument(newDocument)

        return newDocument
    }



    // MARK: - Creating Workspaces

    private func createWorkspaceDialog() -> URL? {
        let dialog = NSSavePanel()

        dialog.title                   = "Create a workspace directory"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            return dialog.url
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }

    // MARK: - Reloading

    @IBAction func reload(_ sender: AnyObject) {
        CSUserTypes.reload()
        CSColors.reload()
        CSTypography.reload()
        CSGradients.reload()
        CSShadows.reload()

        LonaPlugins.current.trigger(eventType: .onReloadWorkspace)
    }
}
