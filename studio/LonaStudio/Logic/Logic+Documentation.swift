//
//  Logic+Documentation.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/21/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

extension LogicViewController {
    public static func documentationForSuggestion(
        rootNode: LGCSyntaxNode,
        suggestionItem: LogicSuggestionItem,
        query: String,
        formattingOptions: LogicFormattingOptions,
        suggestionBuilder builder: LogicSuggestionItem.DynamicSuggestionBuilder
    ) -> NSView {
        switch suggestionItem.node {
        case .expression(.functionCallExpression(_, expression: .identifierExpression(_, identifier: let identifier), arguments: _))
            where identifier.string == "Shadow" && suggestionItem.category == LGCLiteral.Suggestion.categoryTitle:

            let decodeValue: (Data?) -> PickerShadow = { data in
                if let data = data, let shadowValue = try? JSONDecoder().decode(PickerShadow.self, from: data) {
                    return shadowValue
                } else {
                    return .init(x: 0, y: 1, blur: 2, radius: 0, opacity: 0)
                }
            }

            let view = ShadowSuggestionEditor()

            view.shadowValue = decodeValue(builder.initialValue)

            view.onChangeShadowValue = { shadowValue in
                view.shadowValue = shadowValue

                if let data = try? JSONEncoder().encode(shadowValue) {
                    builder.onChangeValue(data)
                }
            }

            view.onSubmit = {
                builder.onSubmit()
            }

            builder.setNodeBuilder({ data in
                let shadowValue = decodeValue(data)

                return .expression(
                    .functionCallExpression(
                        id: UUID(),
                        expression: .identifierExpression(id: UUID(), identifier: .init("Shadow")),
                        arguments: .init([
                            .argument(
                                id: UUID(),
                                label: "x",
                                expression: .literalExpression(id: UUID(), literal: .number(id: UUID(), value: CGFloat(shadowValue.x)))
                            ),
                            .argument(
                                id: UUID(),
                                label: "y",
                                expression: .literalExpression(id: UUID(), literal: .number(id: UUID(), value: CGFloat(shadowValue.y)))
                            ),
                            .argument(
                                id: UUID(),
                                label: "blur",
                                expression: .literalExpression(id: UUID(), literal: .number(id: UUID(), value: CGFloat(shadowValue.blur)))
                            ),
                            .argument(
                                id: UUID(),
                                label: "radius",
                                expression: .literalExpression(id: UUID(), literal: .number(id: UUID(), value: CGFloat(shadowValue.radius)))
                            ),
                            .argument(
                                id: UUID(),
                                label: "color",
                                expression: .literalExpression(id: UUID(), literal: .color(id: UUID(), value: "black"))
                            )
                        ])
                    )
                )
            })

            return view
        case .expression(.literalExpression(id: _, literal: .color(id: _, value: let css))),
             .literal(.color(id: _, value: let css)):

            let decodeValue: (Data?) -> SwiftColor = { data in
                if let data = data, let cssString = String(data: data, encoding: .utf8) {
                    return SwiftColor(cssString: cssString)
                } else {
                    // Improve the empty state by setting alpha to 1 initially
                    if css == "" {
                        return SwiftColor(red: 0, green: 0, blue: 0)
                    }
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
}
