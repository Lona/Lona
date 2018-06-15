module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let styleNameKey = key =>
  switch key {
  | ParameterKey.TextStyle => "font"
  | _ => key |> ParameterKey.toString
  };

let createStyleAttributeAST = (colors, textStyles, layer: Types.layer, styles) =>
  Ast.(
    JSXAttribute({
      "name": "style",
      "value":
        ArrayLiteral([
          Identifier([
            "styles",
            JavaScriptFormat.styleVariableName(layer.name)
          ]),
          ObjectLiteral(
            Layer.mapBindings(((key, value)) =>
              Property({
                "key": Identifier([key |> styleNameKey]),
                "value": JavaScriptLogic.logicValueToJavaScriptAST(value)
              })
            ) @@
            styles
          )
        ])
    })
  );

let rec layerToJavaScriptAST =
        (colors, textStyles, variableMap, getAssetPath, layer: Types.layer) => {
  open Ast;
  let (_, mainParams) =
    layer.parameters
    |> Layer.parameterMapToLogicValueMap
    |> Layer.splitParamsMap;
  let (styleVariables, mainVariables) =
    (
      switch (Layer.LayerMap.find_opt(layer, variableMap)) {
      | Some(map) => map
      | None => ParameterMap.empty
      }
    )
    |> Layer.splitParamsMap;
  let main = ParameterMap.assign(mainParams, mainVariables);
  let styleAttribute =
    createStyleAttributeAST(colors, textStyles, layer, styleVariables);
  let attributes =
    main
    |> Layer.mapBindings(((key, value)) => {
         let key =
           switch (layer.typeName, key) {
           | (Types.Image, ParameterKey.Image) => "source"
           | _ => key |> ParameterKey.toString
           };
         let attributeValue =
           switch value {
           | Logic.Literal(lonaValue) when lonaValue.ltype == Types.urlType =>
             let path =
               switch (lonaValue.data |> Js.Json.decodeString) {
               | Some(url) =>
                 getAssetPath(url |> Js.String.replace("file://", ""))
               | None => ""
               };
             let pathValue: Types.lonaValue = {
               ltype: Types.urlType,
               data: Js.Json.string(path)
             };
             CallExpression({
               "callee": Identifier(["require"]),
               "arguments": [Literal(pathValue)]
             });
           | _ => JavaScriptLogic.logicValueToJavaScriptAST(value)
           };
         JSXAttribute({"name": key, "value": attributeValue});
       });
  let dynamicOrStaticValue = key =>
    switch (
      main |> ParameterMap.find_opt(key),
      layer.parameters |> ParameterMap.find_opt(key)
    ) {
    | (Some(param), _) => Some(param)
    | (None, Some(param)) => Some(Logic.Literal(param))
    | _ => None
    };
  let content =
    switch (layer.typeName, dynamicOrStaticValue(Text)) {
    | (Types.Text, Some(textValue)) => [
        JSXExpressionContainer(
          JavaScriptLogic.logicValueToJavaScriptAST(textValue)
        )
      ]
    | _ =>
      layer.children
      |> List.map(
           layerToJavaScriptAST(colors, textStyles, variableMap, getAssetPath)
         )
    };
  JSXElement({
    "tag": Types.layerTypeToString(layer.typeName),
    "attributes": [styleAttribute, ...attributes],
    "content": content
  });
};

let getStyleValue = (colors, value: Types.lonaValue) =>
  switch value.ltype {
  | Named("Color", _) =>
    let data = value.data |> Json.Decode.string;
    switch (Color.find(colors, data)) {
    | Some(color) => Ast.Identifier(["colors", color.id])
    | None => Ast.Literal(value)
    };
  | _ => Ast.Literal(value)
  };

