//
//  ProjectTemplates.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/28/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

private let designTokensReadmeContents = """
## Overview

Here we define the tokens (colors, text styles, shadows, etc) of our design system.

We then use the Lona compiler to convert this design system to platform-specific code.

> You can learn more about Lona [here](https://github.com/airbnb/Lona).
"""

private let componentLibraryReadmeContents = """
## Overview

This is a Lona workspace.

Here we define the components, tokens (colors, text styles, shadows, etc), and data types that make up our design system.

We then use the Lona compiler to convert this design system to platform-specific code.

> You can learn more about Lona [here](https://github.com/airbnb/Lona).
"""

enum WorkspaceTemplate {
    case designTokens, componentLibrary

    func make(workspaceName: String) -> VirtualNode {
        switch self {
        case .componentLibrary:
            return WorkspaceTemplate.makeComponentLibraryWorkspace(workspaceName: workspaceName)
        case .designTokens:
            return WorkspaceTemplate.makeDesignTokensWorkspace(workspaceName: workspaceName)
        }
    }

    static func makeDesignTokensWorkspace(workspaceName: String) -> VirtualNode {
        func makeColor(name: String, colorString: String) -> LGCDeclaration {
            return .variable(
                name: name,
                annotation: .typeIdentifier(name: "Color"),
                initializer: .colorLiteral(colorString)
            )
        }

        func makeShadow(name: String, y: CGFloat, blur: CGFloat, colorIdentifier: String) -> LGCDeclaration {
            return .variable(
                name: name,
                annotation: .typeIdentifier(name: "Shadow"),
                initializer: .functionCallExpression(
                    id: UUID(),
                    expression: .identifierExpression(id: UUID(), identifier: .init("Shadow")),
                    arguments: .init(
                        [
                            .argument(id: UUID(), label: "y", expression: .numberLiteral(y)),
                            .argument(id: UUID(), label: "blur", expression: .numberLiteral(blur)),
                            .argument(id: UUID(), label: "color", expression: .identifierExpression(id: UUID(), identifier: .init(colorIdentifier)))
                        ]
                    )
                )
            )
        }

        func makeOptional(expression: LGCExpression) -> LGCExpression {
            return .functionCallExpression(
                id: UUID(),
                expression: .memberExpression(
                    id: UUID(),
                    expression: LGCExpression.identifierExpression(id: UUID(), identifier: .init("Optional")),
                    memberName: .init("value")
                ),
                arguments: .init(
                    [
                        .argument(id: UUID(), label: nil, expression: expression)
                    ]
                )
            )
        }

        func makeTextStyle(name: String, fontSize: CGFloat, colorIdentifier: String) -> LGCDeclaration {
            return .variable(
                name: name,
                annotation: .typeIdentifier(name: "TextStyle"),
                initializer: .functionCallExpression(
                    id: UUID(),
                    expression: .identifierExpression(id: UUID(), identifier: .init("TextStyle")),
                    arguments: .init(
                        [
                            .argument(
                                id: UUID(),
                                label: "fontSize",
                                expression: makeOptional(expression: .numberLiteral(fontSize))
                            ),
                            .argument(
                                id: UUID(),
                                label: "color",
                                expression: makeOptional(expression: .identifierExpression(id: UUID(), identifier: .init(colorIdentifier)))
                            )
                        ]
                    )
                )
            )
        }

        func makeImport(name: String) -> LGCDeclaration {
            return .importDeclaration(id: UUID(), name: LGCPattern(id: UUID(), name: name))
        }

        func makeNamespace(name: String, declarations: [LGCDeclaration]) -> LGCDeclaration {
            return .namespace(
                id: UUID(),
                name: .init(id: UUID(), name: name),
                declarations: LGCList<LGCDeclaration>(declarations)
            )
        }

        return VirtualDirectory(name: workspaceName) {
            [
                VirtualFile(name: "README.md") {
                    designTokensReadmeContents.data(using: .utf8)!
                },
                VirtualFile(name: "lona.json") {
                    CSData.Object([:])
                },
                VirtualFile(name: "Colors.logic", contents: {
                    let program = LGCSyntaxNode.topLevelDeclarations(
                        .init(
                            id: UUID(),
                            declarations: LGCList<LGCDeclaration>(
                                [
                                    makeImport(name: "Color"),
                                    makeNamespace(
                                        name: "Colors",
                                        declarations: [
                                            makeColor(name: "red", colorString: "#F03E3E"),
                                            makeColor(name: "pink", colorString: "#D6336C"),
                                            makeColor(name: "grape", colorString: "#AE3EC9"),
                                            makeColor(name: "violet", colorString: "#7048E8"),
                                            makeColor(name: "indigo", colorString: "#4263EB"),
                                            makeColor(name: "blue", colorString: "#1C7ED6"),
                                            makeColor(name: "cyan", colorString: "#1098AD"),
                                            makeColor(name: "teal", colorString: "#0CA678"),
                                            makeColor(name: "green", colorString: "#37B24D"),
                                            makeColor(name: "lime", colorString: "#74B816"),
                                            makeColor(name: "yellow", colorString: "#F59F00"),
                                            makeColor(name: "orange", colorString: "#F76707")
                                        ]
                                    )
                                ]
                            )
                        )
                    )
                    return try! LogicDocument.encode(program)
                }),
                VirtualFile(name: "Shadows.logic", contents: {
                    let program = LGCSyntaxNode.topLevelDeclarations(
                        .init(
                            id: UUID(),
                            declarations: LGCList<LGCDeclaration>(
                                [
                                    makeImport(name: "Shadow"),
                                    makeColor(name: "shadowColor", colorString: "rgba(0,0,0,0.4)"),
                                    makeNamespace(
                                        name: "Shadows",
                                        declarations: [
                                            makeShadow(name: "small", y: 1, blur: 2, colorIdentifier: "shadowColor"),
                                            makeShadow(name: "medium", y: 2, blur: 4, colorIdentifier: "shadowColor"),
                                            makeShadow(name: "large", y: 3, blur: 6, colorIdentifier: "shadowColor")
                                        ]
                                    )
                                ]
                            )
                        )
                    )
                    return try! LogicDocument.encode(program)
                }),
                VirtualFile(name: "TextStyles.logic", contents: {
                    let program = LGCSyntaxNode.topLevelDeclarations(
                        .init(
                            id: UUID(),
                            declarations: LGCList<LGCDeclaration>(
                                [
                                    makeImport(name: "TextStyle"),
                                    makeColor(name: "textColor", colorString: "#222"),
                                    makeNamespace(
                                        name: "TextStyle",
                                        declarations: [
                                            makeTextStyle(name: "display", fontSize: 28, colorIdentifier: "textColor"),
                                            makeTextStyle(name: "heading", fontSize: 17, colorIdentifier: "textColor"),
                                            makeTextStyle(name: "body", fontSize: 15, colorIdentifier: "textColor")
                                        ]
                                    )
                                ]
                            )
                        )
                    )
                    return try! LogicDocument.encode(program)
                })
            ]
        }
    }

    static func makeComponentLibraryWorkspace(workspaceName: String) -> VirtualNode {
        return VirtualDirectory(name: workspaceName) {
            [
                VirtualFile(name: "README.md") {
                    componentLibraryReadmeContents.data(using: .utf8)!
                },
                VirtualFile(name: "lona.json") {
                    CSData.Object([:])
                },
                VirtualDirectory(name: "assets"),
                VirtualDirectory(name: "components"),
                VirtualDirectory(name: "foundation") {
                    [
                        VirtualFile(name: "colors.json") {
                            CSData.Object(["colors": CSData.Array([])])
                        },
                        VirtualFile(name: "textStyles.json") {
                            CSData.Object(["styles": CSData.Array([])])
                        },
                        VirtualFile(name: "shadows.json") {
                            CSData.Object(["shadows": CSData.Array([])])
                        }
                    ]
                }
            ]
        }
    }
}
