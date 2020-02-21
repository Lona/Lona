//
//  WorkspaceViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import BreadcrumbBar
import FileTree
import Foundation
import Logic
import Differ

private func getDirectory() -> URL? {
    let dialog = NSOpenPanel()

    dialog.title                   = "Choose export directory"
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canCreateDirectories    = true
    dialog.canChooseDirectories    = true
    dialog.canChooseFiles          = false

    return dialog.runModal() == NSApplication.ModalResponse.OK ? dialog.url : nil
}

private func requestSketchFileSaveURL() -> URL? {
    let dialog = NSSavePanel()

    dialog.title                   = "Export .sketch file"
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canCreateDirectories    = true
    dialog.allowedFileTypes        = ["sketch"]

    if dialog.runModal() == NSApplication.ModalResponse.OK {
        return dialog.url
    } else {
        // User clicked on "Cancel"
        return nil
    }
}

class WorkspaceViewController: NSSplitViewController {
    private enum DocumentAction: String {
        case cancel = "Cancel"
        case discardChanges = "Discard"
        case saveChanges = "Save"
    }

    private let splitViewResorationIdentifier = "tech.lona.restorationId:workspaceViewController2"

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUpViews()
        setUpLayout()
        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
        setUpLayout()
        update()
    }

    // MARK: Public

    public var activePanes: [WorkspacePane] {
        get {
            return WorkspacePane.all.filter {
                if $0 == .bottom {
                    return !(componentEditorViewController.utilitiesViewVisible)
                } else {
                    return !(splitViewItem(for: $0)?.isCollapsed ?? true)
                }
            }
        }
        set {
            WorkspacePane.all.forEach {
                setVisibility(to: newValue.contains($0), for: $0, animate: true)
            }
        }
    }

    public var onChangeActivePanes: (([WorkspacePane]) -> Void)?

    public var removeDocumentChangeListener: (() -> Void)?

    public var document: NSDocument? {
        didSet {
            if document !== oldValue {
                update()

                self.inspectedContent = nil

                if let document = document as? MarkdownDocument {
                    let key = document.addChangeListener { _ in
                        self.update()
                    }

                    removeDocumentChangeListener = {
                        document.removeChangeListener(forKey: key)
                    }
                } else {
                    removeDocumentChangeListener?()
                }
            }
        }
    }

    // Called from the ComponentMenu
    public func addLayer(_ layer: CSLayer) {
        if let component = component {
            layer.name = component.getNewLayerName(basedOn: layer.name)
        }
        componentEditorViewController.addLayer(layer)
    }

    // MARK: Private

    private var component: CSComponent? {
        return (document as? ComponentDocument)?.component
    }

    var inspectedContent: InspectorView.Content?

    private lazy var fileNavigator: FileNavigator = {
        return FileNavigator(rootPath: LonaModule.current.url.path)
    }()

    private lazy var fileNavigatorViewController: NSViewController = {
        return NSViewController(view: fileNavigator)
    }()

    private lazy var editorViewController = EditorViewController()

    private lazy var componentEditorViewController: ComponentEditorViewController = {
        let controller = ComponentEditorViewController()

        controller.onChangeInspectedCanvas = { [unowned self] index in
            guard let component = self.component else { return }

            let canvas = component.canvas[index]

            controller.selectedLayerName = nil
            controller.selectedCanvasHeaderItem = index
            self.inspectedContent = .canvas(canvas)
            self.inspectorView.content = .canvas(canvas)
        }

        controller.onDeleteCanvas = { [unowned self] index in
            guard let component = self.component else { return }

            component.canvas.remove(at: index)

            controller.selectedLayerName = nil
            controller.selectedCanvasHeaderItem = nil
            self.inspectedContent = nil
            self.inspectorView.content = nil
        }

        controller.onAddCanvas = { [unowned self] in
            guard let component = self.component else { return }

            let canvas: Canvas

            if let last = component.canvas.last {
                canvas = last.copy() as! Canvas
            } else {
                canvas = Canvas.createDefaultCanvas()
            }

            component.canvas.append(canvas)

            controller.selectedLayerName = nil
            controller.selectedCanvasHeaderItem = component.canvas.count - 1
            self.inspectedContent = .canvas(canvas)
            self.inspectorView.content = .canvas(canvas)
        }

        controller.onMoveCanvas = { [unowned self] index, newIndex in
            guard let component = self.component else { return }

            component.canvas.swapAt(index, newIndex)

            controller.selectedLayerName = nil

            // If there was a canvas selected previous, re-select it at its new index
            if controller.selectedCanvasHeaderItem == index {
                let canvas = component.canvas[newIndex]

                controller.selectedCanvasHeaderItem = newIndex
                self.inspectedContent = .canvas(canvas)
                self.inspectorView.content = .canvas(canvas)
            }
        }

        return controller
    }()

    private lazy var codeEditorViewController = CodeEditorViewController()

    private lazy var colorEditorViewController: ColorEditorViewController = {
        let controller = ColorEditorViewController()

        controller.onInspectColor = { color in
            self.inspectedContent = InspectorView.Content(color)
            self.update()
        }

        controller.onChangeColors = { actionName, newColors, selectedColor in
            guard
                let document = self.document as? JSONDocument,
                let content = document.content,
                case let .colors(oldColors) = content else { return }

            let oldInspectedContent = self.inspectedContent
            let newInspectedContent = InspectorView.Content(selectedColor)

            UndoManager.shared.run(
                name: actionName,
                execute: {[unowned self] _ in
                    document.content = .colors(newColors)
                    self.inspectedContent = newInspectedContent
                    self.inspectorView.content = newInspectedContent
                    controller.colors = newColors
                },
                undo: {[unowned self] in
                    document.content = .colors(oldColors)
                    self.inspectedContent = oldInspectedContent
                    self.inspectorView.content = oldInspectedContent
                    controller.colors = oldColors
                }
            )
        }

        return controller
    }()

    private lazy var textStyleEditorViewController: TextStyleEditorViewController = {
        let controller = TextStyleEditorViewController()

        controller.onInspectTextStyle = { textStyle in
            self.inspectedContent = InspectorView.Content(textStyle)
            self.update()
        }

        controller.onChangeTextStyles = { actionName, newTextStyles, selectedTextStyle in
            guard
                let document = self.document as? JSONDocument,
                let content = document.content,
                case let .textStyles(oldFile) = content else { return }

            let oldInspectedContent = self.inspectedContent
            let newInspectedContent = InspectorView.Content(selectedTextStyle)

            UndoManager.shared.run(
                name: actionName,
                execute: {[unowned self] _ in
                    var newFile = oldFile
                    newFile.styles = newTextStyles
                    document.content = .textStyles(newFile)
                    self.inspectedContent = newInspectedContent
                    self.inspectorView.content = newInspectedContent
                    controller.textStyles = newFile.styles
                },
                undo: {[unowned self] in
                    document.content = .textStyles(oldFile)
                    self.inspectedContent = oldInspectedContent
                    self.inspectorView.content = oldInspectedContent
                    controller.textStyles = oldFile.styles
                }
            )
        }

        return controller
    }()

    private lazy var markdownViewController = MarkdownViewController(editable: true, preview: false)

    private lazy var imageViewController = ImageViewController()

    private lazy var logicViewController = LogicViewController()

    private lazy var inspectorView = InspectorView()
    private lazy var inspectorViewController: NSViewController = {
        return NSViewController(view: inspectorView)
    }()
    private var inspectorViewVisible: Bool {
        get {
            return splitViewItems.contains(sidebarItem)
        }
        set {
            if newValue && !inspectorViewVisible {
                insertSplitViewItem(sidebarItem, at: splitViewItems.count)
            } else if !newValue && inspectorViewVisible {
                removeSplitViewItem(sidebarItem)
            }
        }
    }

    // A document's window controllers are deallocated if there are no associated documents.
    // This ViewController can contain a reference.
    private var windowController: NSWindowController?

    private func splitViewItem(for workspacePane: WorkspacePane) -> NSSplitViewItem? {
        switch workspacePane {
        case .left:
            return contentListItem
        case .right:
            return sidebarItem
        case .bottom:
            return nil
        }
    }

    private func setVisibility(to visible: Bool, for pane: WorkspacePane, animate: Bool) {
        if pane == .bottom {
            componentEditorViewController.utilitiesViewVisible = visible
        } else {
            guard let item = splitViewItem(for: pane) else { return }

            if (visible && item.isCollapsed) || (!visible && !item.isCollapsed) {
                if animate {
                    item.animator().isCollapsed = !visible
                } else {
                    item.isCollapsed = !visible
                }
            }
        }
    }

    override func viewDidAppear() {
        windowController = view.window?.windowController
        onChangeActivePanes?(activePanes)
    }

    override func viewDidDisappear() {
        windowController = nil
    }

    private func setUpViews() {
        splitView.dividerStyle = .thin
        splitView.autosaveName = splitViewResorationIdentifier
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)

        fileNavigator.onCreateFile = { path, options in
            LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
        }

        fileNavigator.performDeleteFile = { path in
            let fileURL = URL(fileURLWithPath: path)

            // Attempt to delete the file specially a document, falling back to deleting the file
            DocumentController.shared.openDocument(withContentsOf: fileURL, display: false).finalResult { result in
                switch result {
                case .success(let document):
                    _ = DocumentController.shared.delete(document: document)
                case .failure:
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        Alert.runInformationalAlert(
                            messageText: "Couldn't delete file",
                            informativeText: "The file \(fileURL.lastPathComponent) could not be deleted"
                        )
                    }
                }

                LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
            }
        }

        // Handle files being removed from the filesystem (e.g. via Finder)
        fileNavigator.onDeleteFile = { path, options in
            if options.contains(.ownEvent) { return }

            let fileURL = URL(fileURLWithPath: path)

            if let document = DocumentController.shared.findOpenDocument(for: fileURL) {
                DocumentController.shared.close(document: document)

                LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
            }
        }

        // TODO: Add moving files back in, adjusting page links as needed
        fileNavigator.validateProposedMove = { prev, next in false }

        fileNavigator.performMoveFile = { prev, next in
            Swift.print("Move", prev, "=>", next)

            let prevURL = URL(fileURLWithPath: prev)
            let nextURL = URL(fileURLWithPath: next)

            if prevURL.isLonaPage() {
                DocumentController.shared.openDocument(withContentsOf: prevURL, display: false)
                    // Save this page to its new location
                    .onSuccess({ document in
                        return (document as! MarkdownDocument).movePage(to: nextURL, display: true)
                    })
                return true
            } else {
                do {
                    try FileManager.default.moveItem(atPath: prev, toPath: next)
                    return true
                } catch {
                    Swift.print("Failed to move \(prev) to \(next)")
                    return false
                }
            }
        }

        fileNavigator.performCreateComponent = { path in
            let document = ComponentDocument()

            let fileURL = URL(fileURLWithPath: path)

            document
                .save(to: fileURL, ofType: "DocumentType", for: .saveOperation)
                .onSuccess({ document in
                    DocumentController.shared.openDocument(withContentsOf: fileURL, display: true)
                })

            return true
        }

        // The parent may be a directory or .md file. The `pageName` does not end in ".md".
        fileNavigator.performCreatePage = { pageName, parentPath in
            let parentURL = URL(fileURLWithPath: parentPath)

            if FileManager.default.isDirectory(path: parentPath) {
                let fileURL = parentURL.appendingPathComponent(pageName + ".md")

                _ = DocumentController.shared.makeAndOpenMarkdownDocument(withTitle: pageName, savedTo: fileURL)
            } else {
                DocumentController.shared.openDocument(withContentsOf: parentURL, display: false)
                .onSuccess({ parentDocument -> Promise<MarkdownDocument, NSError> in
                    if let parentDocument = parentDocument as? MarkdownDocument {
                        return .success(parentDocument)
                    } else {
                        return .failure(NSError.init())
                    }
                })
                // First, convert the parent to a directory
                .onSuccess({ parentDocument in parentDocument.convertToDirectory() })
                .onSuccess({ directoryURL in
                    DocumentController.shared.makeAndOpenMarkdownDocument(
                        withTitle: pageName,
                        savedTo: directoryURL.appendingPathComponent(pageName + ".md")
                    )
                })
            }
        }

        fileNavigator.onSelect = { path in
            if let path = path {
                let fileURL = URL(fileURLWithPath: path)
                DocumentController.shared.openDocument(withContentsOf: fileURL, display: true).finalFailure { [unowned self] error in
                    self.fileNavigator.selectedFile = path
                    self.update()
                }
            }
        }
    }

    private lazy var contentListItem = NSSplitViewItem(contentListWithViewController: fileNavigatorViewController)
    private lazy var mainItem = NSSplitViewItem(viewController: editorViewController)
    private lazy var sidebarItem = NSSplitViewItem(viewController: inspectorViewController)

    private func setUpLayout() {
        let newSplitView = SubtleSplitView()
        newSplitView.isVertical = splitView.isVertical
        newSplitView.dividerStyle = splitView.dividerStyle
        newSplitView.autosaveName = splitView.autosaveName
        newSplitView.identifier = splitView.identifier
        self.splitView = newSplitView

        minimumThicknessForInlineSidebars = 180

        contentListItem.collapseBehavior = .preferResizingSiblingsWithFixedSplitView
        addSplitViewItem(contentListItem)

        mainItem.minimumThickness = 300
        mainItem.preferredThicknessFraction = 0.5
        addSplitViewItem(mainItem)

        sidebarItem.collapseBehavior = .preferResizingSiblingsWithFixedSplitView
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 280
        sidebarItem.maximumThickness = 280
        addSplitViewItem(sidebarItem)
    }

    private static func makeBreadcrumbs(for selectedFileURL: URL) -> (breadcrumbs: [Breadcrumb], handler: (UUID) -> Void) {
        let relativePathComponents = selectedFileURL.pathComponents.dropFirst(CSUserPreferences.workspaceURL.pathComponents.count)

        let workspaceBreadcrumb = Breadcrumb(
            id: UUID(),
            title: CSWorkspacePreferences.workspaceName,
            icon: NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
        )

        var breadcrumbURLs: [UUID: URL] = [workspaceBreadcrumb.id: CSUserPreferences.workspaceURL]

        let pageBreadcrumbs: [Breadcrumb] = relativePathComponents.enumerated().map { index, component in
            let url = relativePathComponents.dropLast(relativePathComponents.count - index - 1).reduce(CSUserPreferences.workspaceURL, { (result, item) in
                result.appendingPathComponent(item)
            })

            let id = UUID()

            breadcrumbURLs[id] = url

            let icon = url.isLonaMarkdownDirectory()
                ? NSWorkspace.shared.icon(forFile: url.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME).path)
                : NSWorkspace.shared.icon(forFile: url.path)

            let title = component.hasSuffix(".md") ? String(component.dropLast(3)) : component

            return Breadcrumb(id: id, title: title, icon: icon)
        }

        let breadcrumbs = [workspaceBreadcrumb] + pageBreadcrumbs

        let handler: (UUID) -> Void = { uuid in
            guard let url = breadcrumbURLs[uuid] else { return }
            DocumentController.shared.openDocument(withContentsOf: url, display: true)
        }

        return (breadcrumbs, handler)
    }

    func update() {
        inspectorView.content = inspectedContent

        codeEditorViewController.document = document

        guard let document = document else {
            if let path = fileNavigator.selectedFile, FileManager.default.isDirectory(path: path) {
                let contentView = NoDocument(
                    titleText: "This folder has no index page (README.md)",
                    buttonTitleText: "Create index page"
                )

                contentView.onClick = {
                    let fileURL = URL(fileURLWithPath: path)
                    let title = fileURL.lastPathComponent
                    let document = MarkdownDocument(title: title)
                    let pageURL = fileURL.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)

                    // Create a README.md file
                    document.save(to: pageURL, for: .saveOperation)
                        .onSuccess({ _ in document.ensureParentLink(customTitle: title) })
                        // Attempt to convert to a plain file, in case there's nothing else in this folder
                        .onSuccess({ _ in document.convertToFile() })
                        .finalResult({ result in
                            switch result {
                            case .success(let convertedURL):
                                DocumentController.shared.openDocument(withContentsOf: convertedURL, display: true)
                            case .failure:
                                DocumentController.shared.openDocument(withContentsOf: pageURL, display: true)
                            }
                        })
                }

                editorViewController.contentView = contentView

                fileNavigator.selectedFile = path
            } else {
                let contentView = NSBox()
                contentView.boxType = .custom
                contentView.borderType = .noBorder
                contentView.fillColor = Colors.contentBackground

                editorViewController.contentView = contentView

                fileNavigator.selectedFile = nil
            }

            inspectorViewVisible = false

            editorViewController.breadcrumbs = [
                .init(id: UUID(), title: "No document", icon: nil)
            ]

            return
        }

        if let fileURL = document.fileURL {
            let selectedFileURL = fileURL.lastPathComponent == MarkdownDocument.INDEX_PAGE_NAME
                ? fileURL.deletingLastPathComponent()
                : fileURL

            fileNavigator.selectedFile = selectedFileURL.path

            let (breadcrumbs, handler) = WorkspaceViewController.makeBreadcrumbs(for: selectedFileURL)

            editorViewController.breadcrumbs = breadcrumbs
            editorViewController.onClickBreadcrumb = handler
        } else {
            let titleText = document.fileURL?.lastPathComponent ?? "Untitled"
            let subtitleText = document.isDocumentEdited == true ? " — Edited" : ""

            editorViewController.breadcrumbs = [
                .init(id: UUID(), title: titleText + subtitleText, icon: nil)
            ]
        }

        editorViewController.showsHeaderDivider = false

        editorViewController.onClickPublish = {
            if PublishingViewController.shared.canPublish() {
                PublishingViewController.shared.initializeState()
                self.presentAsModalWindow(PublishingViewController.shared)
            } else {
                Alert.runInformationalAlert(messageText: "Invalid git configuration", informativeText: "There must be a git repository in your workspace root (the same directory as the lona.json) before you can publish.")
            }
        }

        if document is ComponentDocument {
            editorViewController.showsHeaderDivider = true
            inspectorViewVisible = true
            editorViewController.contentView = componentEditorViewController.view

            componentEditorViewController.onChangeUtilitiesViewVisible = { [unowned self] _ in
                // We don't use the visible param, which complicated the logic.
                // We'll need to keep an eye on performance here.
                self.onChangeActivePanes?(self.activePanes)
            }

            componentEditorViewController.component = component

            componentEditorViewController.onInspectLayer = { layer in
                guard let layer = layer else {
                    self.inspectedContent = nil
                    self.componentEditorViewController.selectedLayerName = nil
                    return
                }
                self.inspectedContent = .layer(layer)
                self.inspectorView.content = .layer(layer)
                self.componentEditorViewController.selectedCanvasHeaderItem = nil
                self.componentEditorViewController.selectedLayerName = layer.name
            }

            componentEditorViewController.onChangeInspectedLayer = {
                self.inspectorView.content = self.inspectedContent
            }

            inspectorView.onChangeContent = { [unowned self] content, changeType in
                switch content {
                case .canvas(let canvas):
                    guard let index = self.componentEditorViewController.selectedCanvasHeaderItem else { break }
                    self.component?.canvas[index] = canvas
                    self.componentEditorViewController.updateCanvas()
                default:
                    break
                }

                switch changeType {
                case .canvas:
                    self.componentEditorViewController.updateCanvas()
                    self.inspectorView.content = content
                case .full:
                    self.componentEditorViewController.reloadLayerListWithoutModifyingSelection()
                }
            }
        } else if let document = document as? LogicDocument {
            inspectorViewVisible = false

            editorViewController.contentView = logicViewController.view

            logicViewController.rootNode = document.content
            logicViewController.onChangeRootNode = { rootNode in
                let originalContent = document.content

                document.undoManager?.run(
                    name: "Edit Logic",
                    execute: {[unowned self] isRedo in
                        document.updateChangeCount(isRedo ? .changeRedone : .changeDone)
                        document.content = rootNode
                        self.update()
                    },
                    undo: {[unowned self] in
                        document.updateChangeCount(.changeUndone)
                        document.content = originalContent
                        self.update()
                    }
                )
            }
        } else if let document = document as? JSONDocument {
            inspectorViewVisible = true
            if let content = document.content, case .colors(let colors) = content {
                editorViewController.contentView = colorEditorViewController.view

                colorEditorViewController.colors = colors
            } else if let content = document.content, case .textStyles(let file) = content {
                editorViewController.contentView = textStyleEditorViewController.view

                textStyleEditorViewController.textStyles = file.styles
            } else {
                editorViewController.contentView = nil
            }

            inspectorView.onChangeContent = { newContent, changeType in
                if UndoManager.shared.isUndoing || UndoManager.shared.isRedoing {
                    return
                }

                guard let oldContent = self.inspectedContent else { return }
                guard let content = document.content else { return }

                switch (oldContent, newContent, content) {
                case (.color(let oldColor), .color(let newColor), .colors(let colors)):

                    // Perform update using indexes in case the id was changed
                    guard let index = colors.firstIndex(where: { $0.id == oldColor.id }) else { return }

                    let updated = colors.enumerated().map { offset, element in
                        return index == offset ? newColor : element
                    }

                    // TODO: Improve this. It may be conflicting with the textfield's built-in undo
                    UndoManager.shared.run(
                        name: "Edit Color",
                        execute: {[unowned self] _ in
                            document.content = .colors(updated)
                            self.inspectedContent = .color(newColor)
                            self.inspectorView.content = .color(newColor)
                            self.colorEditorViewController.colors = updated
                        },
                        undo: {[unowned self] in
                            document.content = .colors(colors)
                            self.inspectedContent = .color(oldColor)
                            self.inspectorView.content = .color(oldColor)
                            self.colorEditorViewController.colors = colors
                        }
                    )
                case (.textStyle(let oldTextStyle), .textStyle(let newTextStyle), .textStyles(let textStyles)):

                    // Perform update using indexes in case the id was changed
                    guard let index = textStyles.styles.firstIndex(where: { $0.id == oldTextStyle.id }) else { return }

                    let updated = JSONDocument.TextStylesFile(
                        styles: textStyles.styles.enumerated().map { offset, element in
                            return index == offset ? newTextStyle : element
                        },
                        defaultStyleName: textStyles.defaultStyleName
                    )

                    // TODO: Improve this. It may be conflicting with the textfield's built-in undo
                    UndoManager.shared.run(
                        name: "Edit Text Style",
                        execute: {[unowned self] _ in
                            document.content = .textStyles(updated)
                            self.inspectedContent = .textStyle(newTextStyle)
                            self.inspectorView.content = .textStyle(newTextStyle)
                            self.textStyleEditorViewController.textStyles = updated.styles
                        },
                        undo: {[unowned self] in
                            document.content = .textStyles(textStyles)
                            self.inspectedContent = .textStyle(oldTextStyle)
                            self.inspectorView.content = .textStyle(oldTextStyle)
                            self.textStyleEditorViewController.textStyles = textStyles.styles
                        }
                    )
                default:
                    break
                }
            }
        } else if let document = document as? ImageDocument {
            inspectorViewVisible = false
            if let content = document.content {
                editorViewController.contentView = imageViewController.view

                imageViewController.image = content
            } else {
                editorViewController.contentView = nil
            }
        } else if let document = document as? MarkdownDocument {
            inspectorViewVisible = false

            markdownViewController.content = document.content

            editorViewController.contentView = markdownViewController.view

            markdownViewController.onNavigateToPage = { [unowned document] page in
                guard let fileURL = document.fileURL else { return false }
                let pageURL = fileURL.deletingLastPathComponent().appendingPathComponent(page)

                // Attempt to open the document without displaying it
                DocumentController.shared.openDocument(withContentsOf: pageURL, display: false).finalResult { result in
                    switch result {
                    case .success:
                        // Display the document once we know it exists on the filesystem
                        DocumentController.shared.openDocument(withContentsOf: pageURL, display: true)
                    case .failure:
                        if Alert.runConfirmationAlert(
                            confirmationText: "Delete link",
                            messageText: "Page \(page) not found",
                            informativeText: [
                                "The page \(page) doesn't seem to exist on your filesystem.",
                                "It may have been deleted by another author."
                                ].joined(separator: " ")) {
                            let updated = MarkdownDocument.removePageLink(blocks: document.content, target: page)
                            document.setContent(updated, userInitiated: false)
                        }
                    }
                }

                return true
            }
            markdownViewController.onRequestCreatePage = { [unowned document] index, shouldReplace in
                guard let pageName = Alert.runTextInputAlert(
                    messageText: "Enter the name of your new page",
                    placeholderText: "Page name")
                    else { return }
                document.makeAndOpenChildPage(pageName: pageName, blockIndex: index, shouldReplaceBlock: shouldReplace)
            }
            markdownViewController.onChange = { [unowned document] blocks in
                document.setContent(blocks, userInitiated: true)
                document.scheduleAutosaving()
                return true
            }
        }
    }

    // Subscriptions

    var subscriptions: [LonaPlugins.SubscriptionHandle] = []

    override func viewWillAppear() {
        subscriptions.append(LonaPlugins.current.register(eventType: .onReloadWorkspace) {
            self.component?.layers
                .filter({ $0 is CSComponentLayer })
                .forEach({ layer in
                    let layer = layer as! CSComponentLayer
                    layer.reload()
                })

            self.update()
        })
    }

    override func viewWillDisappear() {
        subscriptions.forEach({ sub in sub() })
    }

    // Key handling

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(" ")) {
            componentEditorViewController.canvasPanningEnabled = true
        }

        super.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(" ")) {
            componentEditorViewController.canvasPanningEnabled = false
        }

        super.keyUp(with: event)
    }
}

