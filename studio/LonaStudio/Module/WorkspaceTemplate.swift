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
                                    .namespace(
                                        id: UUID(),
                                        name: .init(id: UUID(), name: "Colors"),
                                        declarations: LGCList<LGCDeclaration>(
                                            [
                                                .variable(
                                                    id: UUID(),
                                                    name: .init(id: UUID(), name: "red50"),
                                                    annotation: .typeIdentifier(
                                                        id: UUID(),
                                                        identifier: .init(id: UUID(), string: "Color"),
                                                        genericArguments: .empty
                                                    ),
                                                    initializer: .literalExpression(
                                                        id: UUID(),
                                                        literal: .color(id: UUID(), value: "#F0A0B0")
                                                    )
                                                )
                                            ]
                                        )
                                    )
                                ]
                            )
                        )
                    )
                    let data: Data = try! LogicDocument.encode(program)
                    return data
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