let toJavaScriptStyleSheetAST =
    (framework: JavaScriptOptions.framework, colors, layer: Types.layer) => {
  open Ast;
  let createStyleObjectForLayer = (layer: Types.layer) => {
    let styleParams =
      layer.parameters
      |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key));
    Property({
      "key": Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      "value":
        ObjectLiteral(
          styleParams
          |> ParameterMap.bindings
          |> List.map(((key, value: Types.lonaValue)) =>
               switch key {
               | ParameterKey.TextStyle =>
                 switch (value.data |> Js.Json.decodeString) {
                 | Some(textStyleName) =>
                   let inner =
                     switch framework {
                     | JavaScriptOptions.ReactSketchapp =>
                       CallExpression({
                         "callee": Identifier(["TextStyles", "get"]),
                         "arguments": [
                           StringLiteral(
                             textStyleName
                             |> JavaScriptFormat.styleVariableName
                           )
                         ]
                       })
                     | _ =>
                       Identifier([
                         "textStyles",
                         textStyleName |> JavaScriptFormat.styleVariableName
                       ])
                     };
                   SpreadElement(inner);
                 | None =>
                   Js.log("Unknown TextStyle name");
                   raise(Not_found);
                 }
               | _ =>
                 Property({
                   "key": Identifier([key |> ParameterKey.toString]),
                   "value": getStyleValue(colors, value)
                 })
               }
             )
        )
    });
  };
  let styleObjects =
    layer |> Layer.flatten |> List.map(createStyleObjectForLayer);
  VariableDeclaration(
    AssignmentExpression({
      "left": Identifier(["styles"]),
      "right":
        CallExpression({
          "callee": Identifier(["StyleSheet", "create"]),
          "arguments": [ObjectLiteral(styleObjects)]
        })
    })
  );
};

type componentImports = {
  absolute: list(Ast.node),
  relative: list(Ast.node)
};

let importComponents =
    (framework: JavaScriptOptions.framework, getComponentFile, rootLayer) => {
  let {builtIn, custom}: Layer.availableTypeNames =
    rootLayer |> Layer.getTypeNames;
  {
    absolute: [
      Ast.ImportDeclaration({
        "source":
          switch framework {
          | JavaScriptOptions.ReactSketchapp => "@mathieudutour/react-sketchapp"
          | _ => "react-native"
          },
        "specifiers":
          (
            List.map(typeName =>
              Ast.ImportSpecifier({
                "imported": Types.layerTypeToString(typeName),
                "local": None
              })
            ) @@
            builtIn
          )
          @ [Ast.ImportSpecifier({"imported": "StyleSheet", "local": None})]
          @ (
            switch framework {
            | JavaScriptOptions.ReactSketchapp => [
                Ast.ImportSpecifier({"imported": "TextStyles", "local": None})
              ]
            | _ => []
            }
          )
      })
    ],
    relative:
      List.map(componentName =>
        Ast.ImportDeclaration({
          "source":
            getComponentFile(componentName)
            |> Js.String.replace(".component", ""),
          "specifiers": [Ast.ImportDefaultSpecifier(componentName)]
        })
      ) @@
      custom
  };
};

let generate =
    (
      options: JavaScriptOptions.options,
      name,
      colorsFilePath,
      textStylesFilePath,
      colors,
      textStyles,
      getComponent,
      getComponentFile,
      getAssetPath,
      json
    ) => {
  let rootLayer = json |> Decode.Component.rootLayer(getComponent);
  let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let rootLayerAST =
    rootLayer
    |> layerToJavaScriptAST(colors, textStyles, assignments, getAssetPath);
  let styleSheetAST =
    rootLayer |> toJavaScriptStyleSheetAST(options.framework, colors);
  let logicAST = logic |> JavaScriptLogic.toJavaScriptAST |> Ast.optimize;
  let {absolute, relative} =
    rootLayer |> importComponents(options.framework, getComponentFile);
  Ast.(
    Program(
      SwiftDocument.joinGroups(
        Ast.Empty,
        [
          [
            ImportDeclaration({
              "source": "react",
              "specifiers": [ImportDefaultSpecifier("React")]
            })
          ]
          @ absolute,
          [
            ImportDeclaration({
              "source": colorsFilePath |> Js.String.replace(".json", ""),
              "specifiers": [ImportDefaultSpecifier("colors")]
            }),
            ImportDeclaration({
              "source": textStylesFilePath |> Js.String.replace(".json", ""),
              "specifiers": [ImportDefaultSpecifier("textStyles")]
            })
          ]
          @ relative,
          [
            ExportDefaultDeclaration(
              ClassDeclaration({
                "id": name,
                "superClass": Some("React.Component"),
                "body": [
                  MethodDefinition({
                    "key": "render",
                    "value":
                      FunctionExpression({
                        "id": None,
                        "params": [],
                        "body": [logicAST, Return(rootLayerAST)]
                      })
                  })
                ]
              })
            )
          ],
          [styleSheetAST]
        ]
      )
    )
  )
  /* Renames variables */
  |> Ast.prepareForRender;
};