// MARK: - IBActions

extension WorkspaceViewController {
    @IBAction func newDocument(_ sender: AnyObject) {
        guard var pageName = Alert.runTextInputAlert(
            messageText: "Create a new page in this workspace",
            placeholderText: "Page name") else { return }
        if pageName.hasSuffix(".md") {
            pageName.removeLast(3)
        }
        _ = DocumentController.shared.makeAndOpenMarkdownDocument(
            withTitle: pageName,
            savedTo: CSUserPreferences.workspaceURL.appendingPathComponent(pageName + ".md")
        )
    }

    @objc func document(_ doc: NSDocument?, didSave: Bool, contextInfo: UnsafeMutableRawPointer?) {
        update()
        fileNavigator.reloadData()
    }

    @IBAction func saveDocument(_ sender: AnyObject) {
        document?.save(
            withDelegate: self,
            didSave: #selector(document(_:didSave:contextInfo:)),
            contextInfo: nil)
    }

    @IBAction func zoomToActualSize(_ sender: AnyObject) {
        componentEditorViewController.zoomToActualSize()
    }

    @IBAction func zoomIn(_ sender: AnyObject) {
        componentEditorViewController.zoomIn()
    }

    @IBAction func zoomOut(_ sender: AnyObject) {
        componentEditorViewController.zoomOut()
    }

