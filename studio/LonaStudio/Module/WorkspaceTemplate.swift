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
# Design System

Our design system contains the following token definitions:

<a class="page" href="Colors.md">Colors</a>

<a class="page" href="TextStyles.md">Text Styles</a>

<a class="page" href="Shadows.md">Shadows</a>
"""

private let componentLibraryReadmeContents = """
## Overview

This is a Lona workspace.

Here we define the components, tokens (colors, text styles, shadows, etc), and data types that make up our design system.

We then use the Lona compiler to convert this design system to platform-specific code.

> You can learn more about Lona [here](https://github.com/airbnb/Lona).
"""

private let colorsDocumentContents = """
# Colors

These are the core colors in our design system.

```tokens
let red: Color = #color(css: "#F03E3E")
```

```tokens
let pink: Color = #color(css: "#D6336C")
```

```tokens
let grape: Color = #color(css: "#AE3EC9")
```

```tokens
let violet: Color = #color(css: "#7048E8")
```

```tokens
let indigo: Color = #color(css: "#4263EB")
```

```tokens
let blue: Color = #color(css: "#1C7ED6")
```

```tokens
let cyan: Color = #color(css: "#1098AD")
```

```tokens
let teal: Color = #color(css: "#0CA678")
```

```tokens
let green: Color = #color(css: "#37B24D")
```

```tokens
let lime: Color = #color(css: "#74B816")
```

```tokens
let yellow: Color = #color(css: "#F59F00")
```

```tokens
let orange: Color = #color(css: "#F76707")
```
"""

private let textStylesDocumentContents = """
# TextStyles

These are the core text styles in our design system.

```tokens
let display: TextStyle = TextStyle(fontSize: Optional.value(28), color: Optional.value(#color(css: "black")))
```

```tokens
let heading: TextStyle = TextStyle(fontSize: Optional.value(17), color: Optional.value(#color(css: "black")))
```

```tokens
let body: TextStyle = TextStyle(fontSize: Optional.value(15), color: Optional.value(#color(css: "black")))
```
"""

private let shadowsDocumentContents = """
# Shadows

These are the core shadows in our design system.

```tokens
let small: Shadow = Shadow(y: 1, blur: 2, color: #color(css: "rgba(0,0,0,0.4)"))
```

```tokens
let medium: Shadow = Shadow(y: 2, blur: 4, color: #color(css: "rgba(0,0,0,0.4)"))
```

```tokens
let large: Shadow = Shadow(y: 3, blur: 6, color: #color(css: "rgba(0,0,0,0.4)"))
```
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

    static func makeColor(name: String, colorString: String) -> LGCDeclaration {
        return .variable(
            name: name,
            annotation: .typeIdentifier(name: "Color"),
            initializer: .colorLiteral(colorString)
        )
    }

    static func makeShadow(name: String, y: CGFloat? = nil, blur: CGFloat? = nil, colorIdentifier: String? = nil) -> LGCDeclaration {
        var arguments: [LGCFunctionCallArgument] = []

        if let y = y {
            arguments.append(.argument(id: UUID(), label: "y", expression: .numberLiteral(y)))
        }

        if let blur = blur {
            arguments.append(.argument(id: UUID(), label: "blur", expression: .numberLiteral(blur)))
        }

        if let colorIdentifier = colorIdentifier {
            arguments.append(.argument(id: UUID(), label: "color", expression: .identifierExpression(id: UUID(), identifier: .init(colorIdentifier))))
        }

        return .variable(
            name: name,
            annotation: .typeIdentifier(name: "Shadow"),
            initializer: .functionCallExpression(
                id: UUID(),
                expression: .identifierExpression(id: UUID(), identifier: .init("Shadow")),
                arguments: .init(arguments)
            )
        )
    }

    static func makeOptional(expression: LGCExpression) -> LGCExpression {
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

    static func makeTextStyle(name: String, fontSize: CGFloat, colorIdentifier: String) -> LGCDeclaration {
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

    static func makeImport(name: String) -> LGCDeclaration {
        return .importDeclaration(id: UUID(), name: LGCPattern(id: UUID(), name: name))
    }

    static func makeNamespace(name: String, declarations: [LGCDeclaration]) -> LGCDeclaration {
        return .namespace(
            id: UUID(),
            name: .init(id: UUID(), name: name),
            declarations: LGCList<LGCDeclaration>(declarations)
        )
    }

    static func makeDesignTokensWorkspace(workspaceName: String) -> VirtualNode {
        return VirtualDirectory(name: workspaceName) {
            [
                VirtualFile(name: "README.md") {
                    designTokensReadmeContents.data(using: .utf8)!
                },
                VirtualFile(name: "lona.json") {
                    CSData.Object([:])
                },
                VirtualFile(name: "Colors.md", contents: {
                    return colorsDocumentContents.data(using: .utf8)!
                }),
                VirtualFile(name: "TextStyles.md", contents: {
                    return textStylesDocumentContents.data(using: .utf8)!
                }),
                VirtualFile(name: "Shadows.md", contents: {
                    return shadowsDocumentContents.data(using: .utf8)!
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
