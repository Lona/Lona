module Ast = JavaScriptAst;

module Render = JavaScriptRender;

let frameworkSpecificValue =
    (framework, container: Types.platformSpecificValue('a)) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => container.reactDom
  | JavaScriptOptions.ReactNative => container.reactNative
  | JavaScriptOptions.ReactSketchapp => container.reactSketchapp
  };

let getElementTagStringForLayerType =
    (options: JavaScriptOptions.options, typeName: Types.layerType) =>
  switch (options.framework) {
  | ReactDOM => ReactDomTranslators.layerTypeTags(typeName)
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

let getElementTagString =
    (options: JavaScriptOptions.options, layer: Types.layer) => {
  let override =
    frameworkSpecificValue(
      options.framework,
      layer.metadata.backingElementClass,
    );

  switch (layer.typeName) {
  | VectorGraphic =>
    Format.vectorClassName(
      SwiftComponentParameter.getVectorAssetUrl(layer),
      Some(layer.name),
    )
  | _ =>
    switch (options.styleFramework, override) {
    | (StyledComponents, _) => JavaScriptFormat.elementName(layer.name)
    | (None, Some(value)) => value
    | (None, None) =>
      getElementTagStringForLayerType(options, layer.typeName)
    }
  };
};

let getStyleVariables =
    (
      assignments: Layer.LayerMap.t(ParameterMap.t(Logic.logicValue)),
      layer: Types.layer,
    ) =>
  switch (Layer.LayerMap.find_opt(layer, assignments)) {
  | Some(map) =>
    map |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key))
  | None => ParameterMap.empty
  };

let getPropVariables =
    (
      assignments: Layer.LayerMap.t(ParameterMap.t(Logic.logicValue)),
      layer: Types.layer,
    ) =>
  switch (Layer.LayerMap.find_opt(layer, assignments)) {
  | Some(map) =>
    map |> ParameterMap.filter((key, _) => !Layer.parameterIsStyle(key))
  | None => ParameterMap.empty
  };

