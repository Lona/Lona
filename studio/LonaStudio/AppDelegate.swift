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

    func applicationWillFinishLaunching(_ notification: Notification) {
        if #available(OSX 10.14, *) {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
        #if DEBUG
        #else
            PFMoveToApplicationsFolderIfNecessary()
        #endif
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        showWelcomeWindow(self)
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showComponentBrowser(self)
            return true
        }
        return false
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)

        switch FileUtils.fileExists(atPath: filename) {
        case .directory:
            if openWorkspace(url: url) {
                welcomeWindow?.close()
                showComponentBrowser(self)
                return true
            } else {
                return false
            }
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

    @IBAction func showPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            let workspace = WorkspacePreferencesViewController()
            workspace.viewDidLoad()

            preferencesWindow = MASPreferencesWindowController(viewControllers: [workspace], title: "Preferences")
        }

        preferencesWindow?.showWindow(sender)
    }

    @IBAction func showComponentBrowser(_ sender: AnyObject) {
        let windowController = WorkspaceWindowController.create()

        // Throws an exception related to _NSDetectedLayoutRecursion without async here.
        // With async, it becomes a warning.
        DispatchQueue.main.async {
            windowController.showWindow(self)
        }
    }

    var welcomeWindow: NSWindow?

    @IBAction func showWelcomeWindow(_ sender: AnyObject) {
        if welcomeWindow == nil {
            let size = NSSize(width: 720, height: 460)
            let initialRect = NSRect(origin: .zero, size: size)
            let window = NSWindow(contentRect: initialRect, styleMask: [.closable, .titled, .fullSizeContentView], backing: .retained, defer: false)
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
                guard let url = self.createWorkspaceDialog() else { return }

                let ok = self.createWorkspace(url: url)
                if !ok {
                    Swift.print("Failed to create workspace")
                    return
                }

                if self.openWorkspace(url: url) {
                    window.close()
                    self.showComponentBrowser(self)
                }
            }

            welcome.onOpenProject = {
                guard let url = self.openWorkspaceDialog() else { return }

                if self.openWorkspace(url: url) {
                    window.close()
                    self.showComponentBrowser(self)
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

    private func openWorkspace(url: URL) -> Bool {
        if !CSWorkspacePreferences.validateProposedWorkspace(url: url) {
            return false
        }

        CSUserPreferences.workspaceURL = url

        NSDocumentController.shared.noteNewRecentDocumentURL(url)

        CSWorkspacePreferences.reloadAllConfigurationFiles(closeDocuments: true)

        return true
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

    private func createWorkspace(url: URL) -> Bool {
        do {
            try LonaModule.createWorkspace(at: url)
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
