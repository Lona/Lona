module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let styleNameKey = key =>
  switch (key) {
  | ParameterKey.TextStyle => "font"
  | _ => key |> ParameterKey.toString
  };

let getElementTagString =
    (framework: JavaScriptOptions.framework, typeName: Types.layerType) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => ReactDomTranslators.layerTypeTags(typeName)
  /* | JavaScriptOptions.ReactDOM => JavaScriptFormat.elementName(layer.name) */
  | _ =>
    switch (typeName) {
    | View => "View"
    | Text => "Text"
    | Image => "Image"
    | Animation => "Animation"
    | Children => "Children"
    | Component(value) => value
    | _ => "Unknown"
    }
  };

module StyledComponents = {
  let createStyleSetObjectProperties = viewVariableName =>
    JavaScriptAst.[
      SpreadElement(
        Identifier(["props", "theme", viewVariableName, "normal"]),
      ),
      Property({
        key: StringLiteral(":hover"),
        value: Identifier(["props", "theme", viewVariableName, "hovered"]),
      }),
    ];

  let createDynamicStyles = contents =>
    JavaScriptAst.(
      ArrowFunctionExpression({
        id: None,
        params: ["props"],
        body: [Return(ObjectLiteral(contents))],
      })
    );

  let createStyledComponentAST = (layer: Types.layer) =>
    JavaScriptAst.(
      VariableDeclaration(
        AssignmentExpression({
          left: Identifier([JavaScriptFormat.elementName(layer.name)]),
          right:
            CallExpression({
              callee:
                Identifier([
                  "styled",
                  layer.typeName |> ReactDomTranslators.layerTypeTags,
                ]),
              arguments: [
                createDynamicStyles(
                  createStyleSetObjectProperties(
                    layer.name |> JavaScriptFormat.styleVariableName,
                  ),
                ),
              ],
            }),
        }),
      )
    );

  let createdAllStyledComponentsAST = (layer: Types.layer) =>
    layer |> Layer.flatten |> List.map(createStyledComponentAST);
};

let createStyleAttributePropertyAST =
    (config: Config.t, key: ParameterKey.t, value: Logic.logicValue) =>
  switch (key) {
  | ParameterKey.TextStyle =>
    JavaScriptAst.SpreadElement(
      JavaScriptLogic.logicValueToJavaScriptAST(config, value),
    )
  | _ =>
    JavaScriptAst.Property({
      key: Identifier([key |> styleNameKey]),
      value: JavaScriptLogic.logicValueToJavaScriptAST(config, value),
    })
  };

let createStyleAttributeAST =
    (
      framework: JavaScriptOptions.framework,
      config: Config.t,
      layer: Types.layer,
      styles,
    ) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM =>
    Ast.(
      JSXAttribute({
        name: "style",
        value:
          CallExpression({
            callee: Identifier(["Object", "assign"]),
            arguments: [
              ObjectLiteral([]),
              Identifier([
                "styles",
                JavaScriptFormat.styleVariableName(layer.name),
              ]),
              ObjectLiteral(
                Layer.mapBindings(((key, value)) =>
                  createStyleAttributePropertyAST(config, key, value)
                ) @@
                styles,
              ),
            ],
          }),
      })
    )
  | _ =>
    Ast.(
      JSXAttribute({
        name: "style",
        value:
          ArrayLiteral([
            Identifier([
              "styles",
              JavaScriptFormat.styleVariableName(layer.name),
            ]),
            ObjectLiteral(
              Layer.mapBindings(((key, value)) =>
                createStyleAttributePropertyAST(config, key, value)
              ) @@
              styles,
            ),
          ]),
      })
    )
  };

