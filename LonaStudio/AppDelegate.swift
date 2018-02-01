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
}
