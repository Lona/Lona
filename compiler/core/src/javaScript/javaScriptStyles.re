module Property = {
  let keyName = (framework: JavaScriptOptions.framework, key: ParameterKey.t) =>
    switch (framework, key) {
    | (_, ParameterKey.TextStyle) => "font"
    | (ReactDOM, ParameterKey.ResizeMode) => "objectFit"
    | _ => key |> ParameterKey.toString
    };

  let textStyle = (framework: JavaScriptOptions.framework, textStyleId) =>
    JavaScriptAst.(
      SpreadElement(
        switch (framework) {
        | JavaScriptOptions.ReactSketchapp =>
          CallExpression({
            callee: Identifier(["TextStyles", "get"]),
            arguments: [
              StringLiteral(
                textStyleId |> JavaScriptFormat.styleVariableName,
              ),
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

  let shadow = (framework: JavaScriptOptions.framework, shadowId) =>
    JavaScriptAst.(
      SpreadElement(
        switch (framework) {
        | JavaScriptOptions.ReactSketchapp =>
          CallExpression({
            callee: Identifier(["Shadows", "get"]),
            arguments: [
              StringLiteral(shadowId |> JavaScriptFormat.styleVariableName),
            ],
          })
        | _ =>
          Identifier([
            "shadows",
            shadowId |> JavaScriptFormat.styleVariableName,
          ])
        },
      )
    );

  let forValue =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        key,
        value: Types.lonaValue,
      ) => {
    let keyIdentifier =
      JavaScriptAst.Identifier([
        switch (framework) {
        | ReactDOM => key |> ReactDomTranslators.styleVariableNames
        | ReactNative
        | ReactSketchapp => key |> ParameterKey.toString
        },
      ]);
    switch (value.ltype) {
    | Named("TextStyle", _)
    | Reference("TextStyle") =>
      let data = value.data |> Js.Json.decodeString;
      switch (data) {
      | Some(textStyleId) => textStyle(framework, textStyleId)
      | None =>
        Js.log("TextStyle id must be a string");
        raise(Not_found);
      };
    | Named("Shadow", _)
    | Reference("Shadow") =>
      let data = value.data |> Js.Json.decodeString;
      switch (data) {
      | Some(shadowId) => shadow(framework, shadowId)
      | None =>
        Js.log("Shadow id must be a string");
        raise(Not_found);
      };
    | Named("Color", _)
    | Reference("Color") =>
      let data = value.data |> Json.Decode.string;
      switch (Color.find(config.colorsFile.contents, data)) {
      | Some(color) =>
        JavaScriptAst.Property({
          key: keyIdentifier,
          value: Some(JavaScriptAst.Identifier(["colors", color.id])),
        })
      | None =>
        JavaScriptAst.Property({
          key: keyIdentifier,
          value: Some(Literal(value)),
        })
      };
    | _ =>
      let value =
        switch (framework, key) {
        | (ReactDOM, ParameterKey.ResizeMode) =>
          LonaValue.string(
            ReactDomTranslators.resizeMode(value.data |> Json.Decode.string),
          )
        | _ => value
        };
      JavaScriptAst.Property({
        key: keyIdentifier,
        value: Some(Literal(value)),
      });
    };
  };
};

let focusStyles =
    (config: Config.t, layer: Types.layer): option(JavaScriptAst.node) => {
  let canBeFocused = JavaScriptLayer.canBeFocused(layer);

  if (canBeFocused && config.options.javaScript.framework == ReactDOM) {
    Some(
      Property({
        key: StringLiteral(":focus"),
        value:
          Some(
            ObjectLiteral([
              Property({
                key: Identifier(["outline"]),
                value: Some(Literal(LonaValue.number(0.))),
              }),
            ]),
          ),
      }),
    );
  } else {
    None;
  };
};

let defaultStyles =
    (
      framework: JavaScriptOptions.framework,
      config: Config.t,
      layerType: Types.layerType,
    )
    : ParameterMap.t(Types.lonaValue) => {
  let defaults = ParameterMap.empty;

  let defaults =
    switch (framework, layerType) {
    | (JavaScriptOptions.ReactDOM, Types.Text) =>
      ParameterMap.(
        defaults
        |> add(ParameterKey.Display, LonaValue.string("block"))
        |> add(ParameterKey.TextAlign, LonaValue.string("left"))
      )
    | (JavaScriptOptions.ReactDOM, _) =>
      ParameterMap.(
        defaults |> add(ParameterKey.Display, LonaValue.string("flex"))
      )
    | (JavaScriptOptions.ReactNative, _)
    | (JavaScriptOptions.ReactSketchapp, _) => defaults
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
    let parentUnwrapped =
      switch (parent) {
      | Some(unwrapped) => unwrapped
      | None =>
        Js.log("Nested custom components cannot currently be top level.");
        raise(Not_found);
      };
    let parentLayout = Layer.getLayout(None, parentUnwrapped.parameters);

    /* Top-level views should work equally well when rendered by the user and when
       nested within other Lona components. The user should not need to use any special
       flex styles to get the correct layout (except `display: flex` for React DOM).
       We make a wrapper view for each nested component. We assume the wrapper's child
       is a top-level view that expects its parent to have platform-default layout values.
       E.g. for React DOM, we make a `div` with `flex-direction: row`, and propagate the
       child alignment (`align-items` and `justify-content`) from the parent. The wrapper
       `div` will only be generated if its parent is a `column`, since if the parent is a
       `row`, the layout will be correct without it. */
    let parameters =
      ParameterMap.(
        LonaValue.(
          switch (framework) {
          | JavaScriptOptions.ReactDOM =>
            parameters
            |> add(FlexDirection, string("row"))
            /* Using `1 1 auto` works correctly here while `1 1 0%` doesn't.
               This can be tested using the NestedComponent example */
            |> add(Flex, string("1 1 auto"))
            |> add(AlignSelf, string("stretch"))
            |> add(
                 JustifyContent,
                 string(
                   parentLayout.horizontalAlignment
                   |> Layout.ToString.childrenAlignment,
                 ),
               )
            |> add(
                 AlignItems,
                 string(
                   parentLayout.verticalAlignment
                   |> Layout.ToString.childrenAlignment,
                 ),
               )
          | JavaScriptOptions.ReactNative
          | JavaScriptOptions.ReactSketchapp =>
            parameters
            |> add(FlexDirection, string("row"))
            |> add(Flex, number(1.0))
            |> add(AlignSelf, string("stretch"))
            |> add(
                 JustifyContent,
                 string(
                   parentLayout.horizontalAlignment
                   |> Layout.ToString.childrenAlignment,
                 ),
               )
            |> add(
                 AlignItems,
                 string(
                   parentLayout.verticalAlignment
                   |> Layout.ToString.childrenAlignment,
                 ),
               )
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

    /* Always add relative positioning to images. Sometimes images will be wrapped
       in a div and absolute-positioned within. */
    let parameters =
      ParameterMap.(
        if (framework == ReactDOM && layer.typeName == Image) {
          parameters
          |> add(Position, LonaValue.string("relative"))
          |> add(Overflow, LonaValue.string("hidden"));
        } else {
          parameters;
        }
      );

    parameters;
  };
};

let getStylePropertyWithUnits =
    (
      config: Config.t,
      framework: JavaScriptOptions.framework,
      key,
      value: Types.lonaValue,
    ) =>
  switch (framework, key |> ReactDomTranslators.isUnitNumberParameter) {
  | (JavaScriptOptions.ReactDOM, true) =>
    JavaScriptAst.Property({
      key: JavaScriptAst.Identifier([key |> ParameterKey.toString]),
      value:
        Some(
          Literal(
            LonaValue.string(
              value.data |> ReactDomTranslators.convertUnitlessStyle,
            ),
          ),
        ),
    })
  | (_, _) => Property.forValue(config, framework, key, value)
  };

let handleNumberOfLines =
    (framework: JavaScriptOptions.framework, config: Config.t, parameters) =>
  switch (
    framework,
    ParameterMap.find_opt(ParameterKey.NumberOfLines, parameters),
  ) {
  | (JavaScriptOptions.ReactDOM, Some(lineCount)) =>
    open Monad;
    let lineHeight =
      ParameterMap.find_opt(ParameterKey.TextStyle, parameters)
      >>= (
        (item: Types.lonaValue) =>
          TextStyle.find(
            config.textStylesFile.contents.styles,
            item.data |> Json.Decode.string,
          )
      )
      >>= ((textStyle: TextStyle.t) => textStyle.lineHeight);

    let parameters =
      parameters |> ParameterMap.remove(ParameterKey.NumberOfLines);

    switch (lineHeight) {
    | Some(lineHeight) =>
      parameters
      |> ParameterMap.add(ParameterKey.Overflow, LonaValue.string("hidden"))
      |> ParameterMap.add(
           ParameterKey.MaxHeight,
           LonaValue.number(Json.Decode.float(lineCount.data) *. lineHeight),
         )
    | None => parameters
    };
  | (_, _) => parameters
  };

let handleResizeMode =
    (
      _framework: JavaScriptOptions.framework,
      _config: Config.t,
      parent: option(Types.layer),
      layer: Types.layer,
      parameters,
    ) => {
  let layout = Layer.getLayout(parent, layer.parameters);

  /* Images without fixed dimensions are absolute positioned within a wrapper.
     We need to remove the resizeMode style from the wrapper. It will be added
     to the image itself elsewhere. */
  switch (layer.typeName, layout.width, layout.height) {
  | (Image, Fixed(_), Fixed(_)) =>
    switch (ParameterMap.find_opt(ParameterKey.ResizeMode, parameters)) {
    | Some(_) => parameters
    | None =>
      parameters
      |> ParameterMap.add(ParameterKey.ResizeMode, LonaValue.string("cover"))
    }
  | (Image, _, _) =>
    parameters |> ParameterMap.remove(ParameterKey.ResizeMode)
  | _ => parameters
  };
};

let createStyleAttributePropertyAST =
    (
      framework: JavaScriptOptions.framework,
      config: Config.t,
      key: ParameterKey.t,
      value: Logic.logicValue,
    ) => {
  let astValue = JavaScriptLogic.logicValueToJavaScriptAST(config, value);
  switch (key, ReactTranslators.isUnitNumberParameter(framework, key)) {
  | (ParameterKey.TextStyle, _) => JavaScriptAst.SpreadElement(astValue)
  | (ParameterKey.Shadow, _) => JavaScriptAst.SpreadElement(astValue)
  | (_, true) =>
    JavaScriptAst.Property({
      key: Identifier([key |> Property.keyName(framework)]),
      value:
        Some(ReactTranslators.convertUnitlessAstNode(framework, astValue)),
    })
  | (_, false) =>
    JavaScriptAst.Property({
      key: Identifier([key |> Property.keyName(framework)]),
      value: Some(astValue),
    })
  };
};

module Object = {
  /* We replace all of these keys with the appropriate defaults for the framework */
  let replacedLayoutKeys = [
    ParameterKey.AlignItems,
    ParameterKey.AlignSelf,
    ParameterKey.Flex,
    ParameterKey.FlexDirection,
    ParameterKey.JustifyContent,
  ];

  let forLayer =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        parent: option(Types.layer),
        layer: Types.layer,
      ) => {
    let layoutParameters = getLayoutParameters(framework, parent, layer);

    JavaScriptAst.(
      ObjectLiteral(
        (
          layer.parameters
          |> handleNumberOfLines(framework, config)
          |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key))
          /* Remove layout parameters stored in the component file */
          |> ParameterMap.filter((key, _) =>
               !List.mem(key, replacedLayoutKeys)
             )
          /* Add layout parameters appropriate for the framework */
          |> ParameterMap.assign(_, layoutParameters)
          |> ParameterMap.assign(
               defaultStyles(framework, config, layer.typeName),
             )
          |> handleResizeMode(framework, config, parent, layer)
          |> ParameterMap.bindings
          |> List.map(((key, value)) =>
               getStylePropertyWithUnits(config, framework, key, value)
             )
        )
        @ (
          switch (focusStyles(config, layer)) {
          | Some(property) => [
              SpreadElement(
                UnaryExpression({
                  prefix: true,
                  operator: "!",
                  argument:
                    BinaryExpression({
                      left: Identifier(["props", "focusRing"]),
                      operator: And,
                      right: ObjectLiteral([property]),
                    }),
                }),
              ),
            ]
          | None => []
          }
        ),
      )
    );
  };

  let commonImageParameterMap =
    ParameterMap.(
      empty
      |> add(Position, LonaValue.string("absolute"))
      |> add(Width, LonaValue.string("100%"))
      |> add(Height, LonaValue.string("100%"))
    );

  let imageResizing =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        resizeMode: string,
      ) =>
    JavaScriptAst.ObjectLiteral(
      ParameterMap.(
        commonImageParameterMap
        |> add(ResizeMode, LonaValue.string(resizeMode))
      )
      |> Layer.parameterMapToLogicValueMap
      |> Layer.mapBindings(((key, value)) =>
           createStyleAttributePropertyAST(framework, config, key, value)
         ),
    );
};

module NamedStyle = {
  open JavaScriptAst;

  let forLayer =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        parent: option(Types.layer),
        layer: Types.layer,
      ) =>
    Property({
      key: Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      value: Some(Object.forLayer(config, framework, parent, layer)),
    });

  let imageResizing =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        resizeMode: string,
      )
      : node =>
    Property({
      key:
        Identifier([JavaScriptFormat.imageResizeModeHelperName(resizeMode)]),
      value: Some(Object.imageResizing(config, framework, resizeMode)),
    });
};

module StyleSheet = {
  let create =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        rootLayer: Types.layer,
      ) => {
    let styleObjects =
      rootLayer
      |> Layer.flatmapParent(NamedStyle.forLayer(config, framework));

    let imageResizingStyles =
      rootLayer
      |> Layer.imageResizingModes
      |> List.map(NamedStyle.imageResizing(config, framework));

    let namedStyles = [styleObjects, imageResizingStyles] |> List.concat;

    JavaScriptAst.(
      VariableDeclaration(
        AssignmentExpression({
          left: Identifier(["styles"]),
          right:
            switch (framework) {
            | JavaScriptOptions.ReactDOM => ObjectLiteral(namedStyles)
            | _ =>
              CallExpression({
                callee: Identifier(["StyleSheet", "create"]),
                arguments: [ObjectLiteral(namedStyles)],
              })
            },
        }),
      )
    );
  };
};

module StyleSet = {
  let layerStyleBindings = (styles: Styles.viewLayerStyles('a)) => [
    ("backgroundColor", styles.backgroundColor),
    ("borderColor", styles.border.borderColor),
    ("borderRadius", styles.border.borderRadius),
    ("borderStyle", styles.border.borderStyle),
    ("borderWidth", styles.border.borderWidth),
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
        value: Some(ObjectLiteral(contents)),
      })
    );

  let createLayerObjectAST = (layerName: string, contents) =>
    JavaScriptAst.(
      Property({
        key: StringLiteral(layerName |> JavaScriptFormat.styleVariableName),
        value: Some(ObjectLiteral(contents)),
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

  let layerToThemeAST =
      (
        config: Config.t,
        framework: JavaScriptOptions.framework,
        layer: Types.layer,
      ) => {
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
                      config,
                      framework,
                      styleSet.styles,
                    ),
                  )
                ),
           )
         );

    createThemeObjectAST(layerObjectsAst);
  };
};