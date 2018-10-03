let getTextStyleProperty =
    (framework: JavaScriptOptions.framework, textStyleId) =>
  JavaScriptAst.(
    SpreadElement(
      switch (framework) {
      | JavaScriptOptions.ReactSketchapp =>
        CallExpression({
          callee: Identifier(["TextStyles", "get"]),
          arguments: [
            StringLiteral(textStyleId |> JavaScriptFormat.styleVariableName),
          ],
        })
      | _ =>
        Identifier([
          "textStyles",
          textStyleId |> JavaScriptFormat.styleVariableName,
        ])
      },
    )
  );

let getStyleProperty =
    (
      framework: JavaScriptOptions.framework,
      key,
      colors,
      value: Types.lonaValue,
    ) => {
  let keyIdentifier =
    JavaScriptAst.Identifier([key |> ParameterKey.toString]);
  switch (value.ltype) {
  | Named("TextStyle", _)
  | Reference("TextStyle") =>
    let data = value.data |> Js.Json.decodeString;
    switch (data) {
    | Some(textStyleId) => getTextStyleProperty(framework, textStyleId)
    | None =>
      Js.log("TextStyle id must be a string");
      raise(Not_found);
    };
  | Named("Color", _)
  | Reference("Color") =>
    let data = value.data |> Json.Decode.string;
    switch (Color.find(colors, data)) {
    | Some(color) =>
      JavaScriptAst.Property({
        key: keyIdentifier,
        value: JavaScriptAst.Identifier(["colors", color.id]),
      })
    | None =>
      JavaScriptAst.Property({key: keyIdentifier, value: Literal(value)})
    };
  | _ => JavaScriptAst.Property({key: keyIdentifier, value: Literal(value)})
  };
};

let addDefaultStyles =
    (
      framework: JavaScriptOptions.framework,
      styleParams: ParameterMap.t(Types.lonaValue),
    ) =>
  ParameterMap.assign(
    switch (framework) {
    | JavaScriptOptions.ReactDOM =>
      ParameterMap.(
        empty
        |> add(ParameterKey.Display, LonaValue.string("flex"))
        |> add(ParameterKey.FlexDirection, LonaValue.string("column"))
        |> add(ParameterKey.AlignItems, LonaValue.string("stretch"))
      )
    | _ => ParameterMap.empty
    },
    styleParams,
  );

/* let normalizeLayoutStyles =
     (
       framework: JavaScriptOptions.framework,
       styleParams: ParameterMap.t(Types.lonaValue),
     ) =>
   ParameterMap.assign(
     switch (framework) {
     | JavaScriptOptions.ReactDOM =>
       ParameterMap.(
         empty
         |> add(ParameterKey.Display, LonaValue.string("flex"))
         |> add(ParameterKey.FlexDirection, LonaValue.string("column"))
         |> add(ParameterKey.AlignItems, LonaValue.string("stretch"))
       )
     | _ => ParameterMap.empty
     },
     styleParams,
   ); */

let getStylePropertyWithUnits =
    (
      framework: JavaScriptOptions.framework,
      colors,
      key,
      value: Types.lonaValue,
    ) =>
  switch (framework, key |> ReactDomTranslators.isUnitNumberParameter) {
  | (JavaScriptOptions.ReactDOM, true) =>
    JavaScriptAst.Property({
      key: JavaScriptAst.Identifier([key |> ParameterKey.toString]),
      value:
        Literal(
          LonaValue.string(
            value.data |> ReactDomTranslators.convertUnitlessStyle,
          ),
        ),
    })
  | (_, _) => getStyleProperty(framework, key, colors, value)
  };

let createStyleObjectForLayer =
    (framework: JavaScriptOptions.framework, colors, layer: Types.layer) =>
  JavaScriptAst.(
    Property({
      key: Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      value:
        ObjectLiteral(
          layer.parameters
          |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key))
          |> addDefaultStyles(framework)
          |> ParameterMap.bindings
          |> List.map(((key, value)) =>
               getStylePropertyWithUnits(framework, colors, key, value)
             ),
        ),
    })
  );

