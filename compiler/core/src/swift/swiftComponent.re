type constraintDefinition = {
  variableName: string,
  initialValue: SwiftAst.node,
  priority: Constraint.layoutPriority,
};

type directionParameter = {
  lonaName: ParameterKey.t,
  swiftName: string,
};

module Naming = {
  let layerType =
      (
        config: Config.t,
        pluginContext: Plugin.context,
        swiftOptions: SwiftOptions.options,
        componentName: string,
        layerType,
      ) => {
    let typeName =
      switch (swiftOptions.framework, layerType) {
      | (UIKit, Types.View) => "UIView"
      | (UIKit, Text) => "UILabel"
      | (UIKit, Image) => "UIImageView"
      | (AppKit, Types.View) => "NSBox"
      | (AppKit, Text) => "NSTextField"
      | (AppKit, Image) => "NSImageView"
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

module Parameter = {
  let isFunction = (param: Types.parameter) =>
    param.ltype == Types.handlerType;

  let isSetInitially = (layer: Types.layer, parameter) =>
    ParameterMap.mem(parameter, layer.parameters);

  let get = (layer: Types.layer, parameter) =>
    ParameterMap.find_opt(parameter, layer.parameters);

  let isAssigned = (assignments, layer: Types.layer, parameter) => {
    let assignedParameters = Layer.LayerMap.find_opt(layer, assignments);
    switch (assignedParameters) {
    | Some(parameters) => ParameterMap.mem(parameter, parameters)
    | None => false
    };
  };

  let isUsed = (assignments, layer: Types.layer, parameter) =>
    isAssigned(assignments, layer, parameter)
    || isSetInitially(layer, parameter);

  let paddingParameters = [
    {swiftName: "topPadding", lonaName: PaddingTop},
    {swiftName: "trailingPadding", lonaName: PaddingRight},
    {swiftName: "bottomPadding", lonaName: PaddingBottom},
    {swiftName: "leadingPadding", lonaName: PaddingLeft},
  ];

  let marginParameters = [
    {swiftName: "topMargin", lonaName: MarginTop},
    {swiftName: "trailingMargin", lonaName: MarginRight},
    {swiftName: "bottomMargin", lonaName: MarginBottom},
    {swiftName: "leadingMargin", lonaName: MarginLeft},
  ];
};

/* Ast builders, agnostic to the kind of data they use */
module Build = {
  open SwiftAst;

  let memberExpression = (list: list(string)): node =>
    switch (list) {
    | [item] => SwiftIdentifier(item)
    | _ => MemberExpression(list |> List.map(item => SwiftIdentifier(item)))
    };

  let functionCall =
      (
        name: list(string),
        arguments: list((option(string), list(string))),
      )
      : node =>
    FunctionCallExpression({
      "name": memberExpression(name),
      "arguments":
        arguments
        |> List.map(((label, expr)) =>
             FunctionCallArgument({
               "name":
                 switch (label) {
                 | Some(value) => Some(SwiftIdentifier(value))
                 | None => None
                 },
               "value": memberExpression(expr),
             })
           ),
    });

  let privateVariableDeclaration =
      (name: string, annotation: option(typeAnnotation), init: option(node)) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(name),
          "annotation": annotation,
        }),
      "init": init,
      "block": None,
    });

  let convenienceInit = (body: list(node)): node =>
    InitializerDeclaration({
      "modifiers": [
        AccessLevelModifier(PublicModifier),
        ConvenienceModifier,
      ],
      "parameters": [],
      "failable": None,
      "throws": false,
      "body": body,
    });
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
    Build.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "hovered"),
      None,
      Some(LiteralExpression(Boolean(false))),
    ),
    Build.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "pressed"),
      None,
      Some(LiteralExpression(Boolean(false))),
    ),
    Build.privateVariableDeclaration(
      SwiftFormat.layerVariableName(rootLayer, layer, "onPress"),
      Some(OptionalType(TypeName("(() -> Void)"))),
      None,
    ),
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
            "didSet": Some([Build.functionCall(["update"], [])]),
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
        colors,
        textStyles: TextStyle.file,
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
          Logic.defaultAssignmentForLayerParameter(
            colors,
            textStyles,
            layer,
            name,
          )
        };
      let node =
        SwiftLogic.toSwiftAST(
          swiftOptions,
          colors,
          textStyles,
          rootLayer,
          logic,
        );
      StatementListHelper(node);
    };
  };

  let setUpViews =
      (
        swiftOptions: SwiftOptions.options,
        colors,
        textStyles: TextStyle.file,
        getComponent,
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
        |> List.filter(filterParameters)
        |> List.filter(filterNotAssignedByLogic(layer))
        |> List.map(((k, v)) =>
             defineInitialLayerValue(
               swiftOptions,
               colors,
               textStyles,
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
      | (SwiftOptions.AppKit, View) => [
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
    FunctionDeclaration({
      "name": "setUpViews",
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
          ],
        ),
    });
  };

  let update =
      (
        swiftOptions: SwiftOptions.options,
        colors,
        textStyles: TextStyle.file,
        getComponent,
        assignmentsFromLayerParameters,
        assignmentsFromLogic,
        rootLayer: Types.layer,
        logic,
      ) => {
    let filterParameters = ((name, _)) =>
      name != ParameterKey.PaddingTop
      && name != PaddingRight
      && name != PaddingBottom
      && name != PaddingLeft
      && name != MarginTop
      && name != MarginRight
      && name != MarginBottom
      && name != MarginLeft;
    let conditionallyAssigned = Logic.conditionallyAssignedIdentifiers(logic);
    let filterConditionallyAssigned = (layer: Types.layer, (name, _)) => {
      let isAssigned = ((_, value)) =>
        value == ["layers", layer.name, name |> ParameterKey.toString];
      conditionallyAssigned |> Logic.IdentifierSet.exists(isAssigned);
    };
    let defineInitialLayerValues = ((layer, propertyMap)) =>
      propertyMap
      |> ParameterMap.bindings
      |> List.filter(filterParameters)
      |> List.filter(filterConditionallyAssigned(layer))
      |> List.map(
           defineInitialLayerValue(
             swiftOptions,
             colors,
             textStyles,
             getComponent,
             assignmentsFromLayerParameters,
             rootLayer,
             layer,
           ),
         );

    FunctionDeclaration({
      "name": "update",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        (
          assignmentsFromLogic
          |> Layer.LayerMap.bindings
          |> List.map(defineInitialLayerValues)
          |> List.concat
        )
        @ SwiftLogic.toSwiftAST(
            swiftOptions,
            colors,
            textStyles,
            rootLayer,
            logic,
          ),
    });
  };
};

