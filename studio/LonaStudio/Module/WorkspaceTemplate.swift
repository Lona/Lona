//
//  ProjectTemplates.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/28/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

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
                }),
                VirtualDirectory(name: ".github") {
                    [
                        VirtualDirectory(name: "workflows") {
                            [
                                VirtualFile(name: "lona-delete.yml") { lonaDelete.data(using: .utf8)! },
                                VirtualFile(name: "lona-pr.yml") { lonaPR.data(using: .utf8)! },
                                VirtualFile(name: "lona-master.yml") { lonaMaster.data(using: .utf8)! }
                            ]
                        }
                    ]
                }
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

private let lonaDelete = """
name: Lona Delete

on: delete

jobs:
  clean:
    runs-on: ubuntu-latest

    steps:
      - name: Delete outdated website documentation
        uses: Lona/lona-clean-github-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          ref_type: ${{ github.event.ref_type }}
          ref_name: ${{ github.event.ref }}
"""

private let lonaPR = """
name: Lona PR

on:
  push:
    branches-ignore:
      - master

jobs:
  documentation:
    runs-on: ubuntu-latest

    steps:
      - name: Get the latest version of the repository
        uses: actions/checkout@v1

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: "12.x"

      - name: Check if Lona is enabled on this repo
        id: lona
        uses: Lona/lona-github-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          workflow_succeeded: ${{ job.status == 'Success' }}
          ref_name: ${{ github.ref }}

      - name: Restore the dependencies cache
        uses: actions/cache@preview
        with:
          path: node_modules
          key: ${{ runner.os }}-node

      - name: Generate the documentation website
        uses: Lona/lona-docs-github-action@v1
        with:
          output_folder: ${{ steps.lona.outputs.output_folder }}
"""

