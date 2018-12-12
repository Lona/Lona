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
  let convenienceInit = (config: Config.t) =>
    InitializerDeclaration({
      "modifiers": [ConvenienceModifier],
      "parameters": [
        Parameter({
          "externalName": None,
          "localName": "color",
          "annotation": TypeName(SwiftDocument.colorTypeName(config)),
          "defaultValue": None,
        }),
        Parameter({
          "externalName": None,
          "localName": "offset",
          "annotation": TypeName(SwiftDocument.sizeTypeName(config)),
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
      (config: Config.t, colors: list(Color.t), shadow: Shadow.t): node => {
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
      switch (config.options.swift.framework) {
      | SwiftOptions.AppKit => (-1.0)
      | UIKit => 1.0
      };

    let size =
      FunctionCallExpression({
        "name": SwiftIdentifier(SwiftDocument.sizeTypeName(config)),
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
      "name": SwiftIdentifier(SwiftDocument.shadowTypeName(config)),
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
      (config: Config.t, colors: list(Color.t), s: Shadow.t): node =>
    ConstantDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(s.id),
          "annotation": None,
        }),
      "init": Some(shadow(config, colors, s)),
    });
};

let render = (config: Config.t) =>
  SwiftAst.(
    TopLevelDeclaration({
      "statements":
        SwiftDocument.join(
          Empty,
          [
            SwiftDocument.importFramework(config),
            EnumDeclaration({
              "name": "Shadows",
              "isIndirect": false,
              "inherits": [],
              "modifier": Some(PublicModifier),
              "body":
                config.shadowsFile.contents.styles
                |> List.map(
                     Doc.shadowConstant(config, config.colorsFile.contents),
                   ),
            }),
          ]
          @ (
            switch (config.options.swift.framework) {
            | SwiftOptions.AppKit => [
                ExtensionDeclaration({
                  "name": "NSShadow",
                  "protocols": [],
                  "where": None,
                  "modifier": None,
                  "body": [Doc.convenienceInit(config)],
                }),
              ]
            | UIKit => []
            }
          ),
        ),
    })
    |> SwiftRender.toString
  );