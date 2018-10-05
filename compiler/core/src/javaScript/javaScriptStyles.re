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

let defaultStyles =
    (
      framework: JavaScriptOptions.framework,
      config: Config.t,
      layerType: Types.layerType,
    ) => {
  let defaults = ParameterMap.empty;

  let defaults =
    switch (framework, layerType) {
    | (JavaScriptOptions.ReactDOM, Types.Text) => defaults
    | (JavaScriptOptions.ReactDOM, _) =>
      ParameterMap.(
        defaults |> add(ParameterKey.Display, LonaValue.string("flex"))
      )
    /* |> add(ParameterKey.AlignItems, LonaValue.string("flex-start")) */
    | (JavaScriptOptions.ReactNative, _)
    | (JavaScriptOptions.ReactSketchapp, _) => defaults
    /* ParameterMap.(
         defaults
         |> add(ParameterKey.AlignItems, LonaValue.string("flex-start"))
       ) */
    };

  /* Add default text style */
  let defaults =
    switch (layerType) {
    | Types.Text =>
      ParameterMap.(
        defaults
        |> add(
             ParameterKey.TextStyle,
             LonaValue.textStyle(
               config.textStylesFile.contents.defaultStyle.id,
             ),
           )
      )
    | _ => defaults
    };

  defaults;
};

let flex0Value = framework =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => LonaValue.string("0 0 auto")
  | JavaScriptOptions.ReactNative
  | JavaScriptOptions.ReactSketchapp => LonaValue.number(0.0)
  };

let flex1Value = framework =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => LonaValue.string("1 1 0%")
  | JavaScriptOptions.ReactNative
  | JavaScriptOptions.ReactSketchapp => LonaValue.number(1.0)
  };

let platformDefaultLayout = framework: Layout.t =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => {
      width: Fill,
      height: Fill,
      direction: Row,
      horizontalAlignment: Start,
      verticalAlignment: Start,
    }
  | JavaScriptOptions.ReactNative
  | JavaScriptOptions.ReactSketchapp => {
      width: Fill,
      height: Fill,
      direction: Column,
      horizontalAlignment: Start,
      verticalAlignment: Start,
    }
  };

let platformPrimaryAxis = (framework, layer: option(Types.layer)) =>
  switch (framework, layer) {
  | (_, Some(layer)) =>
    Layer.getFlexDirection(layer.parameters) |> Layout.FromString.direction
  | (JavaScriptOptions.ReactDOM, None) => Row
  | (JavaScriptOptions.ReactNative, None)
  | (JavaScriptOptions.ReactSketchapp, None) => Column
  };

/* Use framework to determine correct layout parameters */
let getLayoutParameters =
    (
      framework: JavaScriptOptions.framework,
      parent: option(Types.layer),
      layer: Types.layer,
    )
    : Types.layerParameters => {
  let layout = Layer.getLayout(parent, layer.parameters);

  /* The primary axis is determined by the parent's direction, or the platform
     if we're at the top level and there is no parent */
  let primaryAxis = platformPrimaryAxis(framework, parent);

  let parameters = ParameterMap.empty;

  if (Layer.isComponentLayer(layer)) {
    let parentU: Types.layer = parent |> Js.Option.getExn;
    let parentLayout = Layer.getLayout(None, parentU.parameters);

    let parameters =
      ParameterMap.(
        LonaValue.(
          /* TODO: ReactDOM: Boundary components within a `row` parent may need more layout
             styles to stretch/fit properly on the vertical axis */
          switch (framework) {
          | JavaScriptOptions.ReactDOM =>
            let parameters = parameters |> add(FlexDirection, string("row"));

            let alignSelf =
              switch (
                parentLayout.direction,
                Layer.getStringParameterOpt(AlignItems, parentU.parameters),
                Layer.getStringParameterOpt(
                  JustifyContent,
                  parentU.parameters,
                ),
              ) {
              | (Column, Some(alignItems), _) => alignItems
              | _ => "stretch"
              };

            parameters |> add(AlignSelf, string(alignSelf));
          /* TODO: ReactNative */
          | JavaScriptOptions.ReactNative
          | JavaScriptOptions.ReactSketchapp =>
            parameters
            |> add(FlexDirection, string("column"))
            |> add(AlignItems, string("stretch"))
          }
        )
      );

    parameters;
  } else {
    /* Horizontal axis */
    let parameters =
      ParameterMap.(
        switch (primaryAxis, layout.width) {
        | (Row, Fill) => parameters |> add(Flex, flex1Value(framework))
        | (Row, FitContent) =>
          parameters |> add(Flex, flex0Value(framework))
        | (Column, Fill) =>
          parameters |> add(AlignSelf, LonaValue.string("stretch"))
        | (Column, FitContent) => parameters
        | (_, Fixed(value)) =>
          parameters |> add(Width, LonaValue.number(value))
        }
      );

    /* Vertical axis */
    let parameters =
      ParameterMap.(
        LonaValue.(
          switch (primaryAxis, layout.height) {
          | (Column, Fill) => parameters |> add(Flex, flex1Value(framework))
          | (Column, FitContent) =>
            parameters |> add(Flex, flex0Value(framework))
          | (Row, Fill) => parameters |> add(AlignSelf, string("stretch"))
          | (Row, FitContent) => parameters
          | (_, Fixed(value)) => parameters |> add(Height, number(value))
          }
        )
      );

    /* Flex direction axis */
    let parameters =
      ParameterMap.(
        LonaValue.(
          switch (layout.direction) {
          | Column => parameters |> add(FlexDirection, string("column"))
          | Row => parameters |> add(FlexDirection, string("row"))
          }
        )
      );

    let (horizontalAlignmentKey, verticalAlignmentKey) =
      ParameterKey.(
        switch (layout.direction) {
        | Row => (JustifyContent, AlignItems)
        | Column => (AlignItems, JustifyContent)
        }
      );

    /* Children alignment */
    let parameters =
      ParameterMap.(
        LonaValue.(
          parameters
          |> add(
               horizontalAlignmentKey,
               string(
                 layout.horizontalAlignment
                 |> Layout.ToString.childrenAlignment,
               ),
             )
          |> add(
               verticalAlignmentKey,
               string(
                 layout.verticalAlignment |> Layout.ToString.childrenAlignment,
               ),
             )
        )
      );

    parameters;
  };
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
      config: Config.t,
      framework: JavaScriptOptions.framework,
      colors,
      parent: option(Types.layer),
      layer: Types.layer,
    ) => {
  let layoutParameters = getLayoutParameters(framework, parent, layer);

  /* We replace all of these keys with the appropriate dfeaults for the framework */
  let replacedKeys = [
    ParameterKey.AlignItems,
    ParameterKey.AlignSelf,
    ParameterKey.Display,
    ParameterKey.Flex,
    ParameterKey.FlexDirection,
    ParameterKey.JustifyContent,
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
          |> ParameterMap.assign(
               defaultStyles(framework, config, layer.typeName),
             )
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
      config: Config.t,
      framework: JavaScriptOptions.framework,
      colors,
      layer: Types.layer,
    ) => {
  let styleObjects =
    layer
    |> Layer.flatmapParent(
         createStyleObjectForLayer(config, framework, colors),
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