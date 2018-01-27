open SwiftAst;

let render = colors => {
  let colorConstantDoc = (color: Color.t) =>
    LineEndComment({
      "comment":
        (color.value |> String.uppercase)
        ++ (
          switch color.comment {
          | Some(comment) => " - " ++ comment
          | _ => ""
          }
        ),
      "line":
        ConstantDeclaration({
          "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
          "pattern":
            IdentifierPattern({"identifier": color.id, "annotation": None}),
          "init": Some(LiteralExpression(Color(color.value)))
        })
    });
  let doc =
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        Empty,
        EnumDeclaration({
          "name": "Colors",
          "modifier": Some(PublicModifier),
          "body": colors |> List.map(colorConstantDoc)
        })
      ]
    });
  SwiftRender.toString(doc);
};