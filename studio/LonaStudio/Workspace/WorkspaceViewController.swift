//
//  WorkspaceViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import FileTree
import Foundation
import Logic

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

    public var codeViewVisible: Bool {
        get {
            return splitViewItems.contains(codeItem)
        }
        set {
            if newValue && !codeViewVisible {
                let mainIndex = splitViewItems.firstIndex(of: mainItem)!
                insertSplitViewItem(codeItem, at: mainIndex + 1)
            } else if !newValue && codeViewVisible {
                removeSplitViewItem(codeItem)
            }
        }
    }
    public var onChangeCodeViewVisible: ((Bool) -> Void)?

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

    public var document: NSDocument? { didSet { update() } }

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

    private var inspectedContent: InspectorView.Content?

    private lazy var fileNavigator: FileNavigator = {
        return FileNavigator(rootPath: LonaModule.current.url.path)
    }()

    private lazy var fileNavigatorViewController: NSViewController = {
        return NSViewController(view: fileNavigator)
    }()

    private lazy var editorViewController = EditorViewController()

    private lazy var companionViewController = EditorViewController()

    func updateEditorHeader(parameters: EditorHeader.Parameters) {
        editorViewController.titleText = parameters.titleText
        editorViewController.subtitleText = parameters.subtitleText
        editorViewController.fileIcon = parameters.fileIcon
    }

    func updateCompanionHeader(parameters: EditorHeader.Parameters) {
        companionViewController.titleText = parameters.titleText
        companionViewController.subtitleText = parameters.subtitleText
        companionViewController.fileIcon = parameters.fileIcon
    }

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

    private lazy var directoryViewController = DirectoryViewController()

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
        onChangeCodeViewVisible?(codeViewVisible)
    }

    override func viewDidDisappear() {
        windowController = nil
    }

    func performCreateFile(path: String, document: NSDocument, ofType documentType: String) -> Bool {
        if let document = self.document {
            guard self.close(document: document, discardingUnsavedChanges: false) else { return false }
        }

        guard let windowController = self.view.window?.windowController else { return false }

        let url = URL(fileURLWithPath: path)
        let newDocument = document
        newDocument.fileURL = url
        newDocument.save(
            to: url,
            ofType: documentType,
            for: NSDocument.SaveOperationType.saveOperation, completionHandler: { error in
                if let error = error {
                    Swift.print("Failed to save \(url): \(error)")
                }
        })

        NSDocumentController.shared.addDocument(newDocument)
        newDocument.addWindowController(windowController)
        windowController.document = newDocument

        self.document = newDocument

        // Set this after updating the document (which calls update)
        // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
        self.inspectedContent = nil

        return true
    }

    private func setUpViews() {
        splitView.dividerStyle = .thin
        splitView.autosaveName = splitViewResorationIdentifier
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)

        fileNavigator.onCreateFile = { path, options in
            LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
        }

        fileNavigator.onDeleteFile = { path, options in
            NSDocumentController.shared.documents.forEach { document in
                let url = URL(fileURLWithPath: path)
                // TODO: If deleting a directory, close all files that are descendants
                if let fileURL = document.fileURL, fileURL == url || fileURL == url.appendingPathComponent("README.md") {
                    self.close(document: document, discardingUnsavedChanges: true)
                }
            }
            LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
        }

        // Don't allow moving these json files within Lona Studio.
        // The lona.json file needs to be in the workspace root directory.
        // The other config files can be moved, but we'll need to handle updating the preference file paths before we allow it.
        let unmovableFiles = ["colors.json", "textStyles.json", "gradients.json", "shadows.json", "lona.json", "types.json"]
        fileNavigator.validateProposedMove = { prev, next in
            let name = URL(fileURLWithPath: prev).lastPathComponent
            let result = !unmovableFiles.contains(name)
            return result
        }

        fileNavigator.performMoveFile = { prev, next in
            do {
                try FileManager.default.moveItem(atPath: prev, toPath: next)
                LonaPlugins.current.trigger(eventType: .onChangeFileSystemComponents)
                return true
            } catch {
                Swift.print("Failed to move \(prev) to \(next)")
                return false
            }
        }

        fileNavigator.performCreateLogicFile = { path in
            let document = LogicDocument()

            let name = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent

            document.content = .topLevelDeclarations(
                .init(
                    id: UUID(),
                    declarations: .init(
                        [
                            WorkspaceTemplate.makeImport(name: "Color"),
                            WorkspaceTemplate.makeNamespace(name: name, declarations:
                                [
                                    .placeholder(id: UUID())
                                ]
                            ),
                            .placeholder(id: UUID())
                        ]
                    )
                )
            )

            return self.performCreateFile(path: path, document: document, ofType: "Logic")
        }

        fileNavigator.performCreateComponent = { path in
            let document = ComponentDocument()
            document.component = CSComponent.makeDefaultComponent()
            return self.performCreateFile(path: path, document: document, ofType: "DocumentType")
        }

        fileNavigator.performCreateMarkdownFile = { path in
            return self.performCreateFile(path: path, document: MarkdownDocument(), ofType: "Markdown")
        }

        fileNavigator.onAction = self.openDocument
        directoryViewController.onSelectComponent = self.openDocument
    }

    private lazy var contentListItem = NSSplitViewItem(contentListWithViewController: fileNavigatorViewController)
    private lazy var mainItem = NSSplitViewItem(viewController: editorViewController)
    private lazy var codeItem = NSSplitViewItem(viewController: companionViewController)
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

        // The codeItem is added to the splitview dynamically, based on saved preference
        codeItem.minimumThickness = 180
        codeItem.preferredThicknessFraction = 0.5
        codeItem.holdingPriority = .dragThatCannotResizeWindow - 1

        sidebarItem.collapseBehavior = .preferResizingSiblingsWithFixedSplitView
        sidebarItem.canCollapse = false
        sidebarItem.minimumThickness = 280
        sidebarItem.maximumThickness = 280
        addSplitViewItem(sidebarItem)
    }

    func update() {
        inspectorView.content = inspectedContent

        companionViewController.contentView = codeEditorViewController.contentView
        codeEditorViewController.document = document

        guard let document = document else {
            if let path = lastOpenedDocumentPath, FileManager.default.isDirectory(path: path) {
                let contentView = NoDocument(
                    titleText: "This folder has no index page (README.md)",
                    buttonTitleText: "Create index page"
                )

                contentView.onClick = {
                    _ = self.performCreateFile(
                        path: URL(fileURLWithPath: path).appendingPathComponent("README.md").path,
                        document: MarkdownDocument(),
                        ofType: "Markdown"
                    )
                }

                editorViewController.contentView = contentView
            } else {
                let contentView = NSBox()
                contentView.boxType = .custom
                contentView.borderType = .noBorder
                contentView.fillColor = Colors.contentBackground

                editorViewController.contentView = contentView
            }

            inspectorViewVisible = false

            let titleText = "No document"
            let subtitleText = ""
            let fileIcon: NSImage? = nil

            editorViewController.titleText = titleText
            editorViewController.subtitleText = subtitleText
            editorViewController.fileIcon = fileIcon

            companionViewController.titleText = titleText
            companionViewController.subtitleText = subtitleText
            companionViewController.fileIcon = fileIcon

            return
        }

        codeEditorViewController.updateEditorHeader = { [weak self] parameters in
            guard let self = self else { return }
            self.updateCompanionHeader(parameters: parameters)
        }

        var titleText = document.fileURL?.lastPathComponent ?? "Untitled"
        let subtitleText = document.isDocumentEdited == true ? " — Edited" : ""
        let fileIcon: NSImage?
        if let fileURL = document.fileURL {
            fileIcon = NSWorkspace.shared.icon(forFile: fileURL.path)

            // When editing a README, display the name of the directory as the title
            if fileURL.lastPathComponent == "README.md" {
                titleText = fileURL.deletingLastPathComponent().lastPathComponent
            }
        } else {
            fileIcon = NSImage()
        }

        editorViewController.titleText = titleText
        editorViewController.subtitleText = subtitleText
        editorViewController.fileIcon = fileIcon

        companionViewController.titleText = titleText
        companionViewController.subtitleText = subtitleText
        companionViewController.fileIcon = fileIcon

        if document is ComponentDocument {
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
            updateCompanionHeader(parameters: codeEditorViewController.headerParameters)

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

            editorViewController.contentView = markdownViewController.view

            markdownViewController.onNavigateToPage = { [unowned self] page in
                guard let fileURL = document.fileURL else { return false }
                self.openDocument(fileURL.deletingLastPathComponent().appendingPathComponent(page).path)
                return true
            }
            markdownViewController.content = document.content
            markdownViewController.onChange = { [unowned self] value in
                let value = value.isEmpty ? [BlockEditor.Block.makeDefaultEmptyBlock()] : value

                document.content = value
                self.markdownViewController.content = value

                document.updateChangeCount(.changeDone)
                self.editorViewController.subtitleText = " — Edited"
                return true
            }
        } else if let document = document as? DirectoryDocument {
            inspectorViewVisible = false
            if let content = document.content {
                editorViewController.contentView = directoryViewController.view

                directoryViewController.componentNames = content.componentNames
                directoryViewController.logicFileNames = content.logicFileNames
                directoryViewController.readme = content.readme
                directoryViewController.folderName = content.folderName
            } else {
                editorViewController.contentView = nil
            }
        }
    }

    // We keep track of the last opened document path so that if it fails to open,
    // we can show the correct placeholder content. However, there are probably other
    // ways a document can be presented, so this is not perfect.
    private var lastOpenedDocumentPath: String?

    func openDocument(_ path: String) {
        lastOpenedDocumentPath = path

        guard let previousDocument = self.document else {
            if FileUtils.fileExists(atPath: path) == .none {
                return
            }

            let url = URL(fileURLWithPath: path)

            if FileUtils.fileExists(atPath: path) == .directory {
                guard let newDocument = try? NSDocumentController.shared.makeDocument(withContentsOf: url, ofType: "DirectoryDocument") else {
                    Swift.print("Failed to open", url)
                    return
                }

                NSDocumentController.shared.addDocument(newDocument)

                guard let windowController = self.view.window?.windowController else { return }

                newDocument.addWindowController(windowController)
                windowController.document = newDocument
                self.document = newDocument

                // Set this after updating the document (which calls update)
                // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
                self.inspectedContent = nil
                return
            }

            NSDocumentController.shared.openDocument(withContentsOf: url, display: false, completionHandler: { newDocument, documentWasAlreadyOpen, error in

                guard let newDocument = newDocument else {
                    Swift.print("Failed to open", url, error as Any)
                    return
                }

                if documentWasAlreadyOpen {
                    newDocument.showWindows()
                    return
                }

                guard let windowController = self.view.window?.windowController else { return }

                newDocument.addWindowController(windowController)
                windowController.document = newDocument
                self.document = newDocument

                // Set this after updating the document (which calls update)
                // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
                self.inspectedContent = nil
            })

            return
        }

        if previousDocument.fileURL?.path == path { return }

        if previousDocument.isDocumentEdited {
            let name = previousDocument.fileURL?.lastPathComponent ?? "Untitled"
            guard let result = Alert(
                items: [
                    DocumentAction.cancel,
                    DocumentAction.discardChanges,
                    DocumentAction.saveChanges],
                messageText: "Save changes to \(name)",
                informativeText: "The document \(name) has unsaved changes. Save them now?").run()
                else { return }
            switch result {
            case .saveChanges:
                var saveURL: URL

                if let url = previousDocument.fileURL {
                    saveURL = url
                } else {
                    let dialog = NSSavePanel()

                    dialog.title                   = "Save .component file"
                    dialog.showsResizeIndicator    = true
                    dialog.showsHiddenFiles        = false
                    dialog.canCreateDirectories    = true
                    dialog.allowedFileTypes        = ["component"]

                    // User canceled the save. Don't swap out the document.
                    if dialog.runModal() != NSApplication.ModalResponse.OK {
                        return
                    }

                    guard let url = dialog.url else { return }

                    saveURL = url
                }

                previousDocument.save(to: saveURL, ofType: previousDocument.fileType ?? "DocumentType", for: NSDocument.SaveOperationType.saveOperation, completionHandler: { error in
                    // TODO: We should not close the document if it fails to save
                    Swift.print("Failed to save", saveURL, error as Any)
                })

                LonaPlugins.current.trigger(eventType: .onSaveComponent)
            case .cancel:
                return
            case .discardChanges:
                break
            }
        }

        if FileUtils.fileExists(atPath: path) == .none {
            return
        }

        let url = URL(fileURLWithPath: path)

        if FileUtils.fileExists(atPath: path) == .directory {
            guard let newDocument = try? NSDocumentController.shared.makeDocument(withContentsOf: url, ofType: "DirectoryDocument") else {
                Swift.print("Failed to open", url)
                NSDocumentController.shared.removeDocument(previousDocument)
                let windowController = previousDocument.windowControllers[0]
                windowController.document = nil
                previousDocument.removeWindowController(windowController)
                self.document = nil
                self.inspectedContent = nil
                return
            }

            NSDocumentController.shared.addDocument(newDocument)

            guard let windowController = self.view.window?.windowController else { return }

            newDocument.addWindowController(windowController)
            windowController.document = newDocument
            self.document = newDocument

            // Set this after updating the document (which calls update)
            // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
            self.inspectedContent = nil
            return
        }

        NSDocumentController.shared.openDocument(withContentsOf: url, display: false, completionHandler: { newDocument, documentWasAlreadyOpen, error in

            guard let newDocument = newDocument else {
                Swift.print("Failed to open", url, error as Any)
                NSDocumentController.shared.removeDocument(previousDocument)
                let windowController = previousDocument.windowControllers[0]
                windowController.document = nil
                previousDocument.removeWindowController(windowController)
                self.document = nil
                self.inspectedContent = nil

                return
            }

            // TODO: This improves the UX of opening files (particularly components), since we can preserve the
            // window state of a document when switching between files. However, it causes some files to be unopenable
            // after double clicking in the directory view, so we've disabled it for now.
//            if documentWasAlreadyOpen && previousDocument.className == newDocument.className {
//                newDocument.showWindows()
//                return
//            }

            NSDocumentController.shared.removeDocument(previousDocument)

            let windowController = previousDocument.windowControllers[0]
            newDocument.addWindowController(windowController)
            windowController.document = newDocument
            self.document = newDocument

            // Set this after updating the document (which calls update)
            // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
            self.inspectedContent = nil
        })
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

    // Documents

    private func createAndShowNewDocument(in windowController: NSWindowController) {
        let newDocument = ComponentDocument()
        newDocument.component = CSComponent.makeDefaultComponent()

        NSDocumentController.shared.addDocument(newDocument)
        newDocument.addWindowController(windowController)
        windowController.document = newDocument

        self.document = newDocument

        // Set this after updating the document (which calls update)
        // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
        self.inspectedContent = nil
    }

    @discardableResult private func close(document: NSDocument, discardingUnsavedChanges: Bool) -> Bool {
        if !discardingUnsavedChanges && document.isDocumentEdited {
            let name = document.fileURL?.lastPathComponent ?? "Untitled"
            guard let result = Alert(
                items: [
                    DocumentAction.cancel,
                    DocumentAction.discardChanges,
                    DocumentAction.saveChanges],
                messageText: "Save changes to \(name)",
                informativeText: "The document \(name) has unsaved changes. Save them now?").run()
                else { return false }
            switch result {
            case .saveChanges:
                var saveURL: URL

                if let url = document.fileURL {
                    saveURL = url
                } else {
                    let dialog = NSSavePanel()

                    dialog.title                   = "Save .component file"
                    dialog.showsResizeIndicator    = true
                    dialog.showsHiddenFiles        = false
                    dialog.canCreateDirectories    = true
                    dialog.allowedFileTypes        = ["component"]

                    // User canceled the save. Don't swap out the document.
                    if dialog.runModal() != NSApplication.ModalResponse.OK {
                        return false
                    }

                    guard let url = dialog.url else { return false }

                    saveURL = url
                }

                document.save(to: saveURL, ofType: document.fileType ?? "DocumentType", for: NSDocument.SaveOperationType.saveOperation, completionHandler: { error in
                    // TODO: We should not close the document if it fails to save
                    Swift.print("Failed to save", saveURL, error as Any)
                })

                LonaPlugins.current.trigger(eventType: .onSaveComponent)
            case .cancel:
                return false
            case .discardChanges:
                break
            }
        }

        NSDocumentController.shared.removeDocument(document)

        if let windowController = document.windowControllers.first {
            windowController.document = nil
            document.removeWindowController(windowController)
        }

        self.document = nil

        // Set this after updating the document (which calls update)
        // TODO: There shouldn't need to be an implicit ordering. Maybe we call update() manually.
        self.inspectedContent = nil

        return true
    }
}

