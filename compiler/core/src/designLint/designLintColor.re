open JavaScriptAst;

let convertToAst = colors => {
  let grabHex = (color: Color.t) =>
    Property({
      "key": Identifier([color.name]),
      "value": Literal(LonaValue.string(color.value)),
    });

  ArrayLiteral([
    StringLiteral("Error"),
    ObjectLiteral(colors |> List.map(grabHex)),
  ]);
};

let render = colors => colors |> convertToAst |> JavaScriptRender.toString;
