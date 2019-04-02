//
//  ParameterListEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Logic

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

class ParameterListEditorView: NSView {

    var editorView: ParameterListView

    func renderScrollView() -> NSView {
        let canvasView = LogicEditor(
            rootNode: .topLevelParameters(
                LGCTopLevelParameters(id: UUID(), parameters: .next(.placeholder(id: UUID()), .empty))
            )
        )
        canvasView.documentationForNode = { syntaxNode, query in
            switch syntaxNode {
//            case .typeAnnotation:
//
            case .functionParameter:
                func getTip() -> RichText.BlockElement? {
                    let startsWithNumberMatch = startsWithNumberRegex?.firstMatch(in: query, range: NSRange(location: 0, length: query.count))

                    switch query {
                    case "":
                        return .paragraph(
                            [
                                .text(.link, "Type any parameter name above!")
                            ]
                        )
                    case _ where query.contains(" "):
                        return .paragraph(
                            [
                                .text(.link, "Parameter names can't contain spaces!")
                            ]
                        )
                    case _ where startsWithNumberMatch != nil:
                        return .paragraph(
                            [
                                .text(.link, "Parameter names can't start with numbers!")
                            ]
                        )
                    default:
                        return nil
                    }
                }

                return RichText(
                    blocks: [
                        .heading(.title, "Component parameter"),
                        getTip(),
                        .paragraph(
                            [
                                .text(.none, "Parameters are the "),
                                .text(.bold, "inputs"),
                                .text(.none, " used to configure components. Each parameter has a "),
                                .text(.bold, "name"),
                                .text(.none, ", a "),
                                .text(.bold, "type"),
                                .text(.none, ", and optionally a "),
                                .text(.bold, "default value"),
                                .text(.none, ".")
                            ]
                        ),
                        .heading(.section, "Example"),
                        .paragraph(
                            [
                                .text(.none, "Suppose we want a component with a configurable title. We might define the following parameter:")
                            ]
                        ),
                        .custom(
                            LGCSyntaxNode.functionParameter(
                                .parameter(
                                    id: UUID(),
                                    externalName: nil,
                                    localName: LGCPattern(id: UUID(), name: "titleText"),
                                    annotation: .typeIdentifier(
                                        id: UUID(),
                                        identifier: LGCIdentifier(id: UUID(), string: "String"),
                                        genericArguments: .empty
                                    ),
                                    defaultValue: .none(id: UUID()))
                            ).makeCodeView()
                        ),
                        .heading(.section, "Recommendations"),
                        .paragraph(
                            [
                                .text(.none, "It's best to use "),
                                .text(.link, "camelCase"),
                                .text(.none, " capitalization when choosing parameter names. This is because most JavaScript, Swift, and Kotlin style guides recommend camelCased parameter names. Names can be transformed automatically if needed (for example, when generating a Sketch library).")
                            ]
                        )
                        ].compactMap { $0 }
                )
            default:
                return RichText(blocks: [])
            }
        }
        canvasView.suggestionsForNode = { syntaxNode, query in
            switch syntaxNode {
            case .typeAnnotation:
                let primitiveTypes = CSType.primitiveTypeNames().map { name in
                    LogicSuggestionItem(
                        title: name,
                        category: "Primitive Types".uppercased(),
                        node: LGCSyntaxNode.typeAnnotation(
                            LGCTypeAnnotation.typeIdentifier(
                                id: UUID(),
                                identifier: LGCIdentifier(id: UUID(), string: name),
                                genericArguments: .empty
                            )
                        )
                    )
                }

                let tokenTypes = CSType.tokenTypeNames().map { name in
                    LogicSuggestionItem(
                        title: name,
                        category: "Token Types".uppercased(),
                        node: LGCSyntaxNode.typeAnnotation(
                            LGCTypeAnnotation.typeIdentifier(
                                id: UUID(),
                                identifier: LGCIdentifier(id: UUID(), string: name),
                                genericArguments: .empty
                            )
                        )
                    )
                }

                return (primitiveTypes + tokenTypes).titleContains(prefix: query)
            case .functionParameter:
                let items = [
                    LogicSuggestionItem(
                        title: "Parameter: \(query)",
                        category: "Component Parameter".uppercased(),
                        node: LGCSyntaxNode.functionParameter(
                            LGCFunctionParameter.parameter(
                                id: UUID(),
                                externalName: nil,
                                localName: LGCPattern(id: UUID(), name: query),
                                annotation: LGCTypeAnnotation.typeIdentifier(
                                    id: UUID(),
                                    identifier: LGCIdentifier(id: UUID(), string: "type"),
                                    genericArguments: .empty
                                ),
                                defaultValue: .none(id: UUID())
                            )
                        ),
                        disabled: query.isEmpty
                    )
                ]

                return items
            default:
                return []
            }
        }

        canvasView.fillColor = Colors.contentBackground
        return canvasView

//        let scrollView = NSScrollView(frame: frame)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.documentView = editorView
//        scrollView.hasVerticalRuler = true
//
//        return scrollView
    }

    func renderToolbar() -> NSView {
        let toolbar = NSView()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundFill = NSColor.controlBackgroundColor.cgColor
        toolbar.addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)

        return toolbar
    }

    func renderPlusButton() -> Button {
        let button = Button(frame: NSRect(x: 0, y: 0, width: 24, height: 23))
        button.image = NSImage.init(named: NSImage.addTemplateName)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false

        return button
    }

    var parameterList: [CSParameter] {
        get { return editorView.list }
        set { editorView.list = newValue }
    }

    var onChange: ([CSParameter]) -> Void = {_ in }

    override init(frame frameRect: NSRect) {
        editorView = ParameterListView(frame: frameRect)

        super.init(frame: frameRect)

        // Create views

        let toolbar = renderToolbar()
        let scrollView = renderScrollView()
        let plusButton = renderPlusButton()

        toolbar.addSubview(plusButton)
        addSubview(toolbar)
        addSubview(scrollView)
        addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)

        // Constraints

        constrain(to: scrollView, [.left, .width])
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        constrain(to: toolbar, [.bottom, .left, .width])
        toolbar.constrain(.height, as: 24)

        // Event handlers

        plusButton.onPress = {
            let newItem = CSParameter()
            self.editorView.list.append(newItem)
            self.editorView.select(item: newItem, ensureVisible: true)
        }

        editorView.onChange = { value in
            self.onChange(value)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