// MARK: - IBActions

extension WorkspaceViewController {
    @IBAction func newDocument(_ sender: AnyObject) {
        if let document = self.document {
            guard close(document: document, discardingUnsavedChanges: false) else { return }
        }

        guard let windowController = self.view.window?.windowController else { return }

        createAndShowNewDocument(in: windowController)
    }

    @objc func document(_ doc: NSDocument?, didSave: Bool, contextInfo: UnsafeMutableRawPointer?) {
        update()
        fileNavigator.reloadData()
    }

    @objc func documentDidSaveAs(_ doc: NSDocument?, didSave: Bool, contextInfo: UnsafeMutableRawPointer?) {
        update()
        fileNavigator.reloadData()
    }

    @objc func document(_ doc: NSDocument?, didDuplicate: Bool, contextInfo: UnsafeMutableRawPointer?) {
        update()
        fileNavigator.reloadData()
    }

    @IBAction func saveDocument(_ sender: AnyObject) {
        document?.save(
            withDelegate: self,
            didSave: #selector(document(_:didSave:contextInfo:)),
            contextInfo: nil)
    }

    // https://developer.apple.com/documentation/appkit/nsdocument/1515171-saveas
    // The default implementation runs the modal Save panel to get the file location under which
    // to save the document. It writes the document to this file, sets the document’s file location
    // and document type (if a native type), and clears the document’s edited status.
    @IBAction func saveDocumentAs(_ sender: AnyObject) {
        document?.runModalSavePanel(
            for: .saveAsOperation,
            delegate: self,
            didSave: #selector(documentDidSaveAs(_:didSave:contextInfo:)),
            contextInfo: nil)
    }

    @IBAction func duplicate(_ sender: AnyObject) {
        document?.duplicate(
            withDelegate: self,
            didDuplicate: #selector(document(_:didDuplicate:contextInfo:)),
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
