module Parameter = SwiftComponentParameter;

type constraintDefinition = {
  variableName: string,
  initialValue: SwiftAst.node,
  priority: Constraint.layoutPriority,
};

module Naming = {
  let layerType =
      (
        config: Config.t,
        pluginContext: Plugin.context,
        swiftOptions: SwiftOptions.options,
        logic: Logic.logicNode,
        componentName: string,
        layer: Types.layer,
      ) => {
    let typeName =
      switch (swiftOptions.framework, layer.typeName) {
      | (UIKit, Types.View) =>
        if (Layer.isInteractive(logic, layer)) {
          "LonaControlView";
        } else {
          "UIView";
        }
      | (UIKit, Text) => "UILabel"
      | (UIKit, Image) => "BackgroundImageView"
      | (AppKit, Types.View) => "NSBox"
      | (AppKit, Text) => "LNATextField"
      | (AppKit, Image) => "LNAImageView"
      | (_, VectorGraphic) =>
        Format.vectorClassName(
          SwiftComponentParameter.getVectorAssetUrl(layer),
          None,
        )
      | (_, Component(name)) => name
      | _ => "TypeUnknown"
      };
    typeName
    |> Plugin.applyTransformTypePlugins(
         config.plugins,
         pluginContext,
         componentName,
       );
  };
};

/* Ast builders, specific to components */
module Doc = {
  open SwiftAst;

