module Parameter = SwiftComponentParameter;

type constraintDefinition = {
  variableName: string,
  initialValue: SwiftAst.node,
  priority: Constraint.layoutPriority,
};

let frameworkSpecificValue =
    (framework, container: Types.platformSpecificValue('a)) =>
  switch (framework) {
  | SwiftOptions.UIKit => container.iOS
  | SwiftOptions.AppKit => container.macOS
  };

module Naming = {
  let layerType =
      (
        config: Config.t,
        swiftOptions: SwiftOptions.options,
        logic: Logic.logicNode,
        componentName: string,
        useEventIgnoringLayer: bool,
        layer: Types.layer,
      ) => {
    let override =
      frameworkSpecificValue(
        swiftOptions.framework,
        layer.metadata.backingElementClass,
      );

    let typeName =
      switch (override) {
      | Some(value) => value
      | None =>
        switch (swiftOptions.framework, layer.typeName) {
        | (UIKit, Types.View) =>
          if (Layer.isInteractive(logic, layer)) {
            "LonaControlView";
          } else if (useEventIgnoringLayer) {
            "EventIgnoringView";
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
        }
      };

    typeName |> SwiftPlugin.applyTransformType(config, Some(componentName));
  };
};

/* Ast builders, specific to components */
module Doc = {
  open SwiftAst;

  let layerNameOrSelf = (rootLayer: Types.layer, layer: Types.layer) =>
    Layer.equal(layer, rootLayer) ?
      "self" : layer.name |> SwiftFormat.layerName;

  let layerMemberExpression =
      (rootLayer: Types.layer, layer: Types.layer, statements) =>
    SwiftAst.Builders.memberOrSelfExpression(
      layerNameOrSelf(rootLayer, layer),
      statements,
    );

  let fileLocalType =
      (
        swiftOptions: SwiftOptions.options,
        componentName: string,
        param: Types.parameter,
      )
      : option(list(node)) =>
    Monad.(
      param.ltype
      |> UserTypes.TypeSystem.toTypeSystem
      >>= (
        entity => {
          let convertedEntity =
            SwiftTypeSystem.Build.entity(
              {nativeTypeNames: [], swiftOptions},
              entity,
            );
          switch (convertedEntity.name) {
          | Some(name) =>
            Some([
              LineComment("MARK: - " ++ name),
              Empty,
              ExtensionDeclaration({
                "name": componentName,
                "protocols": [],
                "where": None,
                "modifier": None,
                "body": [convertedEntity.node],
              }),
            ])
          | None => None
          };
        }
      )
    );

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

  let nestedInteractiveHitTest = (rootLayer: Types.layer) => [
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("isRootControlTrackingEnabled"),
          "annotation": None,
        }),
      "init": Some(LiteralExpression(Boolean(true))),
      "block": None,
    }),
    Empty,
    FunctionDeclaration({
      "name": "hitTest",
      "attributes": [],
      "modifiers": [OverrideModifier, AccessLevelModifier(PublicModifier)],
      "parameters": [
        Parameter({
          "externalName": Some("_"),
          "localName": "point",
          "annotation": TypeName("CGPoint"),
          "defaultValue": None,
        }),
        Parameter({
          "externalName": Some("with"),
          "localName": "event",
          "annotation": TypeName("UIEvent?"),
          "defaultValue": None,
        }),
      ],
      "result": Some(TypeName("UIView?")),
      "throws": false,
      "body": [
        ConstantDeclaration({
          "modifiers": [],
          "init":
            Some(
              Builders.functionCall(
                ["super", "hitTest"],
                [(None, ["point"]), (Some("with"), ["event"])],
              ),
            ),
          "pattern":
            IdentifierPattern({
              "identifier": SwiftIdentifier("result"),
              "annotation": None,
            }),
        }),
        IfStatement({
          "condition":
            BinaryExpression({
              "left":
                BinaryExpression({
                  "left": SwiftIdentifier("result"),
                  "operator": "==",
                  "right": SwiftIdentifier("self"),
                }),
              "operator": "&&",
              "right":
                PrefixExpression({
                  operator: "!",
                  expression: SwiftIdentifier("isRootControlTrackingEnabled"),
                }),
            }),
          "block": [ReturnStatement(Some(LiteralExpression(Nil)))],
        }),
        ReturnStatement(Some(SwiftIdentifier("result"))),
      ],
    }),
  ];

  let tapVariables = (rootLayer: Types.layer, layer: Types.layer) => [
    SwiftAst.Builders.privateVariableDeclaration(
      SwiftFormat.tapHandler(layer.name),
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

  let tapHandler = (layer: Types.layer) => [
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
          [SwiftFormat.tapHandler(layer.name) ++ "?"],
          [],
        ),
      ],
    }),
  ];

  /* We proxy function parameters so that we don't have to call update() when they change.

     We currently don't allow comparing functions for equality -- the Swift language doesn't
     support this. We could allow checking if an optional function is currently nil or not,
     but right now we don't. We would need to detect if that's ever done within logic and
     disable this proxy function optimization for the component.
     */
  let functionParameterProxy =
      (
        config: Config.t,
        swiftOptions: SwiftOptions.options,
        parameter: Types.parameter,
      ) => {
    let functionType =
      UserTypes.unwrapNamedType(
        Config.Type.resolve(config, parameter.ltype),
      );
    let functionParameters =
      switch (functionType) {
      | Function(functionParams, _) =>
        functionParams
        |> List.mapi((index, functionParam: Types.lonaFunctionParameter) =>
             Parameter({
               "externalName": Some(functionParam.label),
               "localName": "arg" ++ string_of_int(index),
               "annotation":
                 functionParam.ltype
                 |> SwiftDocument.typeAnnotationDoc(config),
               "defaultValue": None,
             })
           )
      | _ => []
      };
    let functionCallArguments =
      switch (functionType) {
      | Function(functionParams, _) =>
        functionParams
        |> List.mapi((index, _) =>
             FunctionCallArgument({
               "name": None,
               "value": SwiftIdentifier("arg" ++ string_of_int(index)),
             })
           )
      | _ => []
      };
    FunctionDeclaration({
      "name":
        "handle" ++ Format.upperFirst(parameter.name |> ParameterKey.toString),
      "attributes": [],
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": functionParameters,
      "result": None,
      "throws": false,
      "body": [
        FunctionCallExpression({
          "name":
            SwiftIdentifier((parameter.name |> ParameterKey.toString) ++ "?"),
          "arguments": functionCallArguments,
        }),
      ],
    });
  };

  let parameterVariable =
      (
        config: Config.t,
        swiftOptions: SwiftOptions.options,
        parameter: Types.parameter,
      ) => {
    let setter =
      if (Parameter.isEquatable(config, parameter)) {
        IfStatement({
          "condition":
            BinaryExpression({
              "left":
                SwiftAst.Builders.memberExpression([
                  "parameters",
                  parameter.name |> ParameterKey.toString,
                ]),
              "operator": "!=",
              "right": SwiftIdentifier("newValue"),
            }),
          "block": [
            BinaryExpression({
              "left":
                SwiftAst.Builders.memberExpression([
                  "parameters",
                  parameter.name |> ParameterKey.toString,
                ]),
              "operator": "=",
              "right": SwiftIdentifier("newValue"),
            }),
          ],
        });
      } else {
        BinaryExpression({
          "left":
            SwiftAst.Builders.memberExpression([
              "parameters",
              parameter.name |> ParameterKey.toString,
            ]),
          "operator": "=",
          "right": SwiftIdentifier("newValue"),
        });
      };

    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(parameter.name |> ParameterKey.toString),
          "annotation":
            Some(parameter.ltype |> SwiftDocument.typeAnnotationDoc(config)),
        }),
      "init": None,
      "block":
        Some(
          GetterSetterBlock({
            "get": [
              ReturnStatement(
                Some(
                  SwiftAst.Builders.memberExpression([
                    "parameters",
                    parameter.name |> ParameterKey.toString,
                  ]),
                ),
              ),
            ],
            "set": [setter],
          }),
        ),
    });
  };

  let parametersModelVariable = () =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("parameters"),
          "annotation": Some(TypeName("Parameters")),
        }),
      "init": None,
      "block":
        Some(
          WillSetDidSetBlock({
            "willSet": None,
            "didSet":
              Some([
                IfStatement({
                  "condition":
                    BinaryExpression({
                      "left": SwiftIdentifier("parameters"),
                      "operator": "!=",
                      "right": SwiftIdentifier("oldValue"),
                    }),
                  "block": [SwiftAst.Builders.functionCall(["update"], [])],
                }),
              ]),
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

  let initializerParameter = (config: Config.t, parameter: Decode.parameter) =>
    Parameter({
      "externalName": None,
      "localName": parameter.name |> ParameterKey.toString,
      "annotation":
        parameter.ltype |> SwiftDocument.typeAnnotationDoc(config),
      "defaultValue": None,
    });

  let defineInitialLayerValue =
      (
        swiftOptions: SwiftOptions.options,
        config: Config.t,
        componentParameters,
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
            Config.Find.component(config, componentName)
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
        SwiftLogic.toSwiftAST(
          swiftOptions,
          config,
          componentParameters,
          rootLayer,
          logic,
        );
      StatementListHelper(node);
    };
  };

  let setUpViews =
      (
        swiftOptions: SwiftOptions.options,
        config: Config.t,
        componentParameters,
        logic,
        assignmentsFromLayerParameters,
        assignmentsFromLogic,
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
               componentParameters,
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
              layerMemberExpression(
                rootLayer,
                layer,
                [SwiftIdentifier("boxType")],
              ),
            "operator": "=",
            "right": SwiftIdentifier(".custom"),
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(
                rootLayer,
                layer,
                [SwiftIdentifier("borderType")],
              ),
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
                rootLayer,
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
                rootLayer,
                layer,
                [SwiftIdentifier("lineBreakMode")],
              ),
            "operator": "=",
            "right": SwiftIdentifier(".byWordWrapping"),
          }),
        ]
      | (SwiftOptions.UIKit, Text) =>
        [
          [
            BinaryExpression({
              "left":
                layerMemberExpression(
                  rootLayer,
                  layer,
                  [SwiftIdentifier("isUserInteractionEnabled")],
                ),
              "operator": "=",
              "right": LiteralExpression(Boolean(false)),
            }),
          ],
          Parameter.isSetInitially(layer, NumberOfLines) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    rootLayer,
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
          [
            BinaryExpression({
              "left":
                layerMemberExpression(
                  rootLayer,
                  layer,
                  [SwiftIdentifier("isUserInteractionEnabled")],
                ),
              "operator": "=",
              "right": LiteralExpression(Boolean(false)),
            }),
          ],
          Parameter.isSetInitially(layer, ResizeMode) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    rootLayer,
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
                  rootLayer,
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
          [
            BinaryExpression({
              "left":
                layerMemberExpression(
                  rootLayer,
                  layer,
                  [SwiftIdentifier("isUserInteractionEnabled")],
                ),
              "operator": "=",
              "right": LiteralExpression(Boolean(false)),
            }),
          ],
          Parameter.isSetInitially(layer, BackgroundColor) ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    rootLayer,
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
                rootLayer,
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
          layerMemberExpression(
            rootLayer,
            layer,
            [SwiftIdentifier("addTarget")],
          ),
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
          layerMemberExpression(
            rootLayer,
            layer,
            [SwiftIdentifier("onHighlight")],
          ),
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
        componentParameters,
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
             componentParameters,
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
      @ SwiftLogic.toSwiftAST(
          swiftOptions,
          config,
          componentParameters,
          rootLayer,
          logic,
        );

    let body =
      if (hasConditionalConstraints) {
        let visibilityLayers =
          Constraint.visibilityLayers(assignmentsFromLogic, rootLayer)
          |> List.sort(Layer.compare);

        let initialViewVisibility =
          visibilityLayers
          |> List.map((layer: Types.layer) =>
               ConstantDeclaration({
                 "modifiers": [],
                 "init":
                   Some(
                     Builders.memberExpression([
                       SwiftFormat.layerName(layer.name),
                       "isHidden",
                     ]),
                   ),
                 "pattern":
                   IdentifierPattern({
                     "identifier":
                       SwiftIdentifier(
                         SwiftFormat.layerName(layer.name) ++ "IsHidden",
                       ),
                     "annotation": None,
                   }),
               })
             );

        let compareViewVisibility =
          SwiftDocument.binaryExpressionList(
            "||",
            visibilityLayers
            |> List.map((layer: Types.layer) =>
                 BinaryExpression({
                   "left":
                     Builders.memberExpression([
                       SwiftFormat.layerName(layer.name),
                       "isHidden",
                     ]),
                   "operator": "!=",
                   "right":
                     SwiftIdentifier(
                       SwiftFormat.layerName(layer.name) ++ "IsHidden",
                     ),
                 })
               ),
          );

        let deactivateConstraints =
          FunctionCallExpression({
            "name":
              SwiftAst.Builders.memberExpression([
                "NSLayoutConstraint",
                "deactivate",
              ]),
            "arguments": [
              FunctionCallExpression({
                "name": SwiftIdentifier("conditionalConstraints"),
                "arguments":
                  visibilityLayers
                  |> List.map((layer: Types.layer) =>
                       FunctionCallArgument({
                         "name":
                           Some(
                             SwiftIdentifier(
                               SwiftFormat.layerName(layer.name) ++ "IsHidden",
                             ),
                           ),
                         "value":
                           SwiftIdentifier(
                             SwiftFormat.layerName(layer.name) ++ "IsHidden",
                           ),
                       })
                     ),
              }),
            ],
          });

        let activateConstraints =
          FunctionCallExpression({
            "name":
              SwiftAst.Builders.memberExpression([
                "NSLayoutConstraint",
                "activate",
              ]),
            "arguments": [
              FunctionCallExpression({
                "name": SwiftIdentifier("conditionalConstraints"),
                "arguments":
                  visibilityLayers
                  |> List.map((layer: Types.layer) =>
                       FunctionCallArgument({
                         "name":
                           Some(
                             SwiftIdentifier(
                               SwiftFormat.layerName(layer.name) ++ "IsHidden",
                             ),
                           ),
                         "value":
                           Builders.memberExpression([
                             SwiftFormat.layerName(layer.name),
                             "isHidden",
                           ]),
                       })
                     ),
              }),
            ],
          });

        let updateAccessibilityContainers =
          rootLayer
          |> Layer.flatten
          |> List.map((layer: Types.layer) =>
               switch (Layer.accessibilityType(layer)) {
               | Container(elements)
                   when
                     List.exists(
                       element =>
                         List.exists(
                           (inner: Types.layer) => inner.name == element,
                           visibilityLayers,
                         ),
                       elements,
                     ) =>
                 Some(
                   BinaryExpression({
                     "left":
                       layerMemberExpression(
                         rootLayer,
                         layer,
                         [SwiftIdentifier("accessibilityElements")],
                       ),
                     "operator": "=",
                     "right":
                       FunctionCallExpression({
                         "name":
                           MemberExpression([
                             LiteralExpression(
                               Array(
                                 elements
                                 |> List.map(name =>
                                      SwiftIdentifier(
                                        SwiftFormat.layerName(name),
                                      )
                                    ),
                               ),
                             ),
                             SwiftIdentifier("filter"),
                           ]),
                         "arguments": [
                           FunctionCallArgument({
                             "name": None,
                             "value":
                               CodeBlock({
                                 "statements": [
                                   PrefixExpression({
                                     "operator": "!",
                                     "expression":
                                       Builders.memberExpression([
                                         "$0",
                                         "isHidden",
                                       ]),
                                   }),
                                 ],
                               }),
                           }),
                         ],
                       }),
                   }),
                 )
               | _ => None
               }
             )
          |> Sequence.compact;

        let updateVisibility =
          IfStatement({
            "condition": compareViewVisibility,
            "block": [
              deactivateConstraints,
              activateConstraints,
              ...updateAccessibilityContainers,
            ],
          });

        SwiftDocument.joinGroups(
          Empty,
          [initialViewVisibility, body, [updateVisibility]],
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

  let initParameterAssignment = (parameter: Decode.parameter) =>
    BinaryExpression({
      "left":
        SwiftAst.Builders.memberExpression([
          "self",
          parameter.name |> ParameterKey.toString,
        ]),
      "operator": "=",
      "right": SwiftIdentifier(parameter.name |> ParameterKey.toString),
    });

  let initIndividualParameters = (config, parameters) =>
    InitializerDeclaration({
      "modifiers": [
        AccessLevelModifier(PublicModifier),
        ConvenienceModifier,
      ],
      "parameters":
        parameters
        |> List.filter(param => !Parameter.isFunction(config, param))
        |> List.map(initializerParameter(config)),
      "failable": None,
      "throws": false,
      "body": [
        MemberExpression([
          SwiftIdentifier("self"),
          FunctionCallExpression({
            "name": SwiftIdentifier("init"),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value":
                  FunctionCallExpression({
                    "name": SwiftIdentifier("Parameters"),
                    "arguments":
                      parameters
                      |> List.filter(param =>
                           !Parameter.isFunction(config, param)
                         )
                      |> List.map((param: Decode.parameter) =>
                           FunctionCallArgument({
                             "name":
                               Some(
                                 SwiftIdentifier(
                                   param.name |> ParameterKey.toString,
                                 ),
                               ),
                             "value":
                               SwiftIdentifier(
                                 param.name |> ParameterKey.toString,
                               ),
                           })
                         ),
                  }),
              }),
            ],
          }),
        ]),
      ],
    });

  let init = (_config, _swiftOptions, parameters, needsTracking) =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": [
        Parameter({
          "externalName": Some("_"),
          "localName": "parameters",
          "defaultValue": None,
          "annotation": TypeName("Parameters"),
        }),
      ],
      "failable": None,
      "throws": false,
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            [
              SwiftAst.BinaryExpression({
                "left":
                  SwiftAst.Builders.memberExpression(["self", "parameters"]),
                "operator": "=",
                "right": SwiftIdentifier("parameters"),
              }),
            ],
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

  let coderInitializer = needsTracking =>
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
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            [
              SwiftAst.BinaryExpression({
                "left":
                  SwiftAst.Builders.memberExpression(["self", "parameters"]),
                "operator": "=",
                "right": SwiftAst.Builders.functionCall(["Parameters"], []),
              }),
            ],
            [
              SwiftAst.Builders.functionCall(
                ["super", "init"],
                [(Some("coder"), ["aDecoder"])],
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

  let convenienceInit = () =>
    SwiftAst.Builders.convenienceInit([
      MemberExpression([
        SwiftIdentifier("self"),
        FunctionCallExpression({
          "name": SwiftIdentifier("init"),
          "arguments": [
            FunctionCallArgument({
              "name": None,
              "value":
                FunctionCallExpression({
                  "name": SwiftIdentifier("Parameters"),
                  "arguments": [],
                }),
            }),
          ],
        }),
      ]),
    ]);
};

let generate =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      name,
      json,
    ) => {
  open SwiftAst;

  let rootLayer = json |> Decode.Component.rootLayer(config);
  let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
  let logic = json |> Decode.Component.logic;

  let pressableLayers =
    rootLayer |> Layer.flatten |> List.filter(Layer.isInteractive(logic));
  let needsTracking =
    swiftOptions.framework == SwiftOptions.AppKit
    && List.length(pressableLayers) > 0;
  let containsNoninteractiveDescendants =
    Layer.containsNoninteractiveDescendants(logic, rootLayer);

  let assignmentsFromLayerParameters =
    Layer.logicAssignmentsFromLayerParameters(rootLayer);
  let assignmentsFromLogic =
    Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let parameters = json |> Decode.Component.parameters;

  let visibilityCombinations =
    Constraint.visibilityCombinations(
      config,
      assignmentsFromLogic,
      rootLayer,
    );

  let conditionalConstraints =
    Constraint.conditionalConstraints(visibilityCombinations);

  let viewVariableDoc = (layer: Types.layer): node => {
    let modifiers =
      switch (
        frameworkSpecificValue(
          swiftOptions.framework,
          layer.metadata.accessLevel,
        )
      ) {
      | Types.Public => [AccessLevelModifier(PublicModifier)]
      | Types.Private => [AccessLevelModifier(PrivateModifier)]
      | Types.Internal => []
      };
    VariableDeclaration({
      "modifiers": modifiers,
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(layer.name |> SwiftFormat.layerName),
          "annotation": None,
        }),
      "init":
        Some(
          Doc.viewVariableInitialValue(
            swiftOptions,
            assignmentsFromLayerParameters,
            layer,
            Naming.layerType(
              config,
              swiftOptions,
              logic,
              name,
              containsNoninteractiveDescendants,
              layer,
            ),
          ),
        ),
      "block": None,
    });
  };

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

  let layerMemberExpression = (layer: Types.layer, statements) =>
    Doc.layerMemberExpression(rootLayer, layer, statements);

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
            SwiftHelperClass.generateImageWithBackgroundColor(config),
          ]
          |> List.concat :
          []
      | SwiftOptions.UIKit =>
        rootLayer |> Layer.flatten |> List.exists(Layer.isImageLayer) ?
          [
            [LineComment("MARK: - " ++ "BackgroundImageView"), Empty],
            SwiftHelperClass.generateBackgroundImage(config),
          ]
          |> List.concat :
          []
      },
      swiftOptions.framework == UIKit && containsNoninteractiveDescendants ?
        [LineComment("MARK: - " ++ "EventIgnoringView"), Empty]
        @ SwiftHelperClass.eventIgnoringView(options, swiftOptions) :
        [],
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
    |> SwiftDocument.joinGroups(Empty);

  let superclass =
    TypeName(
      SwiftPlugin.applyTransformType(
        config,
        Some(name),
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
            SwiftDocument.importFramework(config),
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
                    [
                      Doc.init(
                        config,
                        swiftOptions,
                        parameters,
                        needsTracking,
                      ),
                    ],
                    [Doc.initIndividualParameters(config, parameters)],
                    parameters
                    |> List.filter(param =>
                         !Parameter.isFunction(config, param)
                       )
                    |> List.length > 0 ?
                      [Doc.convenienceInit()] : [],
                    [Doc.coderInitializer(needsTracking)],
                    needsTracking ? [AppkitPressable.deinitTrackingArea] : [],
                    [LineComment("MARK: Public")],
                    parameters
                    |> List.map(Doc.parameterVariable(config, swiftOptions))
                    |> SwiftDocument.join(Empty),
                    [Doc.parametersModelVariable()],
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
                        parameters,
                        logic,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
                        rootLayer,
                      ),
                    ],
                    [
                      SwiftConstraint.setUpFunction(
                        swiftOptions,
                        config,
                        assignmentsFromLogic,
                        layerMemberExpression,
                        rootLayer,
                      ),
                    ],
                    List.length(conditionalConstraints) > 0 ?
                      [
                        SwiftConstraint.conditionalConstraintsFunction(
                          config,
                          assignmentsFromLogic,
                          rootLayer,
                        ),
                      ] :
                      [],
                    [
                      Doc.update(
                        swiftOptions,
                        config,
                        parameters,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
                        List.length(conditionalConstraints) > 0,
                        rootLayer,
                        logic,
                      ),
                    ],
                    parameters
                    |> List.filter(Parameter.isFunction(config))
                    |> List.map(
                         Doc.functionParameterProxy(config, swiftOptions),
                       )
                    |> SwiftDocument.join(Empty),
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
                      |> List.map(Doc.tapHandler)
                      |> SwiftDocument.joinGroups(Empty) :
                      [],
                    swiftOptions.framework == UIKit
                    && Layer.isInteractive(logic, rootLayer)
                    && rootLayer
                    |> Layer.flatten
                    |> List.filter(Layer.isInteractive(logic))
                    |> List.length > 1 ?
                      Doc.nestedInteractiveHitTest(rootLayer) : [],
                  ],
                ),
            }),
          ],
          SwiftViewModel.parametersExtension(config, name, parameters),
          SwiftViewModel.viewModelExtension(
            config,
            swiftOptions,
            name,
            parameters,
          ),
          parameters
          |> List.map(Doc.fileLocalType(swiftOptions, name))
          |> Sequence.compact
          |> SwiftDocument.joinGroups(Empty),
        ],
      ),
  });
};