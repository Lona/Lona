open JavaScriptAst;

let render = colors => {
  let propertyDoc = (color: Color.t) => {
    let property =
      Property({
        key: Identifier([color.id]),
        value: Some(Literal(LonaValue.string(color.value))),
      });
    switch (color.comment) {
    | None
    | Some("") => property
    | Some(comment) => LineEndComment({comment, line: property})
    };
  };
  let doc =
    Program([
      ExportDefaultDeclaration(
        ObjectLiteral(colors |> List.map(propertyDoc)),
      ),
      Empty,
    ]);
  JavaScriptRender.toString(doc);
};