  /* required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     } */
  let coderInitializer = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), RequiredModifier],
      "parameters": [
        Parameter({
          "externalName": Some("coder"),
          "localName": "aDecoder",
          "annotation": TypeName("NSCoder"),
          "defaultValue": None,
        }),
      ],
      "failable": Some("?"),
      "throws": false,
      "body": [
        FunctionCallExpression({
          "name": SwiftIdentifier("fatalError"),
          "arguments": [
            FunctionCallArgument({
              "name": None,
              "value":
                SwiftIdentifier("\"init(coder:) has not been implemented\""),
            }),
          ],
        }),
      ],
    });

  let pressableVariables = (rootLayer: Types.layer, layer: Types.layer) => [
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "hovered"),
      None,
      Some(LiteralExpression(Boolean(false))),
    ),
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "pressed"),
      None,
      Some(LiteralExpression(Boolean(false))),
    ),
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "onPress"),
      Some(OptionalType(TypeName("(() -> Void)"))),
      None,
    ),
  ];

  let tapVariables = (rootLayer: Types.layer, layer: Types.layer) => [
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "onPress") /* onTap */,
      Some(OptionalType(TypeName("(() -> Void)"))),
      None,
    ),
  ];

  let interactiveVariables =
      (
        framework: SwiftOptions.framework,
        rootLayer: Types.layer,
        layer: Types.layer,
      ) => [
    switch (framework) {
    | UIKit => tapVariables(rootLayer, layer)
    | AppKit => pressableVariables(rootLayer, layer)
    },
  ];

  let tapHandler = (rootLayer: Types.layer, layer: Types.layer) => [
    FunctionDeclaration({
      "name":
        "handleTap" ++ Format.upperFirst(SwiftFormat.layerName(layer.name)),
      "attributes": ["@objc"],
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body": [
        SwiftAst.Builders.functionCall(
          [
            SwiftFormat.layerVariableName(rootLayer, layer, "onPress?") /* onTap */,
          ],
          [],
        ),
      ],
    }),
  ];

  let parameterVariable =
      (swiftOptions: SwiftOptions.options, parameter: Types.parameter) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(parameter.name |> ParameterKey.toString),
          "annotation":
            Some(
              parameter.ltype
              |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework),
            ),
        }),
      "init": None,
      "block":
        Some(
          WillSetDidSetBlock({
            "willSet": None,
            "didSet":
              Some([SwiftAst.Builders.functionCall(["update"], [])]),
          }),
        ),
    });

  let viewVariableInitialValue =
      (
        swiftOptions: SwiftOptions.options,
        assignmentsFromLayerParameters,
        layer: Types.layer,
        typeName: string,
      ) => {
    let typeName = SwiftIdentifier(typeName);
    switch (swiftOptions.framework, layer.typeName) {
    | (UIKit, Types.View)
    | (UIKit, Image) =>
      FunctionCallExpression({
        "name": typeName,
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("frame")),
            "value": SwiftIdentifier(".zero"),
          }),
        ],
      })
    | (AppKit, Text) =>
      FunctionCallExpression({
        "name": typeName,
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("labelWithString")),
            "value": LiteralExpression(String("")),
          }),
        ],
      })
    | (AppKit, Image) =>
      let hasBackground =
        Parameter.isAssigned(
          assignmentsFromLayerParameters,
          layer,
          BackgroundColor,
        );
      FunctionCallExpression({
        "name":
          hasBackground ?
            SwiftIdentifier("ImageWithBackgroundColor") : typeName,
        "arguments": [],
      });
    | _ => FunctionCallExpression({"name": typeName, "arguments": []})
    };
  };

  let initializerParameter =
      (swiftOptions: SwiftOptions.options, parameter: Decode.parameter) =>
    Parameter({
      "externalName": None,
      "localName": parameter.name |> ParameterKey.toString,
      "annotation":
        parameter.ltype
        |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework),
      "defaultValue": None,
    });

  let defineInitialLayerValue =
      (
        swiftOptions: SwiftOptions.options,
        config: Config.t,
        getComponent,
        assignmentsFromLayerParameters,
        rootLayer: Types.layer,
        layer: Types.layer,
        (name, _),
      ) => {
    let parameters =
      Layer.LayerMap.find_opt(layer, assignmentsFromLayerParameters);
    switch (parameters) {
    | None => SwiftAst.LineComment(layer.name)
    | Some(parameters) =>
      let assignment = ParameterMap.find_opt(name, parameters);
      let parameterValue = Parameter.get(layer, name);
      let logic =
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
      let node =
        SwiftLogic.toSwiftAST(swiftOptions, config, rootLayer, logic);
      StatementListHelper(node);
    };
  };

  let setUpViews =
      (
        swiftOptions: SwiftOptions.options,
        config: Config.t,
        getComponent,
        logic,
        assignmentsFromLayerParameters,
        assignmentsFromLogic,
        layerMemberExpression,
        rootLayer: Types.layer,
      ) => {
    let setUpDefaultsDoc = () => {
      let filterParameters = ((name, _)) =>
        name != ParameterKey.FlexDirection
        && name != JustifyContent
        && name != AlignSelf
        && name != AlignItems
        && name != Flex
        && name != PaddingTop
        && name != PaddingRight
        && name != PaddingBottom
        && name != PaddingLeft
        && name != MarginTop
        && name != MarginRight
        && name != MarginBottom
        && name != MarginLeft
        /* Handled by initial constraint setup */
        && name != Height
        && name != Width
        && name != TextAlign;
      let filterNotAssignedByLogic = (layer: Types.layer, (parameterName, _)) =>
        switch (Layer.LayerMap.find_opt(layer, assignmentsFromLogic)) {
        | None => true
        | Some(parameters) =>
          switch (ParameterMap.find_opt(parameterName, parameters)) {
          | None => true
          | Some(_) => false
          }
        };
      let defineInitialLayerValues = (layer: Types.layer) =>
        layer.parameters
        |> ParameterMap.bindings
        |> List.filter(((k, _)) =>
             !(Layer.isVectorGraphicLayer(layer) && k == ParameterKey.Image)
           )
        |> List.filter(filterParameters)
        |> List.filter(filterNotAssignedByLogic(layer))
        |> List.map(((k, v)) =>
             defineInitialLayerValue(
               swiftOptions,
               config,
               getComponent,
               assignmentsFromLayerParameters,
               rootLayer,
               layer,
               (k, v),
             )
           );
      rootLayer
      |> Layer.flatten
      |> List.map(defineInitialLayerValues)
      |> List.concat;
    };
    let resetViewStyling = (layer: Types.layer) =>
      switch (swiftOptions.framework, layer.typeName) {
      | (SwiftOptions.AppKit, View)
      | (SwiftOptions.AppKit, VectorGraphic) => [
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("boxType")]),
            "operator": "=",
            "right": SwiftIdentifier(".custom"),
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("borderType")]),
            "operator": "=",
            "right":
              Parameter.isUsed(
                assignmentsFromLayerParameters,
                layer,
                BorderWidth,
              ) ?
                SwiftIdentifier(".lineBorder") : SwiftIdentifier(".noBorder"),
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(
                layer,
                [SwiftIdentifier("contentViewMargins")],
              ),
            "operator": "=",
            "right": SwiftIdentifier(".zero"),
          }),
        ]
      | (SwiftOptions.AppKit, Text) => [
          BinaryExpression({
            "left":
              layerMemberExpression(
                layer,
                [SwiftIdentifier("lineBreakMode")],
              ),
            "operator": "=",
            "right": SwiftIdentifier(".byWordWrapping"),
          }),
        ]
      | (SwiftOptions.UIKit, Text) =>
        [
          Parameter.isSetInitially(layer, NumberOfLines) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    layer,
                    [SwiftIdentifier("numberOfLines")],
                  ),
                "operator": "=",
                "right": LiteralExpression(Integer(0)),
              }),
            ],
        ]
        |> List.concat
      | (SwiftOptions.UIKit, Image) =>
        [
          Parameter.isSetInitially(layer, ResizeMode) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    layer,
                    [SwiftIdentifier("contentMode")],
                  ),
                "operator": "=",
                "right":
                  SwiftIdentifier(
                    "." ++ SwiftDocument.resizeModeValue("cover"),
                  ),
              }),
            ],
          [
            BinaryExpression({
              "left":
                layerMemberExpression(
                  layer,
                  [
                    SwiftIdentifier("layer"),
                    SwiftIdentifier("masksToBounds"),
                  ],
                ),
              "operator": "=",
              "right": LiteralExpression(Boolean(true)),
            }),
          ],
        ]
        |> List.concat
      | (SwiftOptions.UIKit, VectorGraphic) =>
        [
          Parameter.isSetInitially(layer, BackgroundColor) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    layer,
                    [SwiftIdentifier("isOpaque")],
                  ),
                "operator": "=",
                "right": LiteralExpression(Boolean(false)),
              }),
            ],
        ]
        |> List.concat
      | _ => []
      };
    let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
      switch (parent) {
      | None => []
      | Some(parent) => [
          FunctionCallExpression({
            "name":
              layerMemberExpression(
                parent,
                [SwiftIdentifier("addSubview")],
              ),
            "arguments": [
              SwiftIdentifier(layer.name |> SwiftFormat.layerName),
            ],
          }),
        ]
      };
    let addInteractionHandlers = (layer: Types.layer) => [
      FunctionCallExpression({
        "name":
          layerMemberExpression(layer, [SwiftIdentifier("addTarget")]),
        "arguments": [
          FunctionCallArgument({
            "name": None,
            "value": SwiftIdentifier("self"),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("action")),
            "value":
              SwiftAst.Builders.functionCall(
                ["#selector"],
                [
                  (
                    None,
                    [
                      "handleTap"
                      ++ Format.upperFirst(SwiftFormat.layerName(layer.name)),
                    ],
                  ),
                ],
              ),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("for")),
            "value": SwiftIdentifier(".touchUpInside"),
          }),
        ],
      }),
      BinaryExpression({
        "left":
          layerMemberExpression(layer, [SwiftIdentifier("onHighlight")]),
        "operator": "=",
        "right": SwiftIdentifier("update"),
      }),
    ];
    FunctionDeclaration({
      "name": "setUpViews",
      "attributes": [],
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            Layer.flatmap(resetViewStyling, rootLayer) |> List.concat,
            Layer.flatmapParent(addSubviews, rootLayer) |> List.concat,
            setUpDefaultsDoc(),
            switch (swiftOptions.framework) {
            | UIKit =>
              rootLayer
              |> Layer.flatten
              |> List.filter(Layer.isInteractive(logic))
              |> List.map(addInteractionHandlers)
              |> List.concat
            | AppKit => []
            },
          ],
        ),
    });
  };

  let update =
      (
        swiftOptions: SwiftOptions.options,
        config: Config.t,
        getComponent,
        assignmentsFromLayerParameters,
        assignmentsFromLogic,
        hasConditionalConstraints: bool,
        rootLayer: Types.layer,
        logic,
      ) => {
    let conditionallyAssigned = Logic.conditionallyAssignedIdentifiers(logic);

    let isConditionallyAssigned = (layer: Types.layer, (key, _)) =>
      conditionallyAssigned
      |> Logic.IdentifierSet.exists(((_, value)) =>
           value == ["layers", layer.name, key |> ParameterKey.toString]
         );

    let defineInitialLayerValues = ((layer, propertyMap)) =>
      propertyMap
      |> ParameterMap.bindings
      |> List.filter(((key, _)) =>
           !SwiftComponentParameter.isPaddingOrMargin(key)
         )
      |> List.filter(isConditionallyAssigned(layer))
      |> List.map(
           defineInitialLayerValue(
             swiftOptions,
             config,
             getComponent,
             assignmentsFromLayerParameters,
             rootLayer,
             layer,
           ),
         );

    let body =
      (
        assignmentsFromLogic
        |> Layer.LayerMap.bindings
        |> List.map(defineInitialLayerValues)
        |> List.concat
      )
      @ SwiftLogic.toSwiftAST(swiftOptions, config, rootLayer, logic);

    let body =
      if (hasConditionalConstraints) {
        SwiftDocument.join(
          Empty,
          [
            FunctionCallExpression({
              "name":
                SwiftAst.Builders.memberExpression([
                  "NSLayoutConstraint",
                  "deactivate",
                ]),
              "arguments": [
                FunctionCallArgument({
                  "name": None,
                  "value":
                    SwiftAst.Builders.functionCall(
                      ["conditionalConstraints"],
                      [],
                    ),
                }),
              ],
            }),
          ]
          @ body
          @ [
            FunctionCallExpression({
              "name":
                SwiftAst.Builders.memberExpression([
                  "NSLayoutConstraint",
                  "activate",
                ]),
              "arguments": [
                FunctionCallArgument({
                  "name": None,
                  "value":
                    SwiftAst.Builders.functionCall(
                      ["conditionalConstraints"],
                      [],
                    ),
                }),
              ],
            }),
          ],
        );
      } else {
        body;
      };

    let initializeVectorLayers =
      Layer.flatten(rootLayer)
      |> List.filter(Layer.isVectorGraphicLayer)
      |> List.map((layer: Types.layer) => {
           let layerName = SwiftFormat.layerName(layer.name);
           let vectorAssignments = Layer.vectorAssignments(layer, logic);
           let svg =
             Config.Find.svg(
               config,
               SwiftComponentParameter.getVectorAssetUrl(layer),
             );

           vectorAssignments
           |> List.map((vectorAssignment: Layer.vectorAssignment) => {
                let initialValue =
                  switch (
                    Svg.find(svg, vectorAssignment.elementName),
                    vectorAssignment.paramKey,
                  ) {
                  | (Some(Path(_, params)), Fill) =>
                    switch (params.style.fill) {
                    | Some(fill) => Some(LiteralExpression(Color(fill)))
                    | None => Some(LiteralExpression(Color("transparent")))
                    }
                  | (Some(Path(_, params)), Stroke) =>
                    switch (params.style.stroke) {
                    | Some(stroke) =>
                      Some(LiteralExpression(Color(stroke)))
                    | None => Some(LiteralExpression(Color("transparent")))
                    }
                  | (Some(_), _) => None
                  | (None, _) => None
                  };

                switch (initialValue) {
                | None => Empty /* Shouldn't happen */
                | Some(initialValue) =>
                  BinaryExpression({
                    "left":
                      SwiftAst.Builders.memberExpression([
                        layerName,
                        SwiftFormat.vectorVariableName(vectorAssignment),
                      ]),
                    "operator": "=",
                    "right": initialValue,
                  })
                };
              });
         })
      |> List.concat;

    let displayVectorLayers =
      Layer.flatten(rootLayer)
      |> List.filter(Layer.isVectorGraphicLayer)
      |> List.map((layer: Types.layer) => {
           let layerName = SwiftFormat.layerName(layer.name);
           switch (swiftOptions.framework) {
           | UIKit =>
             SwiftAst.Builders.functionCall(
               [layerName, "setNeedsDisplay"],
               [],
             )
           | AppKit =>
             BinaryExpression({
               "left":
                 SwiftAst.Builders.memberExpression([
                   layerName,
                   "needsDisplay",
                 ]),
               "operator": "=",
               "right": LiteralExpression(Boolean(true)),
             })
           };
         });

    let body = initializeVectorLayers @ body @ displayVectorLayers;

    FunctionDeclaration({
      "name": "update",
      "attributes": [],
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body": body,
    });
  };
};

