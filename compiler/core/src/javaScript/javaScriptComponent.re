module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let createStyleAttributeAST = (layerName, styles) =>
  Ast.(
    JSXAttribute({
      "name": "style",
      "value":
        ArrayLiteral([
          Identifier([
            "styles",
            JavaScriptFormat.styleVariableName(layerName)
          ]),
          ObjectLiteral(
            styles
            |> Layer.mapBindings(((key, value)) =>
                 Property({
                   "key": Identifier([key]),
                   "value": JavaScriptLogic.logicValueToJavaScriptAST(value)
                 })
               )
          )
        ])
    })
  );

let rec layerToJavaScriptAST = (variableMap, layer: Types.layer) => {
  open Ast;
  let (_, mainParams) =
    layer.parameters
    |> Layer.parameterMapToLogicValueMap
    |> Layer.splitParamsMap;
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
    |> Layer.mapBindings(((key, value)) =>
         JSXAttribute({
           "name": key,
           "value": JavaScriptLogic.logicValueToJavaScriptAST(value)
         })
       );
  JSXElement({
    "tag": Layer.layerTypeToString(layer.typeName),
    "attributes": [styleAttribute, ...attributes],
    "content": layer.children |> List.map(layerToJavaScriptAST(variableMap))
  });
};

let toJavaScriptStyleSheetAST = (layer: Types.layer) => {
  open Ast;
  let createStyleObjectForLayer = (layer: Types.layer) => {
    let styleParams =
      layer.parameters
      |> StringMap.filter((key, _) => Layer.parameterIsStyle(key));
    Property({
      "key": Identifier([JavaScriptFormat.styleVariableName(layer.name)]),
      "value":
        ObjectLiteral(
          styleParams
          |> StringMap.bindings
          |> List.map(((key, value)) =>
               Property({"key": Identifier([key]), "value": Literal(value)})
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

let importComponents = (getComponentFile, rootLayer) => {
  let {builtIn, custom}: Layer.availableTypeNames =
    rootLayer |> Layer.getTypeNames;
  {
    absolute: [
      Ast.ImportDeclaration({
        "source": "react-native",
        "specifiers":
          List.map(typeName =>
            Ast.ImportSpecifier({
              "imported": Layer.layerTypeToString(typeName),
              "local": None
            })
          ) @@
          builtIn
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
      name,
      colorsFilePath,
      textStylesFilePath,
      getComponent,
      getComponentFile,
      json
    ) => {
  let rootLayer = json |> Decode.Component.rootLayer(getComponent);
  let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let rootLayerAST = rootLayer |> layerToJavaScriptAST(assignments);
  let styleSheetAST = rootLayer |> toJavaScriptStyleSheetAST;
  let logicAST = logic |> JavaScriptLogic.toJavaScriptAST |> Ast.optimize;
  let {absolute, relative} = rootLayer |> importComponents(getComponentFile);
  Ast.(
    Program(
      SwiftDocument.joinGroups(
        Ast.Empty,
        [
          absolute,
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
          ],
          [styleSheetAST]
        ]
      )
    )
  )
  /* Renames variables */
  |> Ast.prepareForRender;
};