let removeSpecialProps =
    (
      options: JavaScriptOptions.options,
      layerType: Types.layerType,
      parameters: ParameterMap.t('a),
    ) =>
  parameters
  |> ParameterMap.filter((key: ParameterKey.t, _) =>
       switch (key, options.framework) {
       | (ParameterKey.OnAccessibilityActivate, _)
       | (ParameterKey.AccessibilityHint, _)
       | (ParameterKey.AccessibilityRole, _)
       | (ParameterKey.AccessibilityValue, _)
       | (ParameterKey.AccessibilityType, _)
       | (ParameterKey.AccessibilityElements, _) => false
       | (ParameterKey.NumberOfLines, JavaScriptOptions.ReactDOM) => false
       | (ParameterKey.Text, _) => false
       | (ParameterKey.Visible, _) => false
       | (ParameterKey.Image, _) when layerType == VectorGraphic => false
       | (_, _) => true
       }
     );

let imageNeedsWrapper = (parent: option(Types.layer), layer: Types.layer) =>
  if (layer.typeName == Types.Image) {
    let layout = Layer.getLayout(parent, layer.parameters);

    /* Images without fixed dimensions are absolute positioned within a wrapper */
    switch (layout.height, layout.width) {
    | (Fixed(_), Fixed(_)) => false
    | _ => true
    };
  } else {
    false;
  };

let customComponentNeedsWrapper =
    (
      options: JavaScriptOptions.options,
      parent: option(Types.layer),
      layer: Types.layer,
    ) =>
  switch (layer.typeName, parent) {
  | (Types.Component(_), Some(parent)) =>
    let parentDirection = Layer.getFlexDirection(parent.parameters);

    switch (options.framework, parentDirection) {
    | (JavaScriptOptions.ReactDOM, "column")
    | (JavaScriptOptions.ReactNative, "row")
    | (JavaScriptOptions.ReactSketchapp, "row") => true
    | _ => false
    };
  | _ => false
  };

let getInitialProps = (options: JavaScriptOptions.options, layer: Types.layer) =>
  layer.parameters
  |> removeSpecialProps(options, layer.typeName)
  |> Layer.parameterMapToLogicValueMap
  |> ParameterMap.filter((key, _) => !Layer.parameterIsStyle(key));

module StyledComponents = {
  /* let createStyleSetObjectProperties = viewVariableName =>
     JavaScriptAst.[
       SpreadElement(
         Identifier(["props", "theme", viewVariableName, "normal"]),
       ),
       Property({
         key: StringLiteral(":hover"),
         value: Identifier(["props", "theme", viewVariableName, "hovered"]),
       }),
     ]; */

  let createPropsFunction = contents =>
    JavaScriptAst.(
      ArrowFunctionExpression({
        id: None,
        params: ["props"],
        body: [Return(contents)],
      })
    );

  let layerStyledComponentAST =
      (
        config: Config.t,
        options: JavaScriptOptions.options,
        _assignments,
        rootLayer: Types.layer,
        layer: Types.layer,
      ) =>
    JavaScriptAst.(
      VariableDeclaration(
        AssignmentExpression({
          left:
            Identifier([
              switch (layer.typeName) {
              | Component(name) =>
                JavaScriptFormat.wrapperElementName(name, layer.name)
              | _ => JavaScriptFormat.elementName(layer.name)
              },
            ]),
          right:
            CallExpression({
              callee:
                Identifier([
                  "styled",
                  switch (layer.typeName) {
                  | Component(_) => ReactDomTranslators.layerTypeTags(View)
                  | _ =>
                    let override =
                      frameworkSpecificValue(
                        options.framework,
                        layer.metadata.backingElementClass,
                      );
                    let needsWrapper =
                      imageNeedsWrapper(
                        Layer.findParent(rootLayer, layer),
                        layer,
                      );
                    switch (override) {
                    | Some(value) => value
                    | None =>
                      if (needsWrapper) {
                        ReactDomTranslators.layerTypeTags(Types.View);
                      } else {
                        ReactDomTranslators.layerTypeTags(layer.typeName);
                      }
                    };
                  },
                ]),
              arguments: [
                JavaScriptStyles.Object.forLayer(
                  config,
                  options.framework,
                  Layer.findParent(rootLayer, layer),
                  layer,
                ),
              ],
            }),
        }),
      )
    );

  let imageResizingStyledComponentAst =
      (
        config: Config.t,
        options: JavaScriptOptions.options,
        resizeMode: string,
      ) =>
    JavaScriptAst.(
      VariableDeclaration(
        AssignmentExpression({
          left:
            Identifier([
              JavaScriptFormat.imageResizeModeHelperName(resizeMode)
              |> Format.upperFirst,
            ]),
          right:
            CallExpression({
              callee:
                Identifier([
                  "styled",
                  getElementTagStringForLayerType(options, Types.Image),
                ]),
              arguments: [
                JavaScriptStyles.Object.imageResizing(
                  config,
                  options.framework,
                  resizeMode,
                ),
              ],
            }),
        }),
      )
    );

  let createdAllStyledComponentsAST =
      (
        config: Config.t,
        options: JavaScriptOptions.options,
        assignments,
        rootLayer: Types.layer,
      ) => {
    let imageResizingComponents =
      rootLayer
      |> Layer.flatten
      |> List.filter(layer =>
           imageNeedsWrapper(Layer.findParent(rootLayer, layer), layer)
         )
      |> List.map((layer: Types.layer) =>
           switch (Layer.getStringParameterOpt(ResizeMode, layer.parameters)) {
           | Some(value) => value
           | None => "cover"
           }
         )
      |> Sequence.dedupeMem
      |> List.map(imageResizingStyledComponentAst(config, options));
    let layerComponents =
      rootLayer
      |> Layer.flatten
      /* Custom components don't need a styled-component generated unless they require
         a custom wrapper. All other layers need a styled-component */
      |> List.filter((layer: Types.layer) =>
           !Layer.isComponentLayer(layer)
           || customComponentNeedsWrapper(
                options,
                Layer.findParent(rootLayer, layer),
                layer,
              )
         )
      |> List.map(
           layerStyledComponentAST(config, options, assignments, rootLayer),
         );
    [imageResizingComponents, layerComponents]
    |> List.concat
    |> SwiftDocument.join(JavaScriptAst.Empty);
  };
};

let createDynamicStyleObjectAst =
    (
      config: Config.t,
      framework: JavaScriptOptions.framework,
      styles: ParameterMap.t(Logic.logicValue),
    ) =>
  if (styles |> ParameterMap.is_empty) {
    None;
  } else {
    Some(
      Ast.ObjectLiteral(
        styles
        |> Layer.mapBindings(((key, value)) =>
             JavaScriptStyles.createStyleAttributePropertyAST(
               framework,
               config,
               key,
               value,
             )
           ),
      ),
    );
  };

let createStyleObjectAst =
    (
      framework: JavaScriptOptions.framework,
      config: Config.t,
      layer: Types.layer,
      styles: ParameterMap.t(Logic.logicValue),
    ) => {
  let dynamicStyles = createDynamicStyleObjectAst(config, framework, styles);

  let staticStyles =
    Ast.Identifier([
      "styles",
      JavaScriptFormat.styleVariableName(layer.name),
    ]);

  switch (framework) {
  | JavaScriptOptions.ReactDOM =>
    switch (dynamicStyles) {
    | None => staticStyles
    | Some(dynamicStyles) =>
      CallExpression({
        callee: Identifier(["Object", "assign"]),
        arguments: [ObjectLiteral([]), staticStyles, dynamicStyles],
      })
    }
  | _ =>
    switch (dynamicStyles) {
    | None => staticStyles
    | Some(dynamicStyles) => ArrayLiteral([staticStyles, dynamicStyles])
    }
  };
};

let createWrappedImageElement =
    (
      _config,
      options: JavaScriptOptions.options,
      layer: Types.layer,
      styleAttribute,
      jsxAttributes,
      jsxChildren,
    ) => {
  let resizeMode =
    switch (Layer.getStringParameterOpt(ResizeMode, layer.parameters)) {
    | Some(value) => value
    | None => "cover"
    };

  let imageStyleAttribute =
    switch (options.styleFramework) {
    | StyledComponents => []
    | None => [
        Ast.JSXAttribute({
          name: "style",
          value:
            Identifier([
              "styles",
              JavaScriptFormat.imageResizeModeHelperName(resizeMode),
            ]),
        }),
      ]
    };

  let wrapperTagName =
    switch (options.styleFramework) {
    | StyledComponents => JavaScriptFormat.elementName(layer.name)
    | None => getElementTagStringForLayerType(options, Types.View)
    };

  let elementTagName =
    switch (options.styleFramework) {
    | StyledComponents =>
      JavaScriptFormat.imageResizeModeHelperName(resizeMode)
      |> Format.upperFirst
    | None => getElementTagString(options, layer)
    };

  JavaScriptAst.(
    JSXElement({
      tag: wrapperTagName,
      attributes: styleAttribute,
      content: [
        JSXElement({
          tag: elementTagName,
          attributes: imageStyleAttribute @ jsxAttributes,
          content: jsxChildren,
        }),
      ],
    })
  );
};

/* Wrap custom components in a view that enforces the framework's
   default layout attributes. */
let createJSXElement =
    (
      config: Config.t,
      options: JavaScriptOptions.options,
      parent: option(Types.layer),
      layer: Types.layer,
      attributes: list(JavaScriptAst.node),
      styleVariables: ParameterMap.t(Logic.logicValue),
      content: list(JavaScriptAst.node),
    )
    : JavaScriptAst.node => {
  let framework = options.framework;

  let styleAttribute =
    switch (options.styleFramework) {
    | StyledComponents =>
      let dynamicStylesObject =
        createDynamicStyleObjectAst(config, framework, styleVariables);

      switch (dynamicStylesObject) {
      | Some(styles) => [
          JavaScriptAst.JSXAttribute({name: "style", value: styles}),
        ]
      | None => []
      };
    | _ => [
        JavaScriptAst.JSXAttribute({
          name: "style",
          value:
            createStyleObjectAst(framework, config, layer, styleVariables),
        }),
      ]
    };

  switch (layer.typeName, parent) {
  | (Types.Component(name), Some(parent)) =>
    let parentDirection = Layer.getFlexDirection(parent.parameters);

    /* Custom components can't be passed styles, so don't include the style attribute */
    let customComponent =
      JavaScriptAst.JSXElement({
        tag: getElementTagStringForLayerType(options, layer.typeName),
        attributes,
        content,
      });

    if (customComponentNeedsWrapper(options, Some(parent), layer)) {
      if (options.styleFramework == StyledComponents) {
        JSXElement({
          tag: JavaScriptFormat.wrapperElementName(name, layer.name),
          attributes: styleAttribute,
          content: [customComponent],
        });
      } else {
        JSXElement({
          tag: getElementTagStringForLayerType(options, Types.View),
          attributes: styleAttribute,
          content: [customComponent],
        });
      };
    } else {
      customComponent;
    };
  | _ =>
    if (imageNeedsWrapper(parent, layer)) {
      createWrappedImageElement(
        config,
        options,
        layer,
        styleAttribute,
        attributes,
        content,
      );
    } else {
      JSXElement({
        tag: getElementTagString(options, layer),
        attributes: styleAttribute @ attributes,
        content,
      });
    }
  };
};

let rec layerToJavaScriptAST =
        (
          options: JavaScriptOptions.options,
          config: Config.t,
          logic,
          assignments,
          getAssetPath,
          parent: option(Types.layer),
          layer: Types.layer,
        ) => {
  open Ast;

  let initialProps = getInitialProps(options, layer);
  let styleVariables = getStyleVariables(assignments, layer);
  let propVariables = getPropVariables(assignments, layer);
  let needsRef = JavaScriptLayer.needsRef(layer);
  let canBeFocused = JavaScriptLayer.canBeFocused(layer);

  let main = ParameterMap.assign(initialProps, propVariables);
  let attributes =
    main
    |> removeSpecialProps(options, layer.typeName)
    |> Layer.mapBindings(((key, value)) => {
         let key =
           if (Layer.isPrimitiveTypeName(layer.typeName)) {
             ReactTranslators.variableNames(options.framework, key);
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
  let attributes =
    attributes
    @ (
      canBeFocused ?
        [
          JSXAttribute({
            name: "tabIndex",
            value: Literal(LonaValue.number(-1.)),
          }),
          JSXAttribute({
            name: "onKeyDown",
            value: Identifier(["this", "_handleKeyDown"]),
          }),
        ] :
        []
    );
  let attributes =
    attributes
    @ (
      needsRef ?
        [
          JSXAttribute({
            name: "ref",
            value:
              ArrowFunctionExpression({
                id: None,
                params: ["ref"],
                body: [
                  AssignmentExpression({
                    left:
                      Identifier([
                        "this",
                        "_" ++ JavaScriptFormat.elementName(layer.name),
                      ]),
                    right: Identifier(["ref"]),
                  }),
                ],
              }),
          }),
        ] :
        []
    );
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
      switch (
        layer.typeName,
        Layer.getStringParameterOpt(ResizeMode, layer.parameters),
      ) {
      | (VectorGraphic, Some(resizeMode)) => [
          JSXAttribute({
            name: "preserveAspectRatio",
            value:
              StringLiteral(
                switch (resizeMode) {
                | "contain" => "xMidYMid meet"
                | "cover"
                | _ => "xMidYMid slice"
                },
              ),
          }),
        ]
      | _ => []
      },
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
             options,
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
      config,
      options,
      parent,
      layer,
      attributes,
      styleVariables,
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
    (options: JavaScriptOptions.options, getComponentFile, rootLayer) => {
  let framework = options.framework;
  let {builtIn, custom}: Layer.availableTypeNames =
    rootLayer |> Layer.getTypeNames;
  let importsSvg = List.mem(Types.VectorGraphic, builtIn);
  let builtIn =
    builtIn |> List.filter(typeName => typeName != Types.VectorGraphic);
  {
    absolute:
      (
        switch (framework) {
        | JavaScriptOptions.ReactDOM => []
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
                @ [
                  Ast.ImportSpecifier({imported: "StyleSheet", local: None}),
                ]
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
        }
      )
      @ (
        switch (options.styleFramework) {
        | JavaScriptOptions.StyledComponents => [
            Ast.ImportDeclaration({
              source: "styled-components",
              specifiers: [
                ImportDefaultSpecifier("styled"),
                /* ImportSpecifier({imported: "ThemeProvider", local: None}), */
              ],
            }),
          ]
        | None => []
        }
      ),
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
         options,
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

let generateEnumType = (param: Types.parameter) =>
  switch (param.ltype) {
  | Named(typeName, Variant(cases)) =>
    Some(
      JavaScriptAst.(
        ExportNamedDeclaration(
          VariableDeclaration(
            AssignmentExpression({
              left: Identifier([JavaScriptFormat.enumName(typeName)]),
              right:
                ObjectLiteral(
                  cases
                  |> List.map((case: Types.lonaVariantCase) =>
                       JavaScriptAst.Property({
                         key:
                           Identifier([
                             JavaScriptFormat.enumCaseName(case.tag),
                           ]),
                         value: StringLiteral(case.tag),
                       })
                     ),
                ),
            }),
          ),
        )
      ),
    )
  | _ => None
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
  let parameters = json |> Decode.Component.parameters;
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);

  let themeAST =
    JavaScriptStyles.StyleSet.layerToThemeAST(
      config,
      options.framework,
      rootLayer,
    );

  let enumTypes =
    parameters
    |> List.map(generateEnumType)
    |> Sequence.compact
    |> SwiftDocument.join(Ast.Empty);

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
    JavaScriptStyles.StyleSheet.create(config, options.framework, rootLayer);

  let logicAST =
    logic
    |> defineInitialLogicValues(config, getComponent, rootLayer, assignments)
    |> JavaScriptLogic.toJavaScriptAST(options.framework, config)
    |> Ast.optimize;

  let {absolute, relative} =
    rootLayer |> importComponents(options, getComponentFile);

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
          |> Layer.vectorGraphicLayers
          |> List.map((layer: Types.layer) => {
               let asset = SwiftComponentParameter.getVectorAssetUrl(layer);
               JavaScriptSvg.generateVectorGraphic(
                 config,
                 options,
                 SwiftComponentParameter.allVectorAssignments(
                   rootLayer,
                   logic,
                   asset,
                 ),
                 asset,
                 Some(layer.name),
               );
             }),
          enumTypes,
          [
            ExportDefaultDeclaration(
              ClassDeclaration({
                id: componentName,
                superClass: Some("React.Component"),
                body:
                  (
                    options.framework == ReactDOM
                    && JavaScriptLayer.Hierarchy.needsFocusHandling(rootLayer) ?
                      JavaScriptFocus.focusMethods(rootLayer) : []
                  )
                  @ [
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
                  ]
                  |> Sequence.join(Empty),
              }),
            ),
          ],
          switch (options.styleFramework) {
          | JavaScriptOptions.StyledComponents =>
            StyledComponents.createdAllStyledComponentsAST(
              config,
              options,
              assignments,
              rootLayer,
            )
          | _ => [styleSheetAST]
          },
        ],
      ),
    )
  )
  /* Renames variables */
  |> Ast.prepareForRender;
};