let generate =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      name,
      getComponent,
      json,
    ) => {
  open SwiftAst;

  let rootLayer = json |> Decode.Component.rootLayer(getComponent);
  let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
  let logic = json |> Decode.Component.logic;

  let pluginContext: Plugin.context = {
    "target": "swift",
    "framework": SwiftOptions.frameworkToString(swiftOptions.framework),
  };

  let pressableLayers =
    rootLayer
    |> Layer.flatten
    |> List.filter(Logic.isLayerParameterAssigned(logic, "onPress"));
  let needsTracking =
    swiftOptions.framework == SwiftOptions.AppKit
    && List.length(pressableLayers) > 0;

  let assignmentsFromLayerParameters =
    Layer.logicAssignmentsFromLayerParameters(rootLayer);
  let assignmentsFromLogic =
    Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let parameters = json |> Decode.Component.parameters;

  let visibilityCombinations =
    Constraint.visibilityCombinations(
      getComponent,
      assignmentsFromLogic,
      rootLayer,
    );

  let conditionalConstraints =
    Constraint.conditionalConstraints(visibilityCombinations);

  let viewVariableDoc = (layer: Types.layer): node =>
    SwiftAst.Builders.privateVariableDeclaration(
      layer.name |> SwiftFormat.layerName,
      None,
      Some(
        Doc.viewVariableInitialValue(
          swiftOptions,
          assignmentsFromLayerParameters,
          layer,
          Naming.layerType(
            config,
            pluginContext,
            swiftOptions,
            logic,
            name,
            layer,
          ),
        ),
      ),
    );
  let textStyleVariableDoc = (layer: Types.layer) => {
    let id =
      Parameter.isSetInitially(layer, TextStyle) ?
        Layer.getStringParameter(TextStyle, layer.parameters) :
        config.textStylesFile.contents.defaultStyle.id;
    let value =
      Parameter.isSetInitially(layer, TextAlign) ?
        SwiftAst.Builders.functionCall(
          ["TextStyles", id, "with"],
          [
            (
              Some("alignment"),
              ["." ++ Layer.getStringParameter(TextAlign, layer.parameters)],
            ),
          ],
        ) :
        SwiftAst.Builders.memberExpression(["TextStyles", id]);
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.layerName(layer.name) ++ "TextStyle",
      None,
      Some(value),
    );
  };
  let constraintVariableDoc = variableName =>
    SwiftAst.Builders.privateVariableDeclaration(
      variableName,
      Some(OptionalType(TypeName("NSLayoutConstraint"))),
      None,
    );

  let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
    BinaryExpression({
      "left":
        SwiftAst.Builders.memberExpression([
          "self",
          parameter.name |> ParameterKey.toString,
        ]),
      "operator": "=",
      "right": SwiftIdentifier(parameter.name |> ParameterKey.toString),
    });

  let initializerDoc = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters":
        parameters
        |> List.filter(param => !Parameter.isFunction(param))
        |> List.map(Doc.initializerParameter(swiftOptions)),
      "failable": None,
      "throws": false,
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            parameters
            |> List.filter(param => !Parameter.isFunction(param))
            |> List.map(initParameterAssignmentDoc),
            [
              SwiftAst.Builders.functionCall(
                ["super", "init"],
                [(Some("frame"), [".zero"])],
              ),
            ],
            [
              SwiftAst.Builders.functionCall(["setUpViews"], []),
              SwiftAst.Builders.functionCall(["setUpConstraints"], []),
            ],
            [SwiftAst.Builders.functionCall(["update"], [])],
            needsTracking ? [AppkitPressable.addTrackingArea] : [],
          ],
        ),
    });
  let convenienceInitializerDoc = () =>
    SwiftAst.Builders.convenienceInit([
      MemberExpression([
        SwiftIdentifier("self"),
        FunctionCallExpression({
          "name": SwiftIdentifier("init"),
          "arguments":
            parameters
            |> List.filter(param => !Parameter.isFunction(param))
            |> List.map((param: Decode.parameter) =>
                 FunctionCallArgument({
                   "name":
                     Some(
                       SwiftIdentifier(param.name |> ParameterKey.toString),
                     ),
                   "value":
                     SwiftDocument.defaultValueForLonaType(
                       swiftOptions.framework,
                       config,
                       param.ltype,
                     ),
                 })
               ),
        }),
      ]),
    ]);
  let memberOrSelfExpression = (firstIdentifier, statements) =>
    switch (firstIdentifier) {
    | "self" => MemberExpression(statements)
    | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
    };
  let parentNameOrSelf = (parent: Types.layer) =>
    Layer.equal(parent, rootLayer) ?
      "self" : parent.name |> SwiftFormat.layerName;
  let layerMemberExpression = (layer: Types.layer, statements) =>
    memberOrSelfExpression(parentNameOrSelf(layer), statements);

  let containsImageWithBackgroundColor = () => {
    let hasBackgroundColor = (layer: Types.layer) =>
      Parameter.isAssigned(
        assignmentsFromLayerParameters,
        layer,
        BackgroundColor,
      );
    nonRootLayers
    |> List.filter(Layer.isImageLayer)
    |> List.exists(hasBackgroundColor);
  };

  let helperClasses =
    [
      switch (swiftOptions.framework) {
      | SwiftOptions.AppKit =>
        containsImageWithBackgroundColor() ?
          [
            [LineComment("MARK: - " ++ "ImageWithBackgroundColor"), Empty],
            SwiftHelperClass.generateImageWithBackgroundColor(
              options,
              swiftOptions,
            ),
          ]
          |> List.concat :
          []
      | SwiftOptions.UIKit =>
        rootLayer |> Layer.flatten |> List.exists(Layer.isImageLayer) ?
          [
            [LineComment("MARK: - " ++ "BackgroundImageView"), Empty],
            SwiftHelperClass.generateBackgroundImage(options, swiftOptions),
          ]
          |> List.concat :
          []
      },
      rootLayer
      |> SwiftComponentParameter.allVectorAssets
      |> List.map(asset =>
           SwiftHelperClass.generateVectorGraphic(
             config,
             options,
             swiftOptions,
             SwiftComponentParameter.allVectorAssignments(
               rootLayer,
               logic,
               asset,
             ),
             asset,
           )
         )
      |> List.concat,
    ]
    |> List.concat;

  let superclass =
    TypeName(
      Plugin.applyTransformTypePlugins(
        config.plugins,
        pluginContext,
        name,
        switch (
          swiftOptions.framework,
          Layer.isInteractive(logic, rootLayer),
        ) {
        | (UIKit, true) => "LonaControlView"
        | (UIKit, false) => "UIView"
        | (AppKit, _) => "NSBox"
        },
      ),
    );
  TopLevelDeclaration({
    "statements":
      SwiftDocument.joinGroups(
        Empty,
        [
          [
            SwiftDocument.importFramework(swiftOptions.framework),
            ImportDeclaration("Foundation"),
          ],
          helperClasses,
          [LineComment("MARK: - " ++ name)],
          [
            ClassDeclaration({
              "name": name,
              "inherits": [superclass],
              "modifier": Some(PublicModifier),
              "isFinal": false,
              "body":
                SwiftDocument.joinGroups(
                  Empty,
                  [
                    [Empty, LineComment("MARK: Lifecycle")],
                    [initializerDoc()],
                    parameters
                    |> List.filter(param => !Parameter.isFunction(param))
                    |> List.length > 0 ?
                      [convenienceInitializerDoc()] : [],
                    [Doc.coderInitializer()],
                    needsTracking ? [AppkitPressable.deinitTrackingArea] : [],
                    List.length(parameters) > 0 ?
                      [LineComment("MARK: Public")] : [],
                    parameters
                    |> List.map(Doc.parameterVariable(swiftOptions)),
                    [LineComment("MARK: Private")],
                    needsTracking ? [AppkitPressable.trackingAreaVar] : [],
                    nonRootLayers |> List.map(viewVariableDoc),
                    nonRootLayers
                    |> List.filter(Layer.isTextLayer)
                    |> List.map(textStyleVariableDoc),
                    pressableLayers
                    |> List.map(
                         Doc.interactiveVariables(
                           swiftOptions.framework,
                           rootLayer,
                         ),
                       )
                    |> List.concat
                    |> List.concat,
                    Constraint.conditionalConstraints(visibilityCombinations)
                    @ (
                      Constraint.alwaysConstraints(visibilityCombinations)
                      |> List.filter(const =>
                           SwiftConstraint.isDynamic(
                             assignmentsFromLogic,
                             const,
                           )
                         )
                    )
                    |> List.map(const =>
                         constraintVariableDoc(
                           SwiftConstraint.formatConstraintVariableName(
                             visibilityCombinations,
                             rootLayer,
                             const,
                           ),
                         )
                       ),
                    [
                      Doc.setUpViews(
                        swiftOptions,
                        config,
                        getComponent,
                        logic,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
                        layerMemberExpression,
                        rootLayer,
                      ),
                    ],
                    [
                      SwiftConstraint.setUpFunction(
                        swiftOptions,
                        config,
                        getComponent,
                        assignmentsFromLogic,
                        layerMemberExpression,
                        rootLayer,
                      ),
                    ],
                    List.length(conditionalConstraints) > 0 ?
                      [
                        SwiftConstraint.conditionalConstraintsFunction(
                          getComponent,
                          assignmentsFromLogic,
                          rootLayer,
                        ),
                      ] :
                      [],
                    [
                      Doc.update(
                        swiftOptions,
                        config,
                        getComponent,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
                        List.length(conditionalConstraints) > 0,
                        rootLayer,
                        logic,
                      ),
                    ],
                    needsTracking ?
                      AppkitPressable.mouseTrackingFunctions(
                        rootLayer,
                        pressableLayers,
                      ) :
                      [],
                    swiftOptions.framework == UIKit ?
                      rootLayer
                      |> Layer.flatten
                      |> List.filter(Layer.isInteractive(logic))
                      |> List.map(Doc.tapHandler(rootLayer))
                      |> List.concat :
                      [],
                  ],
                ),
            }),
          ],
        ],
      ),
  });
};