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

let render = (colors, textStyles) => {
  let unwrapOptional = (f, a) => switch (a) {
  | Some(value) => [f(value)]
  | None => []
  };
  let convertFontWeight = fun
  | "100" => "ultraLight"
  | "200" => "thin"
  | "300" => "light"
  | "400" => "regular"
  | "500" => "medium"
  | "600" => "semibold"
  | "700" => "bold"
  | "800" => "heavy"
  | "900" => "black"
  | _ => "regular"
  ;
  let argumentsDoc = (textStyle: TextStyle.t) =>
    [
      textStyle.fontFamily |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("family")),
          "value": LiteralExpression(String(value))
        })
      }),
      textStyle.fontName |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("name")),
          "value": LiteralExpression(String(value))
        })
      }),
      textStyle.fontWeight |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("weight")),
          "value": MemberExpression([
            SwiftIdentifier("UIFont"),
            SwiftIdentifier("Weight"),
            SwiftIdentifier(convertFontWeight(value))
          ])
        })
      }),
      textStyle.fontSize |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("size")),
          "value": LiteralExpression(FloatingPoint(value))
        })
      }),
      textStyle.lineHeight |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("lineHeight")),
          "value": LiteralExpression(FloatingPoint(value))
        })
      }),
      textStyle.letterSpacing |> unwrapOptional((value) => {
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("kerning")),
          "value": LiteralExpression(FloatingPoint(value))
        })
      }),
      textStyle.color |> unwrapOptional((value) => {
        let value = switch (Color.find(colors, value)) {
          | Some(color) => MemberExpression([
            SwiftIdentifier("Colors"),
            SwiftIdentifier(color.id)
            ])
          | None => LiteralExpression(Color(value))
        };
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("color")),
          "value": value
        })
      }),
    ]
    |> List.concat;
  let textStyleConstantDoc = (textStyle: TextStyle.t) =>
    ConstantDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern": IdentifierPattern({"identifier": textStyle.id, "annotation": None}),
      "init":
        Some(
          FunctionCallExpression({
            name: SwiftIdentifier("AttributedFont"),
            arguments: argumentsDoc(textStyle)
          })
        )
    });
  let doc =
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        Empty,
        ClassDeclaration({
          "name": "TextStyles",
          "inherits": [],
          "modifier": None,
          "isFinal": false,
          "body": textStyles |> List.map(textStyleConstantDoc)
        })
      ]
    });
  SwiftRender.toString(doc)
};