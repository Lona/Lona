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
        let url = URL(fileURLWithPath: filename)

        // Only allow opening files if we can find a workspace
        guard let workspaceUrl = LonaModule.findNearestWorkspace(containing: url) else {
            let alert = Alert(
                items: ["OK"],
                messageText: "Could not find workspace",
                informativeText: "The file '\(url.path)' is not a descendant of a workspace directory. A workspace directory contains a 'lona.json' file.")

            _ = alert.run()

            return false
        }

        if LonaModule.current.url != workspaceUrl {
            // If the application has already launched, prompt the user before switching workspaces.
            // Otherwise, switch workspaces automatically (e.g. double clicking a .component file in Finder)
            if applicationDidLaunch && url != workspaceUrl {
                let alert = Alert(
                    items: ["Cancel", "Yes"],
                    messageText: "Switch workspaces?",
                    informativeText: "The file '\(url.path)' is in a different workspace and can only be opened if we first switch workspaces. Do you want to switch workspaces and open the file?")

                let result = alert.run()

                if result != "Yes" {
                    return false
                }
            }

            if !setWorkspace(url: workspaceUrl) {
                return false
            }
        }

        switch FileUtils.fileExists(atPath: filename) {
        case .directory:
            guard let document = try? NSDocumentController.shared.makeDocument(withContentsOf: url, ofType: "DirectoryDocument") else {
                Swift.print("Failed to open", url)
                return false
            }

            NSDocumentController.shared.addDocument(document)

            showComponentBrowser(document)

            return true
        case .file:
            NSDocumentController.shared.openDocument(
                withContentsOf: url,
                display: true,
                completionHandler: { _, _, _ in })
            return true
        case .none:
            return false
        }
    }

    var preferencesWindow: MASPreferencesWindowController?

    private func reloadPreferencesWindow() {
        preferencesWindow?.viewControllers.forEach { viewController in
            if let workspacePreferences = viewController as? WorkspacePreferencesViewController {
                workspacePreferences.render()
            }
        }
    }

    @IBAction func showPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            let workspace = WorkspacePreferencesViewController()
            workspace.viewDidLoad()

            preferencesWindow = MASPreferencesWindowController(viewControllers: [workspace], title: "Preferences")
        }

        reloadPreferencesWindow()

        preferencesWindow?.showWindow(sender)
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
//        visualEffectView.translatesAutoresizingMaskIntoConstraints = true
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
                func finished(template: WorkspaceTemplate) {
                    guard let url = self.createWorkspaceDialog() else { return }

                    let ok = self.createWorkspace(url: url, workspaceTemplate: template)
                    if !ok {
                        Swift.print("Failed to create workspace")
                        return
                    }

                    if self.setWorkspace(url: url), let document = self.openWorkspaceDocument() {
                        window.close()
                        self.showComponentBrowser(document)
                    }
                }

                let sheetWindow = AppDelegate.createSheetWindow(size: .init(width: 924, height: 635))
                let templateBrowser = TemplateBrowser()
                sheetWindow.contentView = templateBrowser

                templateBrowser.onClickDone = {
                    finished(template: .designTokens)
                }

                templateBrowser.onClickCancel = {
                    self.welcomeWindow?.endSheet(sheetWindow)
                }

                self.welcomeWindow?.beginSheet(sheetWindow)
            }

            welcome.onOpenProject = {
                guard let url = self.openWorkspaceDialog() else { return }

                if self.setWorkspace(url: url), let document = self.openWorkspaceDocument() {
                    window.close()
                    self.showComponentBrowser(document)
                }
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

    private func setWorkspace(url: URL) -> Bool {
        if !CSWorkspacePreferences.validateProposedWorkspace(url: url) {
            return false
        }

        CSUserPreferences.workspaceURL = url

        NSDocumentController.shared.noteNewRecentDocumentURL(url)

        CSWorkspacePreferences.reloadAllConfigurationFiles(closeDocuments: true)

        reloadPreferencesWindow()

        return true
    }

    // MARK: - Creating Workspaces

    @IBAction func newWorkspace(_ sender: AnyObject) {
        guard let url = self.createWorkspaceDialog() else { return }

        let ok = self.createWorkspace(url: url, workspaceTemplate: .componentLibrary)
        if !ok {
            Swift.print("Failed to create workspace")
            return
        }

        if setWorkspace(url: url), let document = openWorkspaceDocument() {
            self.showComponentBrowser(document)
        }
    }

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

    private func createWorkspace(url: URL, workspaceTemplate: WorkspaceTemplate) -> Bool {
        do {
            try LonaModule.createWorkspace(at: url, using: workspaceTemplate)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to create workspace \(url.lastPathComponent) in \(url.deletingLastPathComponent().lastPathComponent)"
            alert.runModal()
            return false
        }

        return true
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
