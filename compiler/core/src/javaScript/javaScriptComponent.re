module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let createStyleAttributeAST = (layerName, styles) =>
  Ast.(
    JSXAttribute(
      "style",
      ArrayLiteral([
        Identifier(["styles", layerName]),
        ObjectLiteral(
          styles
          |> Layer.mapBindings(
               ((key, value)) =>
                 ObjectProperty(
                   Identifier([key]),
                   JavaScriptLogic.logicValueToJavaScriptAST(value)
                 )
             )
        )
      ])
    )
  );

let rec layerToJavaScriptAST = (variableMap, layer: Types.layer) => {
  open Ast;
  let (_, mainParams) =
    layer.parameters |> Layer.parameterMapToLogicValueMap |> Layer.splitParamsMap;
  let (styleVariables, mainVariables) =
    (
      switch (Layer.LayerMap.find_opt(layer, variableMap)) {
      | Some(map) => map
      | None => StringMap.empty
      }
    )
    |> Layer.splitParamsMap;
  let main = StringMap.assign(mainParams, mainVariables);
  let styleAttribute = createStyleAttributeAST(layer.name, styleVariables);
  let attributes =
    main
    |> Layer.mapBindings(
         ((key, value)) => JSXAttribute(key, JavaScriptLogic.logicValueToJavaScriptAST(value))
       );
  JSXElement(
    Layer.layerTypeToString(layer.typeName),
    [styleAttribute, ...attributes],
    layer.children |> List.map(layerToJavaScriptAST(variableMap))
  )
};

let toJavaScriptStyleSheetAST = (layer: Types.layer) => {
  open Ast;
  let createStyleObjectForLayer = (layer: Types.layer) => {
    let styleParams =
      layer.parameters |> StringMap.filter((key, _) => Layer.parameterIsStyle(key));
    ObjectProperty(
      Identifier([layer.name]),
      ObjectLiteral(
        styleParams
        |> StringMap.bindings
        |> List.map(((key, value)) => ObjectProperty(Identifier([key]), Literal(value)))
      )
    )
  };
  let styleObjects = layer |> Layer.flatten |> List.map(createStyleObjectForLayer);
  VariableDeclaration(
    AssignmentExpression(
      Identifier(["styles"]),
      CallExpression(Identifier(["StyleSheet", "create"]), [ObjectLiteral(styleObjects)])
    )
  )
};

let generate = (name, json) => {
  let rootLayer = json |> Decode.Component.rootLayer;
  let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let rootLayerAST = rootLayer |> layerToJavaScriptAST(assignments);
  let styleSheetAST = rootLayer |> toJavaScriptStyleSheetAST;
  let logicAST = logic |> JavaScriptLogic.toJavaScriptAST |> Ast.optimize;
  Ast.(
    Program([
      Class(
        name,
        Some("React.Component"),
        [Method("render", [], [logicAST, Return(rootLayerAST)])]
      ),
      styleSheetAST
    ])
  )
  /* Renames variables */
  |> Ast.prepareForRender
};