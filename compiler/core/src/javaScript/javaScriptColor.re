open JavaScriptAst;

let render = colors => {
  let propertyDoc = (color: Color.t) => {
    let property =
      Property({
        "key": Identifier([color.id]),
        "value": Literal(LonaValue.string(color.value))
      });
    switch color.comment {
    | Some(comment) => LineEndComment({"comment": comment, "line": property})
    | None => property
    };
  };
  let doc =
    Program([
      ExportDefaultDeclaration(ObjectLiteral(colors |> List.map(propertyDoc))),
      Empty
    ]);
  JavaScriptRender.toString(doc);
};