    @IBAction func exportToAnimation(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        StaticCanvasRenderer.renderToAnimations(component: component, directory: url)
    }

    @IBAction func exportCurrentModuleToImages(_ sender: AnyObject) {
        guard let url = getDirectory() else { return }

        StaticCanvasRenderer.renderCurrentModuleToImages(savedTo: url)
    }

    @IBAction func exportToImages(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        StaticCanvasRenderer.renderToImages(component: component, directory: url)
    }

    @IBAction func exportToVideo(_ sender: AnyObject) {
        guard let component = component, let url = getDirectory() else { return }

        StaticCanvasRenderer.renderToVideos(component: component, directory: url)
    }

    @IBAction func addComponent(_ sender: AnyObject) {
        guard let component = component else { return }

        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a .component file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["component"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url {
                let newLayer = CSComponentLayer.make(from: url)

                // Add number suffix if needed
                newLayer.name = component.getNewLayerName(basedOn: newLayer.name)

                componentEditorViewController.addLayer(newLayer)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

    @IBAction func toggleAccessibilityOverlay(_ sender: AnyObject) {
        guard let sender = sender as? NSMenuItem else { return }

        switch sender.state {
        case .on:
            sender.state = .off
            componentEditorViewController.showsAccessibilityOverlay = false
        case .off:
            sender.state = .on
            componentEditorViewController.showsAccessibilityOverlay = true
        default:
            break
        }
    }

    func addLayer(forType type: CSLayer.LayerType) {
        guard let component = component else { return }

        let newLayer = component.makeLayer(forType: type)
        componentEditorViewController.addLayer(newLayer)
    }
}
