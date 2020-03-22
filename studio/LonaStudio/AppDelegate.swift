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
import Logic

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // This is necessary to have our subclass be the shared NSDocumentController
    let documentController = DocumentController()

    func applicationWillFinishLaunching(_ notification: Notification) {
//        if #available(OSX 10.14, *) {
//            NSApp.appearance = NSAppearance(named: .aqua)
//        }
        #if DEBUG
        #else
            PFMoveToApplicationsFolderIfNecessary()
        #endif

        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        showWelcomeWindow(self)
        NSDocumentController.shared.autosavingDelay = 1
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
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
        DocumentController.shared.openDocument(withContentsOf: fileURL, display: true)
        return true
    }

    private static var preferencesWindow: MASPreferencesWindowController?

    public static func reloadPreferencesWindow() {
        preferencesWindow?.viewControllers.forEach { viewController in
            if let workspacePreferences = viewController as? WorkspacePreferencesViewController {
                workspacePreferences.render()
            }
            if let accountPreferences = viewController as? AccountPreferencesViewController {
                accountPreferences.render()
            }
        }
    }

    @IBAction func showPreferences(_ sender: AnyObject) {
        if AppDelegate.preferencesWindow == nil {
            let workspace = WorkspacePreferencesViewController()
            workspace.viewDidLoad()

            let account = AccountPreferencesViewController()
            account.viewDidLoad()

            AppDelegate.preferencesWindow = MASPreferencesWindowController(viewControllers: [workspace, account], title: "Preferences")
        }

        AppDelegate.reloadPreferencesWindow()

        AppDelegate.preferencesWindow?.showWindow(sender)
    }

    @IBAction func showLogicDebuggingWindow(_ sender: AnyObject) {
        AppDelegate.debugController.showWindow(nil)
    }

    static var debugController: DebugWindowController = {
        let controller = DebugWindowController()
        controller.getLibraryContents = LogicLoader.load
        controller.getLibraryURL = LogicLoader.url
        return controller
    }()

    private var welcomeWindow = WelcomeWindow()

    @IBAction func showWelcomeWindow(_ sender: AnyObject) {
        welcomeWindow.makeKeyAndOrderFront(nil)
    }

    func hideWelcomeWindow(_ sender: AnyObject) {
        if let viewControllers = welcomeWindow.contentViewController?.presentedViewControllers {
            viewControllers.forEach { $0.dismiss(sender) }
        }

        welcomeWindow.close()
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

    // MARK: - Reloading

    @IBAction func reload(_ sender: AnyObject) {
        CSUserTypes.reload()
        CSColors.reload()
        CSTypography.reload()
        CSGradients.reload()
        CSShadows.reload()

        LonaPlugins.current.trigger(eventType: .onReloadWorkspace)
    }

    /** Gets called when the App launches/opens via URL. */
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        guard let appleEventDescription = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
            return
        }

        guard let appleEventURLString = appleEventDescription.stringValue else {
            return
        }

        guard let appleEventURL = URL(string: appleEventURLString) else {
            return
        }

        if "lonastudio" == appleEventURL.scheme && "oauth-callback" == appleEventURL.host {
            guard
                let urlComponents = URLComponents(string: appleEventURLString),
                let token = urlComponents.queryItems?.first(where: { $0.name == "token" })?.value
            else {
                return
            }

            Account.shared.signin(token: token)
            AppDelegate.reloadPreferencesWindow()
            PublishingViewController.shared.updateForNewAccountInfo()
            OpenWorkspaceViewController.shared.initializeState()
        }
    }
}
