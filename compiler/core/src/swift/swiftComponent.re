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
  let priorityName =
    fun
    | Constraint.Required => "required"
    | Low => "defaultLow";

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
  let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
    let parameters =
      Layer.LayerMap.find_opt(layer, assignmentsFromLayerParameters);
    switch (parameters) {
    | None => LineComment(layer.name)
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
  let setUpViewsDoc = (root: Types.layer) => {
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
        |> List.map(((k, v)) => defineInitialLayerValue(layer, (k, v)));
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
            Layer.flatmap(resetViewStyling, root) |> List.concat,
            Layer.flatmapParent(addSubviews, root) |> List.concat,
            setUpDefaultsDoc(),
          ],
        ),
    });
  };
  let negateNumber = expression =>
    PrefixExpression({"operator": "-", "expression": expression});
  let constraintConstantExpression =
      (layer: Types.layer, variable1, parent: Types.layer, variable2) => {
    let variableName = (layer: Types.layer, variable) =>
      layer === rootLayer ?
        variable :
        SwiftFormat.layerName(layer.name) ++ Format.upperFirst(variable);
    BinaryExpression({
      "left": SwiftIdentifier(variableName(layer, variable1)),
      "operator": "+",
      "right": SwiftIdentifier(variableName(parent, variable2)),
    });
  };
  let generateConstraintWithInitialValue = (constr: Constraint.t, node) =>
    switch (constr) {
    | Constraint.Dimension((layer: Types.layer), dimension, _, _) =>
      layerMemberExpression(
        layer,
        [
          SwiftIdentifier(Constraint.anchorToString(dimension)),
          FunctionCallExpression({
            "name": SwiftIdentifier("constraint"),
            "arguments": [
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("equalToConstant")),
                "value": node,
              }),
            ],
          }),
        ],
      )
    | Constraint.Relation(
        (layer1: Types.layer),
        edge1,
        relation,
        (layer2: Types.layer),
        edge2,
        _,
        _,
      ) =>
      layerMemberExpression(
        layer1,
        [
          SwiftIdentifier(Constraint.anchorToString(edge1)),
          FunctionCallExpression({
            "name": SwiftIdentifier("constraint"),
            "arguments": [
              FunctionCallArgument({
                "name":
                  Some(SwiftIdentifier(Constraint.cmpToString(relation))),
                "value":
                  layerMemberExpression(
                    layer2,
                    [SwiftIdentifier(Constraint.anchorToString(edge2))],
                  ),
              }),
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("constant")),
                "value": node,
              }),
            ],
          }),
        ],
      )
    };
  let generateConstantFromConstraint = (constr: Constraint.t) =>
    Constraint.(
      switch (constr) {
      /* Currently centering doesn't require any constants, since a centered view also
         has a pair of before/after constraints that include the constants */
      | Relation(_, CenterX, _, _, CenterX, _, _)
      | Relation(_, CenterY, _, _, CenterY, _, _) =>
        LiteralExpression(FloatingPoint(0.0))
      | Relation(child, Top, _, layer, Top, _, PrimaryBefore)
      | Relation(child, Top, _, layer, Top, _, SecondaryBefore) =>
        constraintConstantExpression(layer, "topPadding", child, "topMargin")
      | Relation(child, Leading, _, layer, Leading, _, PrimaryBefore)
      | Relation(child, Leading, _, layer, Leading, _, SecondaryBefore) =>
        constraintConstantExpression(
          layer,
          "leadingPadding",
          child,
          "leadingMargin",
        )
      | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
      | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) =>
        negateNumber(
          constraintConstantExpression(
            layer,
            "bottomPadding",
            child,
            "bottomMargin",
          ),
        )
      | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
      | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) =>
        negateNumber(
          constraintConstantExpression(
            layer,
            "trailingPadding",
            child,
            "trailingMargin",
          ),
        )
      | Relation(child, Top, _, previousLayer, Bottom, _, PrimaryBetween) =>
        constraintConstantExpression(
          previousLayer,
          "bottomMargin",
          child,
          "topMargin",
        )
      | Relation(
          child,
          Leading,
          _,
          previousLayer,
          Trailing,
          _,
          PrimaryBetween,
        ) =>
        constraintConstantExpression(
          previousLayer,
          "trailingMargin",
          child,
          "leadingMargin",
        )
      | Relation(child, Width, Leq, layer, Width, _, FitContentSecondary) =>
        negateNumber(
          BinaryExpression({
            "left":
              constraintConstantExpression(
                layer,
                "leadingPadding",
                child,
                "leadingMargin",
              ),
            "operator": "+",
            "right":
              constraintConstantExpression(
                layer,
                "trailingPadding",
                child,
                "trailingMargin",
              ),
          }),
        )
      | Relation(child, Height, Leq, layer, Height, _, FitContentSecondary) =>
        negateNumber(
          BinaryExpression({
            "left":
              constraintConstantExpression(
                layer,
                "topPadding",
                child,
                "topMargin",
              ),
            "operator": "+",
            "right":
              constraintConstantExpression(
                layer,
                "bottomPadding",
                child,
                "bottomMargin",
              ),
          }),
        )
      | Relation(_, _, _, _, _, _, FlexSibling) =>
        LiteralExpression(FloatingPoint(0.0))
      | Dimension((layer: Types.layer), Height, _, _) =>
        let constant = Layer.getNumberParameter(Height, layer);
        LiteralExpression(FloatingPoint(constant));
      | Dimension((layer: Types.layer), Width, _, _) =>
        let constant = Layer.getNumberParameter(Width, layer);
        LiteralExpression(FloatingPoint(constant));
      | _ =>
        Js.log("Unknown constraint types");
        raise(Not_found);
      }
    );
  let formatConstraintVariableName = (constr: Constraint.t) => {
    open Constraint;
    let formatAnchorVariableName = (layer: Types.layer, anchor, suffix) => {
      let anchorString = Constraint.anchorToString(anchor);
      (
        layer === rootLayer ?
          anchorString :
          SwiftFormat.layerName(layer.name)
          ++ Format.upperFirst(anchorString)
      )
      ++ suffix;
    };
    switch (constr) {
    | Relation(
        (layer1: Types.layer),
        edge1,
        _,
        (layer2: Types.layer),
        _,
        _,
        FlexSibling,
      ) =>
      SwiftFormat.layerName(layer1.name)
      ++ Format.upperFirst(SwiftFormat.layerName(layer2.name))
      ++ Format.upperFirst(Constraint.anchorToString(edge1))
      ++ "SiblingConstraint"
    | Relation((layer1: Types.layer), edge1, _, _, _, _, FitContentSecondary) =>
      formatAnchorVariableName(layer1, edge1, "ParentConstraint")
    | Relation((layer1: Types.layer), edge1, _, _, _, _, _) =>
      formatAnchorVariableName(layer1, edge1, "Constraint")
    | Dimension((layer: Types.layer), dimension, _, _) =>
      formatAnchorVariableName(layer, dimension, "Constraint")
    };
  };
  let constraints =
    Constraint.getConstraints(
      /* For the purposes of layouts, we want to swap the custom component layer
         with the root layer from the custom component's definition. We should
         use the parameters of the custom component's root layer, since these
         determine layout. We should still use the type, name, and children of
         the custom component layer. */
      (layer: Types.layer, name) => {
        let component = getComponent(name);
        let rootLayer = component |> Decode.Component.rootLayer(getComponent);
        {
          typeName: layer.typeName,
          styles: layer.styles,
          name: layer.name,
          parameters: rootLayer.parameters,
          children: layer.children,
        };
      },
      rootLayer,
    );
  let setUpConstraintsDoc = (root: Types.layer) => {
    let translatesAutoresizingMask = (layer: Types.layer) =>
      BinaryExpression({
        "left":
          layerMemberExpression(
            layer,
            [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")],
          ),
        "operator": "=",
        "right": LiteralExpression(Boolean(false)),
      });
    let getInitialValue = constr =>
      generateConstraintWithInitialValue(
        constr,
        generateConstantFromConstraint(constr),
      );
    let defineConstraint = def =>
      ConstantDeclaration({
        "modifiers": [],
        "init": Some(getInitialValue(def)),
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier(formatConstraintVariableName(def)),
            "annotation": None,
          }),
      });
    let setConstraintPriority = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier(formatConstraintVariableName(def)),
            SwiftIdentifier("priority"),
          ]),
        "operator": "=",
        "right":
          MemberExpression([
            SwiftDocument.layoutPriorityTypeDoc(swiftOptions.framework),
            SwiftIdentifier(priorityName(Constraint.getPriority(def))),
          ]),
      });
    let activateConstraints = () =>
      FunctionCallExpression({
        "name":
          MemberExpression([
            SwiftIdentifier("NSLayoutConstraint"),
            SwiftIdentifier("activate"),
          ]),
        "arguments": [
          FunctionCallArgument({
            "name": None,
            "value":
              LiteralExpression(
                Array(
                  constraints
                  |> List.map(def =>
                       SwiftIdentifier(formatConstraintVariableName(def))
                     ),
                ),
              ),
          }),
        ],
      });
    let assignConstraint = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier("self"),
            SwiftIdentifier(formatConstraintVariableName(def)),
          ]),
        "operator": "=",
        "right": SwiftIdentifier(formatConstraintVariableName(def)),
      });
    let assignConstraintIdentifier = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier(formatConstraintVariableName(def)),
            SwiftIdentifier("identifier"),
          ]),
        "operator": "=",
        "right":
          LiteralExpression(String(formatConstraintVariableName(def))),
      });
    FunctionDeclaration({
      "name": "setUpConstraints",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            root |> Layer.flatmap(translatesAutoresizingMask),
            constraints |> List.map(defineConstraint),
            constraints
            |> List.filter(def => Constraint.getPriority(def) == Low)
            |> List.map(setConstraintPriority),
            List.length(constraints) > 0 ? [activateConstraints()] : [],
            constraints |> List.map(assignConstraint),
            List.length(constraints) > 0 ?
              [
                LineComment("For debugging"),
                ...constraints |> List.map(assignConstraintIdentifier),
              ] :
              [],
          ],
        ),
    });
  };
  let updateDoc = () => {
    /* let printStringBinding = ((key, value)) => Js.log2(key, value);
       let printLayerBinding = ((key: Types.layer, value)) => {
         Js.log(key.name);
         StringMap.bindings(value) |> List.iter(printStringBinding)
       };
       Layer.LayerMap.bindings(assignments) |> List.iter(printLayerBinding); */
    /* let cond = Logic.conditionallyAssignedIdentifiers(logic);
       cond |> Logic.IdentifierSet.elements |> List.iter(((ltype, path)) => Js.log(path)); */
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
      |> List.map(defineInitialLayerValue(layer));
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
              "inherits": [
                TypeName(
                  Naming.layerType(
                    config,
                    pluginContext,
                    swiftOptions,
                    name,
                    Types.View,
                  ),
                ),
              ],
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
                           formatConstraintVariableName(def),
                         )
                       ),
                    [setUpViewsDoc(rootLayer)],
                    [setUpConstraintsDoc(rootLayer)],
                    [updateDoc()],
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