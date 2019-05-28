open SwiftAst;

/* public static let ultraLight: UIFont.Weight
   public static let thin: UIFont.Weight
   public static let light: UIFont.Weight
   public static let regular: UIFont.Weight
   public static let medium: UIFont.Weight
   public static let semibold: UIFont.Weight
   public static let bold: UIFont.Weight
   public static let heavy: UIFont.Weight
   public static let black: UIFont.Weight */
let render = (config: Config.t) => {
  let unwrapOptional = (f, a) =>
    switch (a) {
    | Some(value) => [f(value)]
    | None => []
    };
  let convertFontWeight =
    fun
    | "100" => "ultraLight"
    | "200" => "thin"
    | "300" => "light"
    | "400" => "regular"
    | "500" => "medium"
    | "600" => "semibold"
    | "700" => "bold"
    | "800" => "heavy"
    | "900" => "black"
    | _ => "regular";
  let argumentsDoc = (textStyle: TextStyle.t) =>
    {
      let lookup = f =>
        TextStyle.lookup(config.textStylesFile.contents.styles, textStyle, f);
      [
        lookup(style => style.fontFamily)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("family")),
               "value": LiteralExpression(String(value)),
             })
           ),
        lookup(style => style.fontName)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("name")),
               "value": LiteralExpression(String(value)),
             })
           ),
        lookup(style => style.fontWeight)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("weight")),
               "value":
                 MemberExpression([
                   SwiftIdentifier(SwiftDocument.fontTypeName(config)),
                   SwiftIdentifier("Weight"),
                   SwiftIdentifier(convertFontWeight(value)),
                 ]),
             })
           ),
        lookup(style => style.fontSize)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("size")),
               "value": LiteralExpression(FloatingPoint(value)),
             })
           ),
        lookup(style => style.lineHeight)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("lineHeight")),
               "value": LiteralExpression(FloatingPoint(value)),
             })
           ),
        lookup(style => style.letterSpacing)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("kerning")),
               "value": LiteralExpression(FloatingPoint(value)),
             })
           ),
        lookup(style => style.textTransform)
        |> unwrapOptional(value =>
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("textTransform")),
               "value": LiteralExpression(String(value)),
             })
           ),
        lookup(style => style.color)
        |> unwrapOptional(value => {
             let value =
               switch (Color.find(config.colorsFile.contents, value)) {
               | Some(color) =>
                 MemberExpression([
                   SwiftIdentifier("Colors"),
                   SwiftIdentifier(color.id),
                 ])
               | None => LiteralExpression(Color(value))
               };
             FunctionCallArgument({
               "name": Some(SwiftIdentifier("color")),
               "value": value,
             });
           }),
      ];
    }
    |> List.concat;
  let textStyleConstantDoc = (textStyle: TextStyle.t) =>
    ConstantDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(textStyle.id),
          "annotation": None,
        }),
      "init":
        Some(
          FunctionCallExpression({
            name: SwiftIdentifier("TextStyle"),
            arguments: argumentsDoc(textStyle),
          }),
        ),
    });
  /* Print a generic default style if none is defined in `textStyles.json` */
  let defaultStyleDoc = (textStyle: TextStyle.t) =>
    switch (
      TextStyle.find(config.textStylesFile.contents.styles, textStyle.id)
    ) {
    | None => [textStyleConstantDoc(textStyle)]
    | Some(_) => []
    };
  let doc =
    TopLevelDeclaration({
      "statements": [
        SwiftDocument.importFramework(config),
        Empty,
        ClassDeclaration({
          "name": "TextStyles",
          "inherits": [],
          "modifier": None,
          "isFinal": false,
          "body":
            (
              config.textStylesFile.contents.styles
              |> List.map(textStyleConstantDoc)
            )
            @ (config.textStylesFile.contents.defaultStyle |> defaultStyleDoc),
        }),
      ],
    });
  SwiftRender.toString(doc);
};