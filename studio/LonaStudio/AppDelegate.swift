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
#if DEBUG
#else
    PFMoveToApplicationsFolderIfNecessary()
#endif
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

    var colorBrowserWindow: NSWindow?

    @IBAction func showColorBrowser(_ sender: AnyObject) {
        if colorBrowserWindow == nil {
            let initialRect = NSRect(x: 0, y: 0, width: 1280, height: 720)
            let window = NSWindow(contentRect: initialRect, styleMask: [.closable, .titled, .resizable], backing: .retained, defer: false)
            window.center()
            window.title = "Color Browser"
            window.isReleasedWhenClosed = false
            window.minSize = NSSize(width: 784, height: 300)

            let view = NSBox()
            view.boxType = .custom
            view.borderType = .noBorder
            view.contentViewMargins = .zero
            view.translatesAutoresizingMaskIntoConstraints = false

            window.contentView = view

            // Set up color browser

            let colorBrowser = ColorBrowser(colors: CSColors.colors)

            view.addSubview(colorBrowser)

            colorBrowser.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            colorBrowser.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            colorBrowser.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

            colorBrowserWindow = window
        }

        // TODO: Set colors every time we show the browser in case they've changed.
        // Also consider hooking into "Refresh" 

        colorBrowserWindow?.makeKeyAndOrderFront(nil)
    }

    var welcomeWindow: NSWindow?

    @IBAction func showWelcomeWindow(_ sender: AnyObject) {
        if welcomeWindow == nil {
            let size = NSSize(width: 448, height: 480)
            let initialRect = NSRect(origin: .zero, size: size)
            let window = NSWindow(contentRect: initialRect, styleMask: [.closable, .titled], backing: .retained, defer: false)
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
            welcome.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            welcome.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

            welcome.onCreateProject = {
                Swift.print("Create project")
            }

            welcome.onOpenExample = {
                Swift.print("Open example")
            }

            welcome.onOpenDocumentation = {
                Swift.print("Open documentation")
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
            guard let document = try NSDocumentController.shared.openUntitledDocumentAndDisplay(true) as? Document else { return }

            let componentLayer = CSComponentLayer.make(from: url)
            let component = CSComponent.makeDefaultComponent()
            component.rootLayer = componentLayer

            document.set(component: component)
        } catch {
            Swift.print("Failed to duplicate template", url)
        }

    }
}
