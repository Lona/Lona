//
//  WelcomeWindow.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/10/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - WelcomeWindow

public class WelcomeWindow: NSWindow {
    public static var shared = WelcomeWindow()

    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {

        let size = NSSize(width: 720, height: 460)

        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let window = self

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
            let sheetWindow = WelcomeWindow.createSheetWindow(size: .init(width: 924, height: 635))
            let templateBrowser = TemplateBrowser()
            sheetWindow.contentView = templateBrowser

            templateBrowser.onClickDone = {
                guard let url = WelcomeWindow.self.createWorkspaceDialog() else { return }

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

            templateBrowser.onClickCancel = { [unowned self] in
                self.endSheet(sheetWindow)
            }

            self.beginSheet(sheetWindow)
        }

        welcome.onOpenProject = {
            guard let url = WelcomeWindow.openWorkspaceDialog() else { return }

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
    }
}

// MARK: - Dialogs

extension WelcomeWindow {
    private static func createWorkspaceDialog() -> URL? {
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

    private static func openWorkspaceDialog() -> URL? {
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
}
