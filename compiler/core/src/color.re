type t = {
  id: string,
  name: string,
  value: string
};

let parseFile = (filename) => {
  let content = Node.Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseColor = (json) => {
    id: field("id", string, json),
    name: field("name", string, json),
    value: field("value", string, json)
  };
  field("colors", list(parseColor), parsed)
};

let render = (target, colors) =>
  switch target {
  | Types.Swift =>
    open Ast.Swift;
    let colorLiteralDoc = (value) => {
      let rgba = Css.parseColorDefault("black", value);
      FunctionCallExpression({
        "name": SwiftIdentifier("#colorLiteral"),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("red")),
            "value": LiteralExpression(FloatingPoint(rgba.r /. 255.0))
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("green")),
            "value": LiteralExpression(FloatingPoint(rgba.g /. 255.0))
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("blue")),
            "value": LiteralExpression(FloatingPoint(rgba.b /. 255.0))
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("alpha")),
            "value": LiteralExpression(FloatingPoint(rgba.a))
          })
        ]
      })
    };
    let colorConstantDoc = (color) =>
      ConstantDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
        "pattern": IdentifierPattern(color.id),
        "init":
          Some(
            FunctionCallExpression({
              "name": SwiftIdentifier("color"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("hex")),
                  "value": LiteralExpression(String(color.value))
                }),
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("preview")),
                  "value": colorLiteralDoc(color.value)
                })
              ]
            })
          )
      });
    let doc =
      TopLevelDeclaration({
        "statements": [
          ImportDeclaration("UIKit"),
          ClassDeclaration({"name": "Colors", "body": colors |> List.map(colorConstantDoc)})
        ]
      });
    Render.Swift.toString(doc)
  | _ =>
    Js.log2("Color generation not supported for target", target);
    "error"
  };