private let lonaMaster = """
name: Lona Production

on:
  push:
    branches:
      - master

jobs:
  documentation:
    runs-on: ubuntu-latest

    steps:
      - name: Get the latest version of the repository
        uses: actions/checkout@v1

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: "12.x"

      - name: Bump the workspace version
        id: tag_version
        uses: mathieudutour/github-tag-action@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          default_bump: patch

      - name: Check if Lona is enabled on this repo
        id: lona
        uses: Lona/lona-github-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          workflow_succeeded: ${{ job.status == 'Success' }}
          ref_name: refs/tags/${{ steps.tag_version.outputs.new_tag || steps.tag_version.outputs.previous_tag }}

      - name: Install the Lona Compiler
        run: npm install -g @lona/compiler

      - name: Extract the list of design tokens
        run: lona convert . --format=tokens > ${{ steps.lona.outputs.output_folder }}/flat-json.json

      - name: Create a GitHub release
        id: create_release
        uses: actions/create-release@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.tag_version.outputs.new_tag }}
          release_name: Release ${{ steps.tag_version.outputs.new_tag }}
          draft: "false"
          prerelease: "false"

      - name: Publish the design tokens to the release
        uses: actions/upload-release-asset@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ steps.create_release.outputs.upload_url }}
          asset_path: ${{ steps.lona.outputs.output_folder }}/flat-json.json
          asset_name: tokens.json
          asset_content_type: application/json

      - name: Generate the documentation website
        uses: Lona/lona-docs-github-action@v1
        with:
          output_folder: ${{ steps.lona.outputs.output_folder }}

      - name: Pass variables to other actions (1/2)
        run: |
          mkdir -p .__lona-artifact-path
          echo "::set-output name=upload_url::${{ steps.create_release.outputs.upload_url }}
          ::set-output name=new_version::${{ steps.tag_version.outputs.new_version }}
          ::set-output name=new_tag::${{ steps.tag_version.outputs.new_tag }}
          " > .__lona-artifact-path/variables.txt
      - name: Pass variables to other actions (2/2)
        uses: actions/upload-artifact@v1
        with:
          name: lona-variables
          path: .__lona-artifact-path

  sketch-library:
    runs-on: macos-latest
    needs: [documentation]
    steps:
      - name: Get variables from documentation (1/2)
        uses: actions/download-artifact@v1
        with:
          name: lona-variables
          path: .__lona-artifact-path
      - name: Get variables from documentation (2/2)
        run: |
          while read p; do
            echo "$p"
          done <.__lona-artifact-path/variables.txt
        id: variables

      - name: Get the latest version of the repository
        uses: actions/checkout@v1

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: "12.x"

      - name: Install the Lona Compiler
        run: npm install lonac @lona/workspace-to-sketch-library

      - name: Generate the Sketch library
        run: 'node -e "require(''@lona/workspace-to-sketch-library'').default(process.cwd(), ''.__lona-artifact-path/sketch-library.sketch'', { logFunction: console.log.bind(console) }).catch(err => { console.log(err); process.exit(1); })"'

      - name: Publish the Sketch Library to the GitHub release
        uses: actions/upload-release-asset@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ steps.variables.outputs.upload_url }}
          asset_path: .__lona-artifact-path/sketch-library.sketch
          asset_name: library.sketch
          asset_content_type: application/zip

  npm-package:
    runs-on: ubuntu-latest
    needs: [documentation]
    steps:
      - name: Get variables from documentation (1/2)
        uses: actions/download-artifact@v1
        with:
          name: lona-variables
          path: .__lona-artifact-path
      - name: Get variables from documentation (2/2)
        run: |
          while read p; do
            echo "$p"
          done <.__lona-artifact-path/variables.txt
        id: variables

      - name: Get the latest version of the repository
        uses: actions/checkout@v1

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: "12.x"

      - name: Install the Lona Compiler
        run: npm install -g @lona/compiler

      - name: Generate js sources
        run: lona convert . --format=js --output=./__lona-npm-output

      - name: Generate package.json
        run: |
          REPO_LOWERCASE=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
          echo "{
            \"name\": \"@$REPO_LOWERCASE\",
            \"version\": \"${{ steps.variables.outputs.new_version }}\",
            \"publishConfig\": { \"registry\": \"https://npm.pkg.github.com/\" },
            \"repository\": \"git://github.com/${{ github.repository }}\"
          }" >> package.json
        working-directory: ./__lona-npm-output

      - name: Publish package to GitHub Package Registry
        run: |
          echo "//npm.pkg.github.com/:_authToken=${{ secrets.GITHUB_TOKEN }}" > ~/.npmrc
          npm publish
        working-directory: ./__lona-npm-output
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  cocoapod:
    runs-on: macos-latest
    needs: [documentation]
    steps:
      - name: Get variables from documentation (1/2)
        uses: actions/download-artifact@v1
        with:
          name: lona-variables
          path: .__lona-artifact-path
      - name: Get variables from documentation (2/2)
        run: |
          while read p; do
            echo "$p"
          done <.__lona-artifact-path/variables.txt
          echo "::set-output name=repo_name::$(echo "${{ github.repository }}" | tr '/' '_')"
        id: variables

      - name: Get the latest version of the repository
        uses: actions/checkout@v1

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: "12.x"

      - name: Install XcodeGen
        run: brew install xcodegen

      - name: Install the Lona Compiler
        run: npm install -g @lona/compiler

      - name: Generate Swift sources
        run: |
          lona convert . --format=swift --output=./.lona-pod/Sources
      - name: Create Package.swift
        run: |
          echo "name: '${{ steps.variables.outputs.repo_name }}'
          ############
          # Options
          ############
          options:
            minimumXcodeGenVersion: 2.10
            groupSortPosition: top
            generateEmptyDirectories: true
            deploymentTarget:
              iOS: '11.0'
              macOS: '10.14'
          ############
          # Targets
          ############
          targets:
            '${{ steps.variables.outputs.repo_name }}':
              type: framework
              platform: [iOS, macOS]
              # scheme
              scheme:
                gatherCoverageData: true
              # sources
              sources:
                - Sources
          " >> project.yml
        working-directory: ./.lona-pod

      - name: Generate Xcode Project
        run: xcodegen
        working-directory: ./.lona-pod

      - name: Archive the framework
        run: |
          mkdir -p .__lona-build-output
          carthage build --archive --log-path ./.__lona-build-output/carthage-xcodebuild.log
        working-directory: ./.lona-pod

      - name: Upload build output if it failed
        if: failure()
        uses: actions/upload-artifact@v1
        with:
          name: lona-xcode-build-output
          path: ./.lona-pod/.__lona-build-output

      - name: Publish the framework to the GitHub release
        uses: actions/upload-release-asset@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ steps.variables.outputs.upload_url }}
          asset_path: ./.lona-pod/${{ steps.variables.outputs.repo_name }}.framework.zip
          asset_name: ${{ steps.variables.outputs.repo_name }}.framework.zip
          asset_content_type: application/zip
"""