let generate =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      name,
      colors,
      textStyles: TextStyle.file,
      getComponent,
      json,
    ) => {
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
  open SwiftAst;

  let viewVariableNode = (layer: Types.layer): node =>
    Build.privateVariableDeclaration(
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
            name,
            layer.typeName,
          ),
        ),
      ),
    );
  let textStyleVariableDoc = (layer: Types.layer) => {
    let id =
      Parameter.isSetInitially(layer, TextStyle) ?
        Layer.getStringParameter(TextStyle, layer) :
        textStyles.defaultStyle.id;
    let value =
      Parameter.isSetInitially(layer, TextAlign) ?
        Build.functionCall(
          ["TextStyles", id, "with"],
          [
            (
              Some("alignment"),
              ["." ++ Layer.getStringParameter(TextAlign, layer)],
            ),
          ],
        ) :
        Build.memberExpression(["TextStyles", id]);
    Build.privateVariableDeclaration(
      SwiftFormat.layerName(layer.name) ++ "TextStyle",
      None,
      Some(value),
    );
  };
  let constraintVariableDoc = variableName =>
    Build.privateVariableDeclaration(
      variableName,
      Some(OptionalType(TypeName("NSLayoutConstraint"))),
      None,
    );
  let spacingVariableDoc = (layer: Types.layer) => {
    let variableName = variable =>
      layer === rootLayer ?
        variable :
        SwiftFormat.layerName(layer.name) ++ Format.upperFirst(variable);
    let marginVariables =
      layer === rootLayer ?
        [] :
        {
          let createVariable = (marginParameter: directionParameter) =>
            Build.privateVariableDeclaration(
              variableName(marginParameter.swiftName),
              Some(TypeName("CGFloat")),
              Some(
                LiteralExpression(
                  FloatingPoint(
                    Layer.getNumberParameter(marginParameter.lonaName, layer),
                  ),
                ),
              ),
            );
          Parameter.marginParameters |> List.map(createVariable);
        };
    let paddingVariables =
      switch (layer.children) {
      | [] => []
      | _ =>
        let createVariable = (paddingParameter: directionParameter) =>
          Build.privateVariableDeclaration(
            variableName(paddingParameter.swiftName),
            Some(TypeName("CGFloat")),
            Some(
              LiteralExpression(
                FloatingPoint(
                  Layer.getNumberParameter(paddingParameter.lonaName, layer),
                ),
              ),
            ),
          );
        Parameter.paddingParameters |> List.map(createVariable);
      };
    marginVariables @ paddingVariables;
  };

  let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
    BinaryExpression({
      "left":
        Build.memberExpression([
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
              Build.functionCall(
                ["super", "init"],
                [(Some("frame"), [".zero"])],
              ),
            ],
            [
              Build.functionCall(["setUpViews"], []),
              Build.functionCall(["setUpConstraints"], []),
            ],
            [Build.functionCall(["update"], [])],
            needsTracking ? [AppkitPressable.addTrackingArea] : [],
          ],
        ),
    });
  let convenienceInitializerDoc = () =>
    Build.convenienceInit(
      SwiftDocument.joinGroups(
        Empty,
        [
          [
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
                             SwiftIdentifier(
                               param.name |> ParameterKey.toString,
                             ),
                           ),
                         "value":
                           SwiftDocument.defaultValueForLonaType(
                             swiftOptions.framework,
                             colors,
                             textStyles,
                             param.ltype,
                           ),
                       })
                     ),
              }),
            ]),
          ],
        ],
      ),
    );
  let memberOrSelfExpression = (firstIdentifier, statements) =>
    switch (firstIdentifier) {
    | "self" => MemberExpression(statements)
    | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
    };
  let parentNameOrSelf = (parent: Types.layer) =>
    parent === rootLayer ? "self" : parent.name |> SwiftFormat.layerName;
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
    | SwiftOptions.UIKit => []
    };

  let constraints =
    SwiftConstraint.calculateConstraints(getComponent, rootLayer);
  let superclass =
    TypeName(
      Naming.layerType(config, pluginContext, swiftOptions, name, Types.View),
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
                    nonRootLayers |> List.map(viewVariableNode),
                    nonRootLayers
                    |> List.filter(Layer.isTextLayer)
                    |> List.map(textStyleVariableDoc),
                    rootLayer
                    |> Layer.flatmap(spacingVariableDoc)
                    |> List.concat,
                    pressableLayers
                    |> List.map(Doc.pressableVariables(rootLayer))
                    |> List.concat,
                    constraints
                    |> List.map(def =>
                         constraintVariableDoc(
                           SwiftConstraint.formatConstraintVariableName(
                             rootLayer,
                             def,
                           ),
                         )
                       ),
                    [
                      Doc.setUpViews(
                        swiftOptions,
                        colors,
                        textStyles,
                        getComponent,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
                        layerMemberExpression,
                        rootLayer,
                      ),
                    ],
                    [
                      SwiftConstraint.setUpFunction(
                        swiftOptions,
                        getComponent,
                        layerMemberExpression,
                        rootLayer,
                      ),
                    ],
                    [
                      Doc.update(
                        swiftOptions,
                        colors,
                        textStyles,
                        getComponent,
                        assignmentsFromLayerParameters,
                        assignmentsFromLogic,
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
                  ],
                ),
            }),
          ],
        ],
      ),
  });
};