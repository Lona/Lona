open SwiftAst;

let render = (colors) => {
  let colorConstantDoc = (color: Color.t) =>
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
  SwiftRender.toString(doc)
};