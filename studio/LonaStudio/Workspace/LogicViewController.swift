//
//  LogicViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicViewController

class LogicViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var rootNode: LGCSyntaxNode = .topLevelDeclarations(
        .init(
            id: UUID(),
            declarations: .init([.makePlaceholder()])
        )
    ) { didSet { update() } }

    override var undoManager: UndoManager? { return nil }

    public var onChangeRootNode: ((LGCSyntaxNode) -> Void)?

    // MARK: Private

    private let logicEditor = LogicEditor()
    private let infoBar = InfoBar()
    private let divider = Divider()
    private let containerView = NSBox()

    private var imports: Set<String> = Set()
    private var colorValues: [UUID: String] = [:]
    private var shadowValues: [UUID: NSShadow] = [:]
    private var textStyleValues: [UUID: Logic.TextStyle] = [:]

    private let editorDisplayStyles: [LogicFormattingOptions.Style] = [.visual, .natural]

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero

        containerView.addSubview(logicEditor)
        containerView.addSubview(infoBar)
        containerView.addSubview(divider)

        infoBar.fillColor = Colors.contentBackground

        divider.fillColor = NSSplitView.defaultDividerColor

        logicEditor.placeholderText = "Search or create"
        logicEditor.fillColor = Colors.contentBackground
        logicEditor.canvasStyle.textMargin = .init(width: 10, height: 6)
        logicEditor.showsFilterBar = true
        logicEditor.showsMinimap = true
        logicEditor.suggestionFilter = LogicViewController.suggestionFilter

        logicEditor.onChangeSuggestionFilter = { [unowned self] value in
            self.logicEditor.suggestionFilter = value
            LogicViewController.suggestionFilter = value
        }

        logicEditor.formattingOptions = LogicFormattingOptions(
            style: LogicViewController.formattingStyle,
            getError: ({ [unowned self ] id in
                if let error = self.logicEditor.elementErrors.first(where: { $0.uuid == id }) {
                    return error.message
                } else {
                    return nil
                }
            }),
            getArguments: ({ [unowned self] id in
                let unification = LonaModule.current.logic.compiled.unification

                let rootNode = self.logicEditor.rootNode

                return StandardConfiguration.formatArguments(
                    rootNode: rootNode,
                    id: id,
                    unificationContext: unification?.0,
                    substitution: unification?.1
                )
            }),
            getColor: ({ id in
                guard let evaluation = LonaModule.current.logic.compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                guard let colorString = value.colorString, let color = NSColor.parse(css: colorString) else { return nil }
                return (colorString, color)
            }),
            getTextStyle: ({ id in
                guard let evaluation = LonaModule.current.logic.compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                return value.textStyle
            }),
            getShadow: ({ id in
                guard let evaluation = LonaModule.current.logic.compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                return value.nsShadow
            })
        )

        infoBar.dropdownIndex = editorDisplayStyles.firstIndex(of: LogicViewController.formattingStyle) ?? 0
        infoBar.dropdownValues = editorDisplayStyles.map { $0.displayName }
        infoBar.onChangeDropdownIndex = { [unowned self] index in
            LogicViewController.formattingStyle = self.editorDisplayStyles[index]
            let newFormattingOptions = self.logicEditor.formattingOptions
            newFormattingOptions.style = self.editorDisplayStyles[index]
            self.logicEditor.formattingOptions = newFormattingOptions
            self.infoBar.dropdownIndex = index
        }

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false

        logicEditor.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        logicEditor.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        logicEditor.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true

        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        divider.bottomAnchor.constraint(equalTo: infoBar.topAnchor).isActive = true

        infoBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        infoBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        infoBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

    private func update() {
        let compiled = LonaModule.current.logic.compiled

        logicEditor.rootNode = rootNode

        let imports = rootNode.reduce(initialResult: Set<String>()) { (result, node, config) -> Set<String> in
            switch node {
            case .declaration(.importDeclaration(_, name: let name)):
                return result.union([name.name])
            default:
                return result
            }
        }

        logicEditor.elementErrors = compiled.errors.filter { rootNode.find(id: $0.uuid) != nil }

        logicEditor.onChangeRootNode = { [unowned self] newRootNode in
            self.onChangeRootNode?(newRootNode)
            return true
        }

        logicEditor.suggestionsForNode = { rootNode, node, query in
            let compiled = LonaModule.current.logic.compiled

            let recommended = LogicViewController.recommendedSuggestions(
                rootNode: compiled.programNode,
                selectedNode: node,
                query: query,
                imports: imports
            )

            return recommended
        }

        logicEditor.documentationForSuggestion = { rootNode, suggestionItem, query, formattingOptions, builder in
            switch suggestionItem.node {
            case .expression(.literalExpression(id: _, literal: .color(id: _, value: let css))),
                 .literal(.color(id: _, value: let css)):

                let decodeValue: (Data?) -> SwiftColor = { data in
                    if let data = data, let cssString = String(data: data, encoding: .utf8) {
                        return SwiftColor(cssString: cssString)
                    } else {
                        return SwiftColor(cssString: css)
                    }
                }

                var colorValue = decodeValue(builder.initialValue)
                let view = ColorSuggestionEditor(colorValue: colorValue)

                view.onChangeColorValue = { color in
                    colorValue = color

                    // Setting the color to nil is a hack to force the color picker to re-draw even if the color values are equal.
                    // The Color library tests for equality in a way that prevents us from changing the hue of the color when the
                    // saturation and lightness are 0.
                    view.colorValue = nil
                    view.colorValue = colorValue

                    builder.setListItem(.colorRow(name: "Color", code: color.cssString, color.NSColor, false))

                    if let data = colorValue.cssString.data(using: .utf8) {
                        builder.onChangeValue(data)
                    }
                }

                view.onReset = {
                    let color = SwiftColor(cssString: css)

                    colorValue = color
                    view.colorValue = colorValue

                    builder.onChangeValue(nil)
                    builder.setListItem(nil)
                }

                view.onSubmit = {
                    builder.onSubmit()
                }

                builder.setNodeBuilder({ data in
                    let cssValue = data != nil ? decodeValue(data).cssString : css
                    let literal = LGCLiteral.color(id: UUID(), value: cssValue)
                    switch suggestionItem.node {
                    case .literal:
                        return .literal(literal)
                    case .expression:
                        return .expression(.literalExpression(id: UUID(), literal: literal))
                    default:
                        fatalError("Unsupported node")
                    }
                })

                return view
            default:
                return LogicEditor.defaultDocumentationForSuggestion(rootNode, suggestionItem, query, formattingOptions, builder)
            }
        }

        logicEditor.decorationForNodeID = { [unowned self] id in
            guard let node = self.logicEditor.rootNode.find(id: id) else { return nil }

            if let colorValue = LonaModule.current.logic.compiled.evaluation?.evaluate(uuid: id)?.colorString {
                if self.logicEditor.formattingOptions.style == .visual,
                    let path = self.logicEditor.rootNode.pathTo(id: id),
                    let parent = path.dropLast().last {

                    // Don't show color decoration on the variable name
                    switch parent {
                    case .declaration(.variable):
                        return nil
                    default:
                        break
                    }

                    // Don't show color decoration of literal value if we're already showing a swatch preview
                    if let grandParent = path.dropLast().dropLast().last {
                        switch (grandParent, parent, node) {
                        case (.declaration(.variable), .expression(.literalExpression), .literal(.color)):
                            return nil
                        default:
                            break
                        }
                    }
                }

                return .color(NSColor.parse(css: colorValue) ?? NSColor.black)
            }

            switch node {
            case .literal(.color(id: _, value: let code)):
                return .color(NSColor.parse(css: code) ?? .clear)
            default:
                return nil
            }
        }
    }

    public static func makeGetColor(rootNode: LGCSyntaxNode) -> (UUID) -> (String, NSColor)? {
        return { id in
            guard let node = rootNode.find(id: id) else { return nil }
            switch node {
            case .expression(.literalExpression(_, literal: .color(_, value: let value))):
                return (value, NSColor.parse(css: value) ?? .clear)
            default:
                return nil
            }
        }
    }

    public static func makeFormattingOptions(rootNode: LGCSyntaxNode) -> LogicFormattingOptions {
        return .init(style: formattingStyle, locale: .en_US, getColor: makeGetColor(rootNode: rootNode))
    }

    public static func recommendedSuggestions(rootNode: LGCSyntaxNode, selectedNode: LGCSyntaxNode, query: String, imports: Set<String>) -> [LogicSuggestionItem] {
        var all: [LogicSuggestionItem]
        if let suggestionBuilder = StandardConfiguration.suggestions(
            rootNode: rootNode,
            node: selectedNode,
            formattingOptions: makeFormattingOptions(rootNode: rootNode)
            ),
            let suggestions = suggestionBuilder(query) {
            all = suggestions
        } else {
            switch selectedNode {
            case .declaration:
                all = [
                    LGCDeclaration.Suggestion.variable(query: query),
                    LGCDeclaration.Suggestion.namespace(query: query),
                    LGCDeclaration.Suggestion.record(query: query),
                    LGCDeclaration.Suggestion.enum(query: query),
                    LGCDeclaration.Suggestion.import
                    ].compactMap { $0 }
            default:
                all = LogicEditor.defaultSuggestionsForNode(rootNode, selectedNode, query)
            }
        }

        switch selectedNode {
        case .declaration:
            let variableId = UUID()
            let valueId = UUID()
            let colorVariable = LogicSuggestionItem(
                title: "Color Variable\(query.isEmpty ? "" : ": " + query)",
                category: "Declarations".uppercased(),
                node: LGCSyntaxNode.declaration(
                    LGCDeclaration.variable(
                        id: UUID(),
                        name: LGCPattern(id: variableId, name: query.isEmpty ? "name" : query),
                        annotation: LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Color", isPlaceholder: false),
                            genericArguments: .empty
                        ),
                        initializer: .literalExpression(id: valueId, literal: .color(id: UUID(), value: "white")),
                        comment: nil
                    )
                ),
                suggestionFilters: [.recommended, .all],
                nextFocusId: query.isEmpty ? variableId : valueId,
                documentation: ({ builder in
                    return LightMark.makeScrollView(markdown: """
# Color Variable

Define a color variable that can be used throughout your design system and UI components.

## Example

We might define a variable, `ocean`, to represent the hex code `#69D2E7`:

```logic
<Declarations>
  <Variable name="ocean" type="Color" value="#69D2E7"/>
</Declarations>
```

## Naming Conventions

There are a variety of naming conventions for colors, each with their own strengths and weaknesses. For more details and recommendations on naming conventions, see [this documentation page](http://google.com).

""", renderingOptions: .init(formattingOptions: .normal))
                })
            )

            let shadowVariable = LogicSuggestionItem(
                title: "Shadow Variable\(query.isEmpty ? "" : ": " + query)",
                category: "Declarations".uppercased(),
                node: LGCSyntaxNode.declaration(
                    LGCDeclaration.variable(
                        id: UUID(),
                        name: LGCPattern(id: variableId, name: query.isEmpty ? "name" : query),
                        annotation: LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Shadow", isPlaceholder: false),
                            genericArguments: .empty
                        ),
                        initializer: .identifierExpression(
                            id: UUID(),
                            identifier: LGCIdentifier(id: valueId, string: "value", isPlaceholder: true)
                        ),
                        comment: nil
                    )
                ),
                suggestionFilters: [.recommended, .all],
                nextFocusId: query.isEmpty ? variableId : valueId,
                documentation: ({ builder in
                    return LightMark.makeScrollView(markdown: """
# Shadow Variable

Define a shadow variable that can be used throughout your design system and UI components.
""", renderingOptions: .init(formattingOptions: builder.formattingOptions))
                })
            )

            let textStyleVariable = LogicSuggestionItem(
                title: "Text Style Variable\(query.isEmpty ? "" : ": " + query)",
                category: "Declarations".uppercased(),
                node: LGCSyntaxNode.declaration(
                    LGCDeclaration.variable(
                        id: UUID(),
                        name: LGCPattern(id: variableId, name: query.isEmpty ? "name" : query),
                        annotation: LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "TextStyle", isPlaceholder: false),
                            genericArguments: .empty
                        ),
                        initializer: .identifierExpression(
                            id: UUID(),
                            identifier: LGCIdentifier(id: valueId, string: "value", isPlaceholder: true)
                        ),
                        comment: nil
                    )
                ),
                suggestionFilters: [.recommended, .all],
                nextFocusId: query.isEmpty ? variableId : valueId,
                documentation: ({ builder in
                    return LightMark.makeScrollView(markdown: """
# Text Style Variable

Define a text style variable that can be used throughout your design system and UI components.
""", renderingOptions: .init(formattingOptions: builder.formattingOptions))
                })
            )

            let patternId = UUID()

            let namespace = LogicSuggestionItem(
                title: "Variable Group\(query.isEmpty ? "" : ": " + query)",
                category: "Declarations".uppercased(),
                node: LGCSyntaxNode.declaration(
                    LGCDeclaration.namespace(
                        id: UUID(),
                        name: LGCPattern(id: patternId, name: query.isEmpty ? "Name" : query),
                        declarations: .next(LGCDeclaration.placeholder(id: valueId), .empty)
                    )
                ),
                suggestionFilters: [.recommended],
                nextFocusId: query.isEmpty ? patternId : valueId,
                documentation: ({ builder in
                    LightMark.makeScrollView(markdown: """
# Variable Group

A group of variables and other declarations, sometimes called a namespace.

This will generate fairly different code for each platform, so if you're curious to see what it turns into, open the split preview pane.
""", renderingOptions: .init(formattingOptions: builder.formattingOptions))
                })
            )

            var suggestedVariables: [LogicSuggestionItem] = []

            if imports.contains("Color") || imports.contains("TextStyle") || imports.contains("Shadow") {
                suggestedVariables.append(colorVariable)
            }
            if imports.contains("Shadow") {
                suggestedVariables.append(shadowVariable)
            }
            if imports.contains("TextStyle") {
                suggestedVariables.append(textStyleVariable)
            }

            return (suggestedVariables + [namespace]).titleContains(prefix: query) + all
        default:
            break
        }

        return all.map {
            var node = $0
            node.suggestionFilters = [.recommended, .all]
            return node
        }
    }

    private static var formattingStyleKey = "Logic editor style"

    static var formattingStyle: LogicFormattingOptions.Style {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: formattingStyleKey),
                let value = LogicFormattingOptions.Style(rawValue: rawValue) else {
                return LogicFormattingOptions.Style.visual
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: formattingStyleKey)
        }
    }

    private static var suggestionFilterKey = "Logic editor suggestion filter"

    static var suggestionFilter: SuggestionView.SuggestionFilter {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: suggestionFilterKey) else {
                return .recommended
            }
            switch rawValue {
            case "all":
                return .all
            default:
                return .recommended
            }
        }
        set {
            var rawValue: String
            switch newValue {
            case .all:
                rawValue = "all"
            case .recommended:
                rawValue = "recommended"
            }
            UserDefaults.standard.set(rawValue, forKey: suggestionFilterKey)
        }
    }
}