let layerToJavaScriptStyleSheetAST =
    (framework: JavaScriptOptions.framework, colors, layer: Types.layer) => {
  let styleObjects =
    layer
    |> Layer.flatten
    |> List.map(createStyleObjectForLayer(framework, colors));
  JavaScriptAst.(
    VariableDeclaration(
      AssignmentExpression({
        left: Identifier(["styles"]),
        right:
          switch (framework) {
          | JavaScriptOptions.ReactDOM => ObjectLiteral(styleObjects)
          | _ =>
            CallExpression({
              callee: Identifier(["StyleSheet", "create"]),
              arguments: [ObjectLiteral(styleObjects)],
            })
          },
      }),
    )
  );
};

module StyleSet = {
  let layerStyleBindings = (styles: Styles.viewLayerStyles('a)) => [
    ("backgroundColor", styles.backgroundColor),
    ("borderColor", styles.border.borderColor),
    ("borderWidth", styles.border.borderWidth),
    ("borderRadius", styles.border.borderRadius),
    ("textAlign", styles.textStyles.textAlign),
    ("textStyles", styles.textStyles.textStyle),
    ("marginTop", styles.layout.margin.top),
    ("marginRight", styles.layout.margin.right),
    ("marginBottom", styles.layout.margin.bottom),
    ("marginLeft", styles.layout.margin.left),
    ("paddingTop", styles.layout.padding.top),
    ("paddingRight", styles.layout.padding.right),
    ("paddingBottom", styles.layout.padding.bottom),
    ("paddingLeft", styles.layout.padding.left),
    ("alignItems", styles.layout.flex.alignItems),
    ("alignSelf", styles.layout.flex.alignSelf),
    ("display", styles.layout.flex.display),
    ("flex", styles.layout.flex.flex),
    ("flexDirection", styles.layout.flex.flexDirection),
    ("height", styles.layout.flex.height),
    ("width", styles.layout.flex.width),
    ("justifyContent", styles.layout.flex.justifyContent),
  ];

  let createViewLayerStylesAST =
      (
        framework,
        colors,
        styleSet: Styles.viewLayerStyles(option(Types.lonaValue)),
      ) =>
    styleSet
    |> layerStyleBindings
    |> List.map(((key, value)) =>
         switch (value) {
         | Some(lvalue) => [
             getStylePropertyWithUnits(
               framework,
               colors,
               ParameterKey.fromString(key),
               lvalue,
             ),
           ]
         | None => []
         }
       )
    |> List.concat;

  let createNameStyleSetAST = (setName: string, contents) =>
    JavaScriptAst.(
      Property({
        key: StringLiteral(setName),
        value: ObjectLiteral(contents),
      })
    );

  let createLayerObjectAST = (layerName: string, contents) =>
    JavaScriptAst.(
      Property({
        key: StringLiteral(layerName |> JavaScriptFormat.styleVariableName),
        value: ObjectLiteral(contents),
      })
    );

  let createThemeObjectAST = contents =>
    JavaScriptAst.(
      VariableDeclaration(
        AssignmentExpression({
          left: Identifier(["theme"]),
          right: ObjectLiteral(contents),
        }),
      )
    );

  let layerToThemeAST = (framework, colors, layer: Types.layer) => {
    let layerObjectsAst =
      layer
      |> Layer.flatten
      |> List.map((layer: Types.layer) =>
           createLayerObjectAST(
             layer.name,
             layer.styles
             |> List.map(
                  (styleSet: Styles.namedStyles(option(Types.lonaValue))) =>
                  createNameStyleSetAST(
                    styleSet.name,
                    createViewLayerStylesAST(
                      framework,
                      colors,
                      styleSet.styles,
                    ),
                  )
                ),
           )
         );

    createThemeObjectAST(layerObjectsAst);
  };
};