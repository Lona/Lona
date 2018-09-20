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