let rec layerToJavaScriptAST =
        (
          framework: JavaScriptOptions.framework,
          config: Config.t,
          variableMap,
          getAssetPath,
          parent: option(Types.layer),
          layer: Types.layer,
        ) => {
  open Ast;
  let nonTextTypeName = (key: ParameterKey.t, _) =>
    switch (key) {
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
    switch (framework) {
    /* | JavaScriptOptions.ReactDOM => [] */
    | _ => [
        createStyleAttributeAST(framework, config, layer, styleVariables),
      ]
    };
  let attributes =
    main
    |> removeTextParams
    |> Layer.mapBindings(((key, value)) => {
         let key =
           switch (framework) {
           | JavaScriptOptions.ReactDOM =>
             key |> ReactDomTranslators.variableNames
           | _ => key |> ReactNativeTranslators.variableNames
           };

         let attributeValue =
           switch (value) {
           | Logic.Literal(lonaValue) when lonaValue.ltype == Types.urlType =>
             let path =
               switch (lonaValue.data |> Js.Json.decodeString) {
               | Some(url) =>
                 getAssetPath(url |> Js.String.replace("file://", ""))
               | None => ""
               };
             let pathValue: Types.lonaValue = {
               ltype: Types.urlType,
               data: Js.Json.string(path),
             };
             CallExpression({
               callee: Identifier(["require"]),
               arguments: [Literal(pathValue)],
             });
           | _ => JavaScriptLogic.logicValueToJavaScriptAST(config, value)
           };
         JSXAttribute({name: key, value: attributeValue});
       });
  let dynamicOrStaticValue = key =>
    switch (
      main |> ParameterMap.find_opt(key),
      layer.parameters |> ParameterMap.find_opt(key),
    ) {
    | (Some(param), _) => Some(param)
    | (None, Some(param)) => Some(Logic.Literal(param))
    | _ => None
    };
  let content =
    switch (layer.typeName, dynamicOrStaticValue(Text)) {
    | (Types.Text, Some(textValue)) => [
        JSXExpressionContainer(
          JavaScriptLogic.logicValueToJavaScriptAST(config, textValue),
        ),
      ]
    | _ =>
      layer.children
      |> List.map(
           layerToJavaScriptAST(
             framework,
             config,
             variableMap,
             getAssetPath,
             Some(layer),
           ),
         )
    };

  /* Wrap custom components in a view that enforces the framework's
     default layout attributes. */
  switch (layer.typeName, parent) {
  | (Types.Component(_), Some(parent)) =>
    let parentDirection = Layer.getFlexDirection(parent.parameters);

    /* Custom components can't be passed styles, so don't include the style attribute */
    let customComponent =
      JSXElement({
        tag: getElementTagString(framework, layer.typeName),
        attributes,
        content,
      });

    switch (framework, parentDirection) {
    | (JavaScriptOptions.ReactDOM, "column")
    | (JavaScriptOptions.ReactNative, "row")
    | (JavaScriptOptions.ReactSketchapp, "row") =>
      JSXElement({
        tag: getElementTagString(framework, Types.View),
        attributes: styleAttribute,
        content: [customComponent],
      })
    | _ => customComponent
    };
  | _ =>
    JSXElement({
      tag: getElementTagString(framework, layer.typeName),
      attributes: styleAttribute @ attributes,
      content,
    })
  };
};

type componentImports = {
  absolute: list(Ast.node),
  relative: list(Ast.node),
};

let importComponents =
    (framework: JavaScriptOptions.framework, getComponentFile, rootLayer) => {
  let {builtIn, custom}: Layer.availableTypeNames =
    rootLayer |> Layer.getTypeNames;
  {
    absolute:
      switch (framework) {
      | JavaScriptOptions.ReactDOM => [
          Ast.ImportDeclaration({
            source: "styled-components",
            specifiers: [
              ImportDefaultSpecifier("styled"),
              ImportSpecifier({imported: "ThemeProvider", local: None}),
            ],
          }),
        ]
      | _ => [
          Ast.ImportDeclaration({
            source:
              switch (framework) {
              | JavaScriptOptions.ReactSketchapp => "@mathieudutour/react-sketchapp"
              | _ => "react-native"
              },
            specifiers:
              (
                List.map(typeName =>
                  Ast.ImportSpecifier({
                    imported: Types.layerTypeToString(typeName),
                    local: None,
                  })
                ) @@
                builtIn
              )
              @ [Ast.ImportSpecifier({imported: "StyleSheet", local: None})]
              @ (
                switch (framework) {
                | JavaScriptOptions.ReactSketchapp => [
                    Ast.ImportSpecifier({
                      imported: "TextStyles",
                      local: None,
                    }),
                  ]
                | _ => []
                }
              ),
          }),
        ]
      },
    relative:
      List.map(componentName =>
        Ast.ImportDeclaration({
          source:
            getComponentFile(componentName)
            |> Js.String.replace(".component", ""),
          specifiers: [Ast.ImportDefaultSpecifier(componentName)],
        })
      ) @@
      custom,
  };
};

let rootLayerToJavaScriptAST =
    (
      options: JavaScriptOptions.options,
      config: Config.t,
      getAssetPath,
      assignments,
      rootLayer,
    ) => {
  let astRootLayer =
    rootLayer
    |> layerToJavaScriptAST(
         options.framework,
         config,
         assignments,
         getAssetPath,
         None,
       );

  switch (options.framework) {
  | ReactDOM =>
    JavaScriptAst.(
      JSXElement({
        tag: "ThemeProvider",
        attributes: [
          JSXAttribute({name: "theme", value: Identifier(["theme"])}),
        ],
        content: [astRootLayer],
      })
    )
  | _ => astRootLayer
  };
};

let defineInitialLogicValues =
    (config: Config.t, getComponent, rootLayer, assignments, logic) => {
  let variableDeclarations = logic |> Logic.buildVariableDeclarations;
  let conditionalAssignments = Logic.conditionallyAssignedIdentifiers(logic);
  let isConditionallyAssigned = (layer: Types.layer, (name, _)) => {
    let isAssigned = ((_, value)) =>
      value == ["layers", layer.name, name |> ParameterKey.toString];
    Logic.IdentifierSet.exists(isAssigned, conditionalAssignments);
  };
  let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
    let layerParameterAssignments =
      Layer.logicAssignmentsFromLayerParameters(rootLayer);
    let parameters =
      Layer.LayerMap.find_opt(layer, layerParameterAssignments);
    let getParameter = (layer: Types.layer, parameter) =>
      ParameterMap.find_opt(parameter, layer.parameters);
    switch (parameters) {
    | None => Logic.None
    | Some(parameters) =>
      let assignment = ParameterMap.find_opt(name, parameters);
      let parameterValue = getParameter(layer, name);
      switch (assignment, layer.typeName, parameterValue) {
      | (Some(assignment), _, _) => assignment
      | (None, Component(componentName), _) =>
        let param =
          getComponent(componentName)
          |> Decode.Component.parameters
          |> List.find((param: Types.parameter) => param.name == name);
        Logic.assignmentForLayerParameter(
          layer,
          name,
          Logic.defaultValueForType(param.ltype),
        );
      | (None, _, Some(value)) =>
        Logic.assignmentForLayerParameter(layer, name, value)
      | (None, _, None) =>
        Logic.defaultAssignmentForLayerParameter(config, layer, name)
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
  Logic.Block([variableDeclarations] @ newVars @ [logic]);
};

let generate =
    (
      options: JavaScriptOptions.options,
      componentName,
      colorsFilePath,
      textStylesFilePath,
      config: Config.t,
      getComponent,
      getComponentFile,
      getAssetPath,
      json,
    ) => {
  let rootLayer = json |> Decode.Component.rootLayer(getComponent);
  let logic = json |> Decode.Component.logic;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);

  let themeAST =
    JavaScriptStyles.StyleSet.layerToThemeAST(
      options.framework,
      config.colorsFile.contents,
      rootLayer,
    );

  let rootLayerAST =
    rootLayerToJavaScriptAST(
      options,
      config,
      getAssetPath,
      assignments,
      rootLayer,
    );

  let styleSheetAST =
    JavaScriptStyles.layerToJavaScriptStyleSheetAST(
      config,
      options.framework,
      config.colorsFile.contents,
      rootLayer,
    );

  let logicAST =
    logic
    |> defineInitialLogicValues(config, getComponent, rootLayer, assignments)
    |> JavaScriptLogic.toJavaScriptAST(options.framework, config)
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
              source: "react",
              specifiers: [ImportDefaultSpecifier("React")],
            }),
          ]
          @ absolute,
          [
            ImportDeclaration({
              source: colorsFilePath |> Js.String.replace(".json", ""),
              specifiers: [ImportDefaultSpecifier("colors")],
            }),
            ImportDeclaration({
              source: textStylesFilePath |> Js.String.replace(".json", ""),
              specifiers: [ImportDefaultSpecifier("textStyles")],
            }),
          ]
          @ relative,
          [
            ExportDefaultDeclaration(
              ClassDeclaration({
                id: componentName,
                superClass: Some("React.Component"),
                body: [
                  MethodDefinition({
                    key: "render",
                    value:
                      FunctionExpression({
                        id: None,
                        params: [],
                        body:
                          [logicAST]
                          @ (
                            switch (options.framework) {
                            | JavaScriptOptions.ReactDOM => [themeAST]
                            | _ => []
                            }
                          )
                          @ [Return(rootLayerAST)],
                      }),
                  }),
                ],
              }),
            ),
          ],
          switch (options.framework) {
          /* | JavaScriptOptions.ReactDOM =>
             StyledComponents.createdAllStyledComponentsAST(rootLayer) */
          | _ => [styleSheetAST]
          },
        ],
      ),
    )
  )
  /* Renames variables */
  |> Ast.prepareForRender;
};