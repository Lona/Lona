open JavaScriptAst;

let renderReactDom = (colors: list(Color.t), shadowsFile: Shadow.file) => {
  let shadowObject = (shadow: Shadow.t) => {
    let dropShadowString =
      "drop-shadow("
      ++ string_of_int(int_of_float(shadow.x))
      ++ "px "
      ++ string_of_int(int_of_float(shadow.y))
      ++ "px "
      ++ string_of_int(int_of_float(shadow.blur))
      ++ "px ";

    let filterValue =
      switch (Color.find(colors, shadow.color)) {
      | Some(color) =>
        BinaryExpression({
          left:
            BinaryExpression({
              left: Literal(LonaValue.string(dropShadowString)),
              operator: Plus,
              right: Identifier(["colors", color.id]),
            }),
          operator: Plus,
          right: Literal(LonaValue.string(")")),
        })
      | None =>
        Literal(LonaValue.string(dropShadowString ++ shadow.color ++ ")"))
      };

    Property({
      key: Identifier([shadow.id |> JavaScriptFormat.styleVariableName]),
      value:
        Some(
          ObjectLiteral([
            JavaScriptAst.Property({
              key: Identifier(["filter"]),
              value: Some(filterValue),
            }),
          ]),
        ),
    });
  };

  JavaScriptRender.toString(
    Program([
      ImportDeclaration({
        source: "./colors",
        specifiers: [ImportDefaultSpecifier("colors")],
      }),
      Empty,
      ExportDefaultDeclaration(
        ObjectLiteral(shadowsFile.styles |> List.map(shadowObject)),
      ),
      Empty,
    ]),
  );
};

let render =
    (
      javascriptOptions: JavaScriptOptions.options,
      colors: list(Color.t),
      shadowsFile: Shadow.file,
    ) =>
  switch (javascriptOptions.framework) {
  | JavaScriptOptions.ReactDOM => renderReactDom(colors, shadowsFile)
  | _ => ""
  };