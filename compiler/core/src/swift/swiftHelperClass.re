/* private class ImageWithBackgroundColor: NSImageView {
     var fillColor: NSColor = NSColor.clear

     override func draw(_ dirtyRect: NSRect) {
         fillColor.set()
         bounds.fill()
         super.draw(dirtyRect)
     }
   } */
let generateImageWithBackgroundColor =
    (options: Options.options, swiftOptions: SwiftOptions.options) =>
  SwiftAst.[
    ClassDeclaration({
      "name": "ImageWithBackgroundColor",
      "inherits": [TypeName("NSImageView")],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body": [
        VariableDeclaration({
          "modifiers": [],
          "pattern":
            IdentifierPattern({
              "identifier": SwiftIdentifier("fillColor"),
              "annotation": None,
            }),
          "init":
            Some(
              MemberExpression([
                SwiftIdentifier(
                  SwiftDocument.colorTypeName(swiftOptions.framework),
                ),
                SwiftIdentifier("clear"),
              ]),
            ),
          "block": None,
        }),
        Empty,
        FunctionDeclaration({
          "name": "draw",
          "modifiers": [OverrideModifier],
          "parameters": [
            Parameter({
              "annotation": TypeName("NSRect"),
              "externalName": Some("_"),
              "localName": "dirtyRect",
              "defaultValue": None,
            }),
          ],
          "body": [
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("fillColor"),
                  SwiftIdentifier("set"),
                ]),
              "arguments": [],
            }),
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("bounds"),
                  SwiftIdentifier("fill"),
                ]),
              "arguments": [],
            }),
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("super"),
                  SwiftIdentifier("draw"),
                ]),
              "arguments": [
                FunctionCallArgument({
                  "name": None,
                  "value": SwiftIdentifier("dirtyRect"),
                }),
              ],
            }),
          ],
          "result": None,
          "throws": false,
        }),
      ],
    }),
    Empty,
  ];

let generateVectorGraphic =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      assetUrl: string,
    ) => {
  let svg = Config.Find.svg(config, assetUrl);

  SwiftAst.[
    ClassDeclaration({
      "name": SwiftFormat.vectorClassName(assetUrl),
      "inherits": [
        TypeName(swiftOptions.framework == UIKit ? "UIView" : "NSView"),
      ],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body":
        [
          swiftOptions.framework == SwiftOptions.AppKit ?
            [
              VariableDeclaration({
                "modifiers": [OverrideModifier],
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("isFlipped"),
                    "annotation": Some(TypeName("Bool")),
                  }),
                "init": None,
                "block":
                  Some(
                    GetterBlock([
                      ReturnStatement(
                        Some(LiteralExpression(Boolean(true))),
                      ),
                    ]),
                  ),
              }),
            ] :
            [],
          [
            FunctionDeclaration({
              "name": "draw",
              "modifiers": [OverrideModifier],
              "parameters": [
                Parameter({
                  "annotation": TypeName("CGRect"),
                  "externalName": Some("_"),
                  "localName": "dirtyRect",
                  "defaultValue": None,
                }),
              ],
              "body":
                [SwiftSvg.convertNode(swiftOptions, svg)] |> List.concat,
              "result": None,
              "throws": false,
            }),
          ],
        ]
        |> SwiftDocument.joinGroups(Empty),
    }),
    Empty,
  ];
};