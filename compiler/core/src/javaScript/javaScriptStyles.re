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
        empty |> add(ParameterKey.Display, LonaValue.string("flex"))
      )
    | _ => ParameterMap.empty
    },
    styleParams,
  );

/* Use framework to determine correct layout parameters */
let getLayoutParameters =
    (
      getComponent: string => Js.Json.t,
      framework: JavaScriptOptions.framework,
      parent: option(Types.layer),
      layer: Types.layer,
    )
    : Types.layerParameters => {
  let layer = Layer.getProxyLayer(getComponent, layer);

  let flexDirection = Layer.getFlexDirection(layer.parameters);

  /* Top-level layers will have a different parent direction depending on the framework */
  let frameworkParentDirection =
    switch (framework, parent) {
    | (_, Some(parent)) => Layer.getFlexDirection(parent.parameters)
    | (JavaScriptOptions.ReactDOM, None) => "row"
    | (JavaScriptOptions.ReactNative, None)
    | (JavaScriptOptions.ReactSketchapp, None) => "column"
    };
  let sizingRules = Layer.getSizingRules(parent, layer);

  let parameters = ParameterMap.empty;

  /* Horizontal axis */
  let parameters =
    ParameterMap.(
      switch (framework, frameworkParentDirection, sizingRules.width) {
      | (JavaScriptOptions.ReactDOM, "row", Types.Fill) =>
        parameters |> add(ParameterKey.Flex, LonaValue.string("1 1 0%"))
      | (JavaScriptOptions.ReactDOM, "row", Types.FitContent) =>
        parameters |> add(ParameterKey.Flex, LonaValue.string("0 0 auto"))
      | (JavaScriptOptions.ReactDOM, "column", Types.Fill) =>
        parameters
        |> add(ParameterKey.AlignSelf, LonaValue.string("stretch"))
      | (JavaScriptOptions.ReactDOM, "column", Types.FitContent) =>
        parameters
        |> add(ParameterKey.AlignSelf, LonaValue.string("flex-start"))
      | (JavaScriptOptions.ReactDOM, _, Types.Fixed(value)) =>
        parameters |> add(ParameterKey.Width, LonaValue.number(value))
      | _ =>
        Js.log2("Bad parent direction (width)", frameworkParentDirection);
        parameters;
      }
    );

  /* Vertical axis */
  let parameters =
    ParameterMap.(
      switch (framework, frameworkParentDirection, sizingRules.height) {
      | (JavaScriptOptions.ReactDOM, "row", Types.Fill) =>
        parameters
        |> add(ParameterKey.AlignSelf, LonaValue.string("stretch"))
      | (JavaScriptOptions.ReactDOM, "row", Types.FitContent) =>
        parameters
        |> add(ParameterKey.AlignSelf, LonaValue.string("flex-start"))
      | (JavaScriptOptions.ReactDOM, "column", Types.Fill) =>
        parameters |> add(ParameterKey.Flex, LonaValue.string("1 1 0%"))
      | (JavaScriptOptions.ReactDOM, "column", Types.FitContent) =>
        parameters |> add(ParameterKey.Flex, LonaValue.string("0 0 auto"))
      | (JavaScriptOptions.ReactDOM, _, Types.Fixed(value)) =>
        parameters |> add(ParameterKey.Height, LonaValue.number(value))
      | _ =>
        Js.log2("Bad parent direction (width)", frameworkParentDirection);
        parameters;
      }
    );

  /* Flex direction axis */
  let parameters =
    ParameterMap.(
      switch (framework, flexDirection) {
      | (JavaScriptOptions.ReactDOM, "column") =>
        parameters
        |> add(ParameterKey.FlexDirection, LonaValue.string("column"))
      | (JavaScriptOptions.ReactNative, "row")
      | (JavaScriptOptions.ReactSketchapp, "row") =>
        parameters
        |> add(ParameterKey.FlexDirection, LonaValue.string("row"))
      | _ => parameters
      }
    );

  parameters;
};

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
    (
      getComponent: string => Js.Json.t,
      framework: JavaScriptOptions.framework,
      colors,
      parent: option(Types.layer),
      layer: Types.layer,
    ) => {
  let layoutParameters =
    getLayoutParameters(getComponent, framework, parent, layer);

  /* We replace all of these keys with the appropriate dfeaults for the framework */
  let replacedKeys = [
    ParameterKey.AlignSelf,
    ParameterKey.Display,
    ParameterKey.Flex,
    ParameterKey.FlexDirection,
  ];

  JavaScriptAst.(
    Property({
      key: Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      value:
        ObjectLiteral(
          layer.parameters
          |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key))
          /* Remove layout parameters stored in the component file */
          |> ParameterMap.filter((key, _) => !List.mem(key, replacedKeys))
          /* Add layout parameters appropriate for the framework */
          |> ParameterMap.assign(_, layoutParameters)
          |> addDefaultStyles(framework)
          |> ParameterMap.bindings
          |> List.map(((key, value)) =>
               getStylePropertyWithUnits(framework, colors, key, value)
             ),
        ),
    })
  );
};

let layerToJavaScriptStyleSheetAST =
    (
      getComponent: string => Js.Json.t,
      framework: JavaScriptOptions.framework,
      colors,
      layer: Types.layer,
    ) => {
  let styleObjects =
    layer
    |> Layer.flatmapParent(
         createStyleObjectForLayer(getComponent, framework, colors),
       );

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