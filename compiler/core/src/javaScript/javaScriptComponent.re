module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let frameworkSpecificValue =
    (framework, container: Types.platformSpecificValue('a)) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => container.reactDom
  | JavaScriptOptions.ReactNative => container.reactNative
  | JavaScriptOptions.ReactSketchapp => container.reactSketchapp
  };

let styleNameKey = key =>
  switch (key) {
  | ParameterKey.TextStyle => "font"
  | _ => key |> ParameterKey.toString
  };

let getElementTagString =
    (framework: JavaScriptOptions.framework, typeName: Types.layerType) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => ReactDomTranslators.layerTypeTags(typeName)
  | _ =>
    switch (typeName) {
    | View => "View"
    | Text => "Text"
    | Image => "Image"
    | VectorGraphic => "VectorGraphic"
    | Animation => "Animation"
    | Children => "Children"
    | Component(value) => value
    | _ => "Unknown"
    }
  };

let getElementOrVectorTagString =
    (framework: JavaScriptOptions.framework, layer: Types.layer) => {
  let override =
    frameworkSpecificValue(framework, layer.metadata.backingElementClass);
  switch (override, layer.typeName) {
  | (Some(value), _) => value
  | (None, VectorGraphic) =>
    SwiftComponentParameter.getVectorAssetUrl(layer) |> Format.vectorClassName
  | _ => getElementTagString(framework, layer.typeName)
  };
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
  | ParameterKey.Shadow =>
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
      styles: ParameterMap.t(Logic.logicValue),
    ) => {
  let dynamicStyles =
    if (styles |> ParameterMap.is_empty) {
      None;
    } else {
      Some(
        Ast.ObjectLiteral(
          styles
          |> Layer.mapBindings(((key, value)) =>
               createStyleAttributePropertyAST(config, key, value)
             ),
        ),
      );
    };

  let staticStyles =
    Ast.Identifier([
      "styles",
      JavaScriptFormat.styleVariableName(layer.name),
    ]);

  switch (framework) {
  | JavaScriptOptions.ReactDOM =>
    Ast.(
      JSXAttribute({
        name: "style",
        value:
          switch (dynamicStyles) {
          | None => staticStyles
          | Some(dynamicStyles) =>
            CallExpression({
              callee: Identifier(["Object", "assign"]),
              arguments: [ObjectLiteral([]), staticStyles, dynamicStyles],
            })
          },
      })
    )
  | _ =>
    Ast.(
      JSXAttribute({
        name: "style",
        value:
          switch (dynamicStyles) {
          | None => staticStyles
          | Some(dynamicStyles) =>
            ArrayLiteral([staticStyles, dynamicStyles])
          },
      })
    )
  };
};

/* Wrap custom components in a view that enforces the framework's
   default layout attributes. */
let createJSXElement =
    (
      framework: JavaScriptOptions.framework,
      parent: option(Types.layer),
      layer: Types.layer,
      attributes: list(JavaScriptAst.node),
      styleAttribute: list(JavaScriptAst.node),
      content: list(JavaScriptAst.node),
    )
    : JavaScriptAst.node =>
  switch (layer.typeName, parent) {
  | (Types.Component(_), Some(parent)) =>
    let parentDirection = Layer.getFlexDirection(parent.parameters);

    /* Custom components can't be passed styles, so don't include the style attribute */
    let customComponent =
      JavaScriptAst.JSXElement({
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
      tag: getElementOrVectorTagString(framework, layer),
      attributes: styleAttribute @ attributes,
      content,
    })
  };

