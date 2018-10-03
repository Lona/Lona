module Doc = {
  open SwiftAst;

  /* extension NSShadow {
       convenience init(color: NSColor, offset: NSSize, blur: CGFloat) {
         self.init()

         shadowColor = color
         shadowOffset = offset
         shadowBlurRadius = blur
       }
     } */
  let convenienceInit = (swiftOptions: SwiftOptions.options) =>
    InitializerDeclaration({
      "modifiers": [ConvenienceModifier],
      "parameters": [
        Parameter({
          "externalName": None,
          "localName": "color",
          "annotation":
            TypeName(SwiftDocument.colorTypeName(swiftOptions.framework)),
          "defaultValue": None,
        }),
        Parameter({
          "externalName": None,
          "localName": "offset",
          "annotation":
            TypeName(SwiftDocument.sizeTypeName(swiftOptions.framework)),
          "defaultValue": None,
        }),
        Parameter({
          "externalName": None,
          "localName": "blur",
          "annotation": TypeName("CGFloat"),
          "defaultValue": None,
        }),
      ],
      "failable": None,
      "throws": false,
      "body": [
        Builders.functionCall(["self", "init"], []),
        Empty,
        BinaryExpression({
          "left": SwiftIdentifier("shadowColor"),
          "operator": "=",
          "right": SwiftIdentifier("color"),
        }),
        BinaryExpression({
          "left": SwiftIdentifier("shadowOffset"),
          "operator": "=",
          "right": SwiftIdentifier("offset"),
        }),
        BinaryExpression({
          "left": SwiftIdentifier("shadowBlurRadius"),
          "operator": "=",
          "right": SwiftIdentifier("blur"),
        }),
      ],
    });

  let shadow =
      (
        swiftOptions: SwiftOptions.options,
        colors: list(Color.t),
        shadow: Shadow.t,
      )
      : node => {
    let color =
      switch (Color.find(colors, shadow.color)) {
      | Some(color) =>
        MemberExpression([
          SwiftIdentifier("Colors"),
          SwiftIdentifier(color.id),
        ])
      | None => LiteralExpression(Color(shadow.color))
      };

    /* The coordinate system is flipped vertically on macOS */
    let direction =
      switch (swiftOptions.framework) {
      | SwiftOptions.AppKit => (-1.0)
      | UIKit => 1.0
      };

    let size =
      FunctionCallExpression({
        "name":
          SwiftIdentifier(
            SwiftDocument.sizeTypeName(swiftOptions.framework),
          ),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("width")),
            "value": LiteralExpression(FloatingPoint(shadow.x)),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("height")),
            "value": LiteralExpression(FloatingPoint(direction *. shadow.y)),
          }),
        ],
      });

    FunctionCallExpression({
      "name":
        SwiftIdentifier(
          SwiftDocument.shadowTypeName(swiftOptions.framework),
        ),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("color")),
          "value": color,
        }),
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("offset")),
          "value": size,
        }),
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("blur")),
          "value": LiteralExpression(FloatingPoint(shadow.blur)),
        }),
      ],
    });
  };

  let shadowConstant =
      (
        swiftOptions: SwiftOptions.options,
        colors: list(Color.t),
        s: Shadow.t,
      )
      : node =>
    ConstantDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(s.id),
          "annotation": None,
        }),
      "init": Some(shadow(swiftOptions, colors, s)),
    });
};

let render =
    (
      swiftOptions: SwiftOptions.options,
      colors: list(Color.t),
      shadowsFile: Shadow.file,
    ) =>
  SwiftAst.(
    TopLevelDeclaration({
      "statements":
        SwiftDocument.join(
          Empty,
          [
            SwiftDocument.importFramework(swiftOptions.framework),
            EnumDeclaration({
              "name": "Shadows",
              "isIndirect": false,
              "inherits": [],
              "modifier": Some(PublicModifier),
              "body":
                shadowsFile.styles
                |> List.map(Doc.shadowConstant(swiftOptions, colors)),
            }),
          ]
          @ (
            switch (swiftOptions.framework) {
            | SwiftOptions.AppKit => [
                ExtensionDeclaration({
                  "name": "NSShadow",
                  "protocols": [],
                  "where": None,
                  "modifier": Some(PrivateModifier),
                  "body": [Doc.convenienceInit(swiftOptions)],
                }),
              ]
            | UIKit => []
            }
          ),
        ),
    })
    |> SwiftRender.toString
  );