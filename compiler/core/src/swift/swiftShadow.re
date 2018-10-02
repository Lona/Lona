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
  let convenienceInit = () =>
    InitializerDeclaration({
      "modifiers": [
        AccessLevelModifier(PrivateModifier),
        ConvenienceModifier,
      ],
      "parameters": [
        Parameter({
          "externalName": None,
          "localName": "color",
          "annotation": TypeName("NSColor"),
          "defaultValue": None,
        }),
        Parameter({
          "externalName": None,
          "localName": "offset",
          "annotation": TypeName("NSSize"),
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

  let shadow = (colors: list(Color.t), shadow: Shadow.t): node => {
    let color =
      switch (Color.find(colors, shadow.color)) {
      | Some(color) =>
        MemberExpression([
          SwiftIdentifier("Colors"),
          SwiftIdentifier(color.id),
        ])
      | None => LiteralExpression(Color(shadow.color))
      };

    let size =
      FunctionCallExpression({
        "name": SwiftIdentifier("NSSize"),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("width")),
            "value": LiteralExpression(FloatingPoint(shadow.x)),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("height")),
            "value": LiteralExpression(FloatingPoint(shadow.y)),
          }),
        ],
      });

    FunctionCallExpression({
      "name": SwiftIdentifier("NSShadow"),
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
};

let render =
    (
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      colors: list(Color.t),
      shadowsFile: Shadow.file,
    ) =>
  SwiftAst.(
    TopLevelDeclaration({
      "statements": [
        SwiftDocument.importFramework(swiftOptions.framework),
        Empty,
        EnumDeclaration({
          "name": "Shadows",
          "isIndirect": false,
          "inherits": [],
          "modifier": Some(PublicModifier),
          "body": shadowsFile.styles |> List.map(Doc.shadow(colors)),
        }),
        Empty,
        Doc.convenienceInit(),
      ],
    })
    |> SwiftRender.toString
  );