let rec layerToJavaScriptAST =
        (
          framework: JavaScriptOptions.framework,
          config: Config.t,
          logic,
          assignments,
          getAssetPath,
          parent: option(Types.layer),
          layer: Types.layer,
        ) => {
  open Ast;
  let removeSpecialParams = params =>
    params
    |> ParameterMap.filter((key: ParameterKey.t, _) =>
         switch (key, framework) {
         | (ParameterKey.NumberOfLines, JavaScriptOptions.ReactDOM) => false
         | (ParameterKey.Text, _) => false
         | (ParameterKey.Visible, _) => false
         | (ParameterKey.Image, _) when layer.typeName == VectorGraphic =>
           false
         | (_, _) => true
         }
       );
  let (_, mainParams) =
    layer.parameters
    |> removeSpecialParams
    |> Layer.parameterMapToLogicValueMap
    |> Layer.splitParamsMap;
  let (styleVariables, mainVariables) =
    (
      switch (Layer.LayerMap.find_opt(layer, assignments)) {
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
    |> removeSpecialParams
    |> Layer.mapBindings(((key, value)) => {
         let key =
           if (Layer.isPrimitiveTypeName(layer.typeName)) {
             switch (framework) {
             | JavaScriptOptions.ReactDOM =>
               key |> ReactDomTranslators.variableNames
             | _ => key |> ReactNativeTranslators.variableNames
             };
           } else {
             key |> ParameterKey.toString;
           };

         let attributeValue =
           switch (value) {
           | Logic.Literal(lonaValue) when lonaValue.ltype == Types.urlType =>
             switch (lonaValue.data |> Js.Json.decodeString) {
             | Some(url) when Js.String.startsWith("file://", url) =>
               let path =
                 getAssetPath(url |> Js.String.replace("file://", ""));
               let pathValue: Types.lonaValue = {
                 ltype: Types.urlType,
                 data: Js.Json.string(path),
               };
               CallExpression({
                 callee: Identifier(["require"]),
                 arguments: [Literal(pathValue)],
               });
             | Some(url) =>
               Literal(
                 {ltype: Types.urlType, data: Js.Json.string(url)}: Types.lonaValue,
               )
             | None =>
               Literal(
                 {ltype: Types.urlType, data: Js.Json.string("")}: Types.lonaValue,
               )
             }
           | _ => JavaScriptLogic.logicValueToJavaScriptAST(config, value)
           };
         JSXAttribute({name: key, value: attributeValue});
       });
  let vectorAssignments = Layer.vectorAssignments(layer, logic);
  let attributes =
    [
      vectorAssignments
      |> List.map((vectorAssignment: Layer.vectorAssignment) =>
           JSXAttribute({
             name:
               vectorAssignment.elementName
               ++ (
                 vectorAssignment.paramKey
                 |> Layer.vectorParamKeyToString
                 |> Format.upperFirst
               ),
             value: Identifier(vectorAssignment.originalIdentifierPath),
           })
         ),
      attributes,
    ]
    |> List.concat;

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
             logic,
             assignments,
             getAssetPath,
             Some(layer),
           ),
         )
    };
  let element =
    createJSXElement(
      framework,
      parent,
      layer,
      attributes,
      styleAttribute,
      content,
    );
  switch (dynamicOrStaticValue(Visible)) {
  | Some(value) =>
    JSXExpressionContainer(
      BinaryExpression({
        left: JavaScriptLogic.logicValueToJavaScriptAST(config, value),
        operator: And,
        right: element,
      }),
    )
  | None => element
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
  let importsSvg = List.mem(Types.VectorGraphic, builtIn);
  let builtIn =
    builtIn |> List.filter(typeName => typeName != Types.VectorGraphic);
  {
    absolute:
      switch (framework) {
      | JavaScriptOptions.ReactDOM =>
        /* Ast.ImportDeclaration({
             source: "styled-components",
             specifiers: [
               ImportDefaultSpecifier("styled"),
               ImportSpecifier({imported: "ThemeProvider", local: None}),
             ],
           }), */
        []
      | _ =>
        (
          switch (framework, importsSvg) {
          | (JavaScriptOptions.ReactNative, true) => [
              Ast.ImportDeclaration({
                source: "react-native-svg",
                specifiers: [Ast.ImportDefaultSpecifier("Svg")],
              }),
            ]
          | _ => []
          }
        )
        @ [
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
              )
              @ (
                switch (framework, importsSvg) {
                | (JavaScriptOptions.ReactSketchapp, true) => [
                    Ast.ImportSpecifier({imported: "Svg", local: None}),
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
      logic,
      assignments,
      rootLayer,
    ) => {
  let astRootLayer =
    rootLayer
    |> layerToJavaScriptAST(
         options.framework,
         config,
         logic,
         assignments,
         getAssetPath,
         None,
       );

  switch (options.framework) {
  /* | ReactDOM =>
     JavaScriptAst.(
       JSXElement({
         tag: "ThemeProvider",
         attributes: [
           JSXAttribute({name: "theme", value: Identifier(["theme"])}),
         ],
         content: [astRootLayer],
       })
     ) */
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
      shadowsFilePath,
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
      logic,
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
              source: shadowsFilePath |> Js.String.replace(".json", ""),
              specifiers: [ImportDefaultSpecifier("shadows")],
            }),
            ImportDeclaration({
              source: textStylesFilePath |> Js.String.replace(".json", ""),
              specifiers: [ImportDefaultSpecifier("textStyles")],
            }),
          ]
          @ relative,
          rootLayer
          |> SwiftComponentParameter.allVectorAssets
          |> List.map(asset =>
               JavaScriptSvg.generateVectorGraphic(
                 config,
                 options,
                 SwiftComponentParameter.allVectorAssignments(
                   rootLayer,
                   logic,
                   asset,
                 ),
                 asset,
               )
             ),
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
                            /* | JavaScriptOptions.ReactDOM => [themeAST] */
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