extension LogicViewController {

    // MARK: Public

    public enum ThumbnailStyle: Int {
        case standard, bordered
    }

    public static func thumbnail(
        for url: URL,
        within size: NSSize,
        canvasSize: NSSize = .init(width: 800, height: 200),
        viewportRect: NSRect = .init(x: 0, y: 0, width: 200, height: 200),
        style: ThumbnailStyle) -> NSImage {
        let key = cacheKey(size: size)

        if let image = thumbnailImageCache[url]?[key] {
            return image
        } else {
            let image = makeThumbnail(for: url, within: size, canvasSize: canvasSize, viewportRect: viewportRect, style: style)

            if thumbnailImageCache[url] == nil {
                thumbnailImageCache[url] = [:]
            }

            thumbnailImageCache[url]?[key] = image

            return image
        }
    }

    // MARK: Private

    public static func invalidateThumbnail(url: URL) {
        thumbnailImageCache.removeValue(forKey: url)
    }

    private static var thumbnailImageCache: [URL: [Int: NSImage]] = [:]

    private static func cacheKey(size: NSSize) -> Int {
        var hasher = Hasher()
        hasher.combine(size.width)
        hasher.combine(size.height)
        return hasher.finalize()
    }

    private static func makeThumbnail(
        for url: URL,
        within size: NSSize,
        canvasSize: NSSize,
        viewportRect: NSRect,
        style: ThumbnailStyle
        ) -> NSImage {
        guard let rootNode = LogicModule.load(url: url) else { return NSImage() }

        let compiled = LonaModule.current.logic.compiled

        let formattingOptions = LogicFormattingOptions(
            style: LogicViewController.formattingStyle,
            getColor: ({ id in
                guard let colorString = compiled.evaluation?.evaluate(uuid: id)?.colorString,
                    let color = NSColor.parse(css: colorString) else { return nil }
                return (colorString, color)
            })
        )

        let getElementDecoration: (UUID) -> LogicElement.Decoration? = { uuid in
            return decorationForNodeID(
                rootNode: compiled.programNode,
                formattingOptions: formattingOptions,
                evaluationContext: compiled.evaluation,
                id: uuid
            )
        }

        guard let pdfData = LogicCanvasView.pdf(
            size: canvasSize,
            mediaBox: viewportRect,
            formattedContent: LGCSyntaxNode.program(rootNode).formatted(using: formattingOptions),
            getElementDecoration: getElementDecoration) else { return NSImage() }

        let image = NSImage(size: size, flipped: false, drawingHandler: { rect in
            NSGraphicsContext.saveGraphicsState()

            switch style {
            case .bordered:
                let inset = NSSize(width: 1, height: 1)
                let insetRect = rect.insetBy(dx: inset.width, dy: inset.height)

                let outline = NSBezierPath(roundedRect: insetRect, xRadius: 2, yRadius: 2)
                outline.lineWidth = 2

                NSColor.parse(css: "rgb(210,210,212)")!.setStroke()
                NSColor.white.withAlphaComponent(0.9).setFill()

                outline.fill()
                outline.setClip()

                if let pdfImage = NSImage(data: pdfData) {
                    pdfImage.draw(in: NSRect(x: inset.width, y: inset.height, width: rect.width, height: rect.height))
                }

                outline.stroke()
            case .standard:
                if let pdfImage = NSImage(data: pdfData) {
                    pdfImage.draw(in: rect)
                }
            }

            NSGraphicsContext.restoreGraphicsState()
            return true
        })

        return image
    }

    private static func decorationForNodeID(
        rootNode: LGCSyntaxNode,
        formattingOptions: LogicFormattingOptions,
        evaluationContext: Compiler.EvaluationContext?,
        id: UUID
        ) -> LogicElement.Decoration? {
        guard let node = rootNode.find(id: id) else { return nil }

        if let colorValue = evaluationContext?.evaluate(uuid: node.uuid)?.colorString {
            if formattingOptions.style == .visual,
                let path = rootNode.pathTo(id: id),
                let parent = path.dropLast().last {

                // Don't show color decoration on the variable name
                switch parent {
                case .declaration(.variable):
                    return nil
                default:
                    break
                }

                // Don't show color decoration of literal value if we're already showing a swatch preview
                if let grandParent = path.dropLast().dropLast().last {
                    switch (grandParent, parent, node) {
                    case (.declaration(.variable), .expression(.literalExpression), .literal(.color)):
                        return nil
                    default:
                        break
                    }
                }
            }

            return .color(NSColor.parse(css: colorValue) ?? NSColor.black)
        }

        switch node {
        case .literal(.color(id: _, value: let code)):
            return .color(NSColor.parse(css: code) ?? .clear)
        default:
            return nil
        }
    }
}
