open JavaScriptAst;

let dropShadow = (colors: list(Color.t), shadow: Shadow.t) => {
  let dropShadowString =
    "drop-shadow("
    ++ string_of_int(int_of_float(shadow.x))
    ++ "px "
    ++ string_of_int(int_of_float(shadow.y))
    ++ "px "
    ++ string_of_int(int_of_float(shadow.blur))
    ++ "px ";

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
};

let shadowObjectReactDOM = (colors: list(Color.t), shadow: Shadow.t) =>
  Property({
    key: Identifier([shadow.id |> JavaScriptFormat.styleVariableName]),
    value:
      Some(
        ObjectLiteral([
          Property({
            key: Identifier(["filter"]),
            value: Some(dropShadow(colors, shadow)),
          }),
        ]),
      ),
  });

let shadowObjectReactNative = (colors: list(Color.t), shadow: Shadow.t) =>
  Property({
    key: Identifier([shadow.id |> JavaScriptFormat.styleVariableName]),
    value:
      Some(
        ObjectLiteral([
          Property({
            key: Identifier(["shadowOffset"]),
            value:
              Some(
                ObjectLiteral([
                  Property({
                    key: Identifier(["width"]),
                    value: Some(Literal(LonaValue.number(shadow.x))),
                  }),
                  Property({
                    key: Identifier(["height"]),
                    value: Some(Literal(LonaValue.number(shadow.y))),
                  }),
                ]),
              ),
          }),
          Property({
            key: Identifier(["shadowRadius"]),
            value: Some(Literal(LonaValue.number(shadow.blur))),
          }),
          Property({
            key: Identifier(["shadowColor"]),
            value:
              Some(
                switch (Color.find(colors, shadow.color)) {
                | Some(color) => Identifier(["colors", color.id])
                | None => Literal(LonaValue.string(shadow.color))
                },
              ),
          }),
        ]),
      ),
  });

let render =
    (
      javascriptOptions: JavaScriptOptions.options,
      colors: list(Color.t),
      shadowsFile: Shadow.file,
    ) => {
  let shadowObject =
    switch (javascriptOptions.framework) {
    | JavaScriptOptions.ReactDOM => shadowObjectReactDOM
    | JavaScriptOptions.ReactNative
    | JavaScriptOptions.ReactSketchapp => shadowObjectReactNative
    };

  JavaScriptRender.toString(
    Program([
      ImportDeclaration({
        source: "./colors",
        specifiers: [ImportDefaultSpecifier("colors")],
      }),
      Empty,
      ExportDefaultDeclaration(
        ObjectLiteral(shadowsFile.styles |> List.map(shadowObject(colors))),
      ),
      Empty,
    ]),
  );
};