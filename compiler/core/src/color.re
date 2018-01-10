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

let find = (colors: list(t), id: string) =>
  switch (colors |> List.find((color) => color.id == id)) {
  | color => Some(color)
  | exception Not_found => None
  };

let render = (target, colors) =>
  switch target {
  | Types.Swift =>
    open Ast.Swift;
    let colorConstantDoc = (color) =>
      LineEndComment({
        "comment": color.value,
        "line":
          ConstantDeclaration({
            "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
            "pattern": IdentifierPattern({"identifier": color.id, "annotation": None}),
            "init": Some(LiteralExpression(Color(color.value)))
          })
      });
    let doc =
      TopLevelDeclaration({
        "statements": [
          ImportDeclaration("UIKit"),
          Empty,
          ClassDeclaration({
            "name": "Colors",
            "inherits": [],
            "modifier": None,
            "isFinal": false,
            "body": colors |> List.map(colorConstantDoc)
          })
        ]
      });
    Render.Swift.toString(doc)
  | _ =>
    Js.log2("Color generation not supported for target", target);
    "error"
  };