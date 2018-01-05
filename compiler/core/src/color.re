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
    let colorLiteralDoc = (value) => LiteralExpression(Color(value));
    let colorConstantDoc = (color) =>
      LineComment({
        "comment": color.value,
        "line":
          ConstantDeclaration({
            "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
            "pattern": IdentifierPattern(color.id),
            "init": Some(colorLiteralDoc(color.value))
          })
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