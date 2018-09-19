module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let styleNameKey = key =>
  switch key {
  | ParameterKey.TextStyle => "font"
  | _ => key |> ParameterKey.toString
  };

let createStyleAttributeAST =
    (
      framework: JavaScriptOptions.framework,
      colors,
      textStyles,
      layer: Types.layer,
      styles
    ) =>
  switch framework {
  | JavaScriptOptions.ReactDOM =>
    Ast.(
      JSXAttribute({
        "name": "style",
        "value":
          CallExpression({
            "callee": Identifier(["Object", "assign"]),
            "arguments": [
              Identifier([
                "styles",
                JavaScriptFormat.styleVariableName(layer.name)
              ]),
              ObjectLiteral(
                Layer.mapBindings(((key, value)) =>
                  Property({
                    "key": Identifier([key |> styleNameKey]),
                    "value":
                      JavaScriptLogic.logicValueToJavaScriptAST(
                        colors,
                        textStyles,
                        value
                      )
                  })
                ) @@
                styles
              )
            ]
          })
      })
    )
  | _ =>
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
                  "value":
                    JavaScriptLogic.logicValueToJavaScriptAST(
                      colors,
                      textStyles,
                      value
                    )
                })
              ) @@
              styles
            )
          ])
      })
    )
  };

let getLayerTypeTagString =
    (framework: JavaScriptOptions.framework, layerType: Types.layerType) =>
  switch framework {
  | JavaScriptOptions.ReactDOM =>
    layerType |> ReactDomTranslators.layerTypeTags
  | _ =>
    switch layerType {
    | View => "View"
    | Text => "Text"
    | Image => "Image"
    | Animation => "Animation"
    | Children => "Children"
    | Component(value) => value
    | _ => "Unknown"
    }
  };

let rec layerToJavaScriptAST =
        (
          framework: JavaScriptOptions.framework,
          colors,
          textStyles,
          variableMap,
          getAssetPath,
          layer: Types.layer
        ) => {
  open Ast;
  let nonTextTypeName = (key: ParameterKey.t, _) =>
    switch key {
    | ParameterKey.Text => false
    | _ => true
    };
  let removeTextParams = params =>
    params |> ParameterMap.filter(nonTextTypeName);
  let (_, mainParams) =
    layer.parameters
    |> removeTextParams
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
    createStyleAttributeAST(
      framework,
      colors,
      textStyles,
      layer,
      styleVariables
    );
  let attributes =
    main
    |> removeTextParams
    |> Layer.mapBindings(((key, value)) => {
         let key =
           switch (layer.typeName, key) {
           | (Types.Image, ParameterKey.Image) => "source"
           | _ =>
             switch framework {
             | JavaScriptOptions.ReactDOM =>
               key |> ReactDomTranslators.variableNames
             | _ => key |> ParameterKey.toString
             }
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
           | _ =>
             JavaScriptLogic.logicValueToJavaScriptAST(
               colors,
               textStyles,
               value
             )
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
          JavaScriptLogic.logicValueToJavaScriptAST(
            colors,
            textStyles,
            textValue
          )
        )
      ]
    | _ =>
      layer.children
      |> List.map(
           layerToJavaScriptAST(
             framework,
             colors,
             textStyles,
             variableMap,
             getAssetPath
           )
         )
    };
  JSXElement({
    "tag": getLayerTypeTagString(framework, layer.typeName),
    "attributes": [styleAttribute, ...attributes],
    "content": content
  });
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
    absolute:
      switch framework {
      | JavaScriptOptions.ReactDOM => []
      | _ => [
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
              @ [
                Ast.ImportSpecifier({"imported": "StyleSheet", "local": None})
              ]
              @ (
                switch framework {
                | JavaScriptOptions.ReactSketchapp => [
                    Ast.ImportSpecifier({
                      "imported": "TextStyles",
                      "local": None
                    })
                  ]
                | _ => []
                }
              )
          })
        ]
      },
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
  let logic = json |> Decode.Component.logic;
  let variableDeclarations = logic |> Logic.buildVariableDeclarations;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let conditionalAssignments = Logic.conditionallyAssignedIdentifiers(logic);
  let isConditionallyAssigned = (layer: Types.layer, (name, _)) => {
    let isAssigned = ((_, value)) =>
      value == ["layers", layer.name, name |> ParameterKey.toString];
    Logic.IdentifierSet.exists(isAssigned, conditionalAssignments);
  };
  let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
    let layerParameterAssignments =
      Layer.logicAssignmentsFromLayerParameters(rootLayer);
    let parameters = Layer.LayerMap.find_opt(layer, layerParameterAssignments);
    let getParameter = (layer: Types.layer, parameter) =>
      ParameterMap.find_opt(parameter, layer.parameters);
    switch parameters {
    | None => Logic.None
    | Some(parameters) =>
      let assignment = ParameterMap.find_opt(name, parameters);
      let parameterValue = getParameter(layer, name);
      switch (assignment, layer.typeName, parameterValue) {
      | (Some(assignment), _, _) =>
        Js.log2("a", ParameterKey.toString(name));
        assignment;
      | (None, Component(componentName), _) =>
        let param =
          getComponent(componentName)
          |> Decode.Component.parameters
          |> List.find((param: Types.parameter) => param.name == name);
        Logic.assignmentForLayerParameter(
          layer,
          name,
          Logic.defaultValueForType(param.ltype)
        );
      | (None, _, Some(value)) =>
        Logic.assignmentForLayerParameter(layer, name, value)
      | (None, _, None) =>
        Logic.defaultAssignmentForLayerParameter(
          colors,
          textStyles,
          layer,
          name
        )
      };
    };
  };
  let defineInitialLayerValues = ((layer, propertyMap)) =>
    propertyMap
    |> ParameterMap.bindings
    |> List.filter(isConditionallyAssigned(layer))
    |> List.map(((k, v)) => defineInitialLayerValue(layer, (k, v)));
  let newVars =
    assignments
    |> Layer.LayerMap.bindings
    |> List.map(defineInitialLayerValues)
    |> List.concat;
  let logic = Logic.Block([variableDeclarations] @ newVars @ [logic]);
  let rootLayerAST =
    rootLayer
    |> layerToJavaScriptAST(
         options.framework,
         colors,
         textStyles,
         assignments,
         getAssetPath
       );
  let styleSheetAST =
    rootLayer
    |> JavaScriptStyles.layerToJavaScriptStyleSheetAST(
         options.framework,
         colors
       );
  let logicAST =
    logic
    |> JavaScriptLogic.toJavaScriptAST(options.framework, colors, textStyles)
    |> Ast.optimize;
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