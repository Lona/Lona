let getTextStyleProperty =
    (framework: JavaScriptOptions.framework, textStyleId) =>
  JavaScriptAst.(
    SpreadElement(
      switch framework {
      | JavaScriptOptions.ReactSketchapp =>
        CallExpression({
          "callee": Identifier(["TextStyles", "get"]),
          "arguments": [
            StringLiteral(textStyleId |> JavaScriptFormat.styleVariableName)
          ]
        })
      | _ =>
        Identifier([
          "textStyles",
          textStyleId |> JavaScriptFormat.styleVariableName
        ])
      }
    )
  );

let getStyleProperty =
    (
      framework: JavaScriptOptions.framework,
      key,
      colors,
      value: Types.lonaValue
    ) => {
  let keyIdentifier = JavaScriptAst.Identifier([key |> ParameterKey.toString]);
  JavaScriptAst.(
    switch value.ltype {
    | Named("TextStyle", _) =>
      let data = value.data |> Js.Json.decodeString;
      switch data {
      | Some(textStyleId) => getTextStyleProperty(framework, textStyleId)
      | None =>
        Js.log("TextStyle id must be a string");
        raise(Not_found);
      };
    | Named("Color", _) =>
      let data = value.data |> Json.Decode.string;
      switch (Color.find(colors, data)) {
      | Some(color) =>
        Property({
          "key": keyIdentifier,
          "value": Identifier(["colors", color.id])
        })
      | None => Property({"key": keyIdentifier, "value": Literal(value)})
      };
    | _ => Property({"key": keyIdentifier, "value": Literal(value)})
    }
  );
};

let addDefaultStyles =
    (framework: JavaScriptOptions.framework, layer: Types.layer) => {
  let styleParams =
    layer.parameters
    |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key));
  ParameterMap.assign(
    styleParams,
    switch framework {
    | JavaScriptOptions.ReactDOM =>
      ParameterMap.add(
        ParameterKey.Display,
        LonaValue.string("flex"),
        ParameterMap.empty
      )
    | _ => ParameterMap.empty
    }
  );
};

let getStylePropertyWithUnits =
    (
      framework: JavaScriptOptions.framework,
      colors,
      key,
      value: Types.lonaValue
    ) =>
  JavaScriptAst.(
    switch (framework, key |> ReactDomTranslators.isUnitNumberParameter) {
    | (JavaScriptOptions.ReactDOM, true) =>
      Property({
        "key": Identifier([key |> ParameterKey.toString]),
        "value":
          Literal(
            LonaValue.string(
              value.data |> ReactDomTranslators.convertUnitlessStyle
            )
          )
      })
    | (_, _) => getStyleProperty(framework, key, colors, value)
    }
  );

let createStyleObjectForLayer =
    (framework: JavaScriptOptions.framework, colors, layer: Types.layer) =>
  JavaScriptAst.(
    Property({
      "key": Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      "value":
        ObjectLiteral(
          layer
          |> addDefaultStyles(framework)
          |> ParameterMap.bindings
          |> List.map(((key, value)) =>
               getStylePropertyWithUnits(framework, colors, key, value)
             )
        )
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
        "left": Identifier(["styles"]),
        "right":
          switch framework {
          | JavaScriptOptions.ReactDOM => ObjectLiteral(styleObjects)
          | _ =>
            CallExpression({
              "callee": Identifier(["StyleSheet", "create"]),
              "arguments": [ObjectLiteral(styleObjects)]
            })
          }
      })
    )
  );
};