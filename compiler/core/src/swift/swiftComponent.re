module Ast = SwiftAst;

module Document = SwiftDocument;

module Render = SwiftRender;

type constraintDefinition = {
  variableName: string,
  initialValue: Ast.node,
  priority: Constraint.layoutPriority
};

type directionParameter = {
  lonaName: string,
  swiftName: string
};

/* type parameterAssignmentMode =
   | Initialized
   | AlwaysAssigned
   | ConditionallyAssigned
   | InitializedAndAlwaysAssigned
   | InitializedAndConditionallyAssigned; */
let isFunctionParameter = (param: Types.parameter) =>
  param.ltype == Types.handlerType;

let generate =
    (
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      name,
      colors,
      textStyles: TextStyle.file,
      getComponent,
      json
    ) => {
  let rootLayer = json |> Decode.Component.rootLayer(getComponent);
  /* Remove the root element */
  let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
  let logic = json |> Decode.Component.logic;
  let textLayers = nonRootLayers |> List.filter(Layer.isTextLayer);
  let imageLayers = nonRootLayers |> List.filter(Layer.isImageLayer);
  let pressableLayers =
    rootLayer
    |> Layer.flatten
    |> List.filter(Logic.isLayerParameterAssigned(logic, "onPress"));
  let needsTracking =
    swiftOptions.framework == SwiftOptions.AppKit
    && List.length(pressableLayers) > 0;
  /* let logic =
     Logic.enforceSingleAssignment(
       (_, path) => [
         "_" ++ Format.variableNameFromIdentifier(rootLayer.name, path)
       ],
       (_, path) =>
         Logic.Literal(LonaValue.defaultValueForParameter(List.nth(path, 2))),
       logic
     ); */
  let layerParameterAssignments =
    Layer.logicAssignmentsFromLayerParameters(rootLayer);
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let parameters = json |> Decode.Component.parameters;
  open Ast;
  let priorityName =
    fun
    | Constraint.Required => "required"
    | Low => "defaultLow";
  let isParameterSetInitially = (layer: Types.layer, parameter) =>
    StringMap.mem(parameter, layer.parameters);
  let getParameter = (layer: Types.layer, parameter) =>
    StringMap.find_opt(parameter, layer.parameters);
  let isParameterAssigned = (layer: Types.layer, parameter) => {
    let assignedParameters =
      Layer.LayerMap.find_opt(layer, layerParameterAssignments);
    switch assignedParameters {
    | Some(parameters) => StringMap.mem(parameter, parameters)
    | None => false
    };
  };
  let isParameterUsed = (layer: Types.layer, parameter) =>
    isParameterAssigned(layer, parameter)
    || isParameterSetInitially(layer, parameter);
  let parameterVariableDoc = (parameter: Types.parameter) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(parameter.name |> ParameterKey.toString),
          "annotation":
            Some(
              parameter.ltype
              |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework)
            )
        }),
      "init": None,
      "block":
        Some(
          WillSetDidSetBlock({
            "willSet": None,
            "didSet":
              Some([
                FunctionCallExpression({
                  "name": SwiftIdentifier("update"),
                  "arguments": []
                })
              ])
          })
        )
    });
  /* TODO: We don't need to update if onPress is only initialized in setUpViews
     and never assigned in logic */
  /* (isFunctionParameter(parameter) && !isParameterAssigned(parameter)) ?
     None : */
  let getLayerTypeName = layerType =>
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
  let getLayerInitCall = (layer: Types.layer) => {
    let typeName = SwiftIdentifier(layer.typeName |> getLayerTypeName);
    switch (swiftOptions.framework, layer.typeName) {
    | (UIKit, Types.View)
    | (UIKit, Image) =>
      FunctionCallExpression({
        "name": typeName,
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("frame")),
            "value": SwiftIdentifier(".zero")
          })
        ]
      })
    | (AppKit, Text) =>
      FunctionCallExpression({
        "name": typeName,
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("labelWithString")),
            "value": LiteralExpression(String(""))
          })
        ]
      })
    | (AppKit, Image) =>
      let hasBackground = isParameterAssigned(layer, "backgroundColor");
      FunctionCallExpression({
        "name":
          hasBackground ?
            SwiftIdentifier("ImageWithBackgroundColor") : typeName,
        "arguments": []
      });
    | _ => FunctionCallExpression({"name": typeName, "arguments": []})
    };
  };
  let viewVariableDoc = (layer: Types.layer) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(layer.name |> SwiftFormat.layerName),
          "annotation": None /*Some(layer.typeName |> viewTypeDoc)*/
        }),
      "init": Some(getLayerInitCall(layer)),
      "block": None
    });
  let textStyleVariableDoc = (layer: Types.layer) => {
    let styleName =
      MemberExpression([
        SwiftIdentifier("TextStyles"),
        SwiftIdentifier(
          isParameterSetInitially(layer, "font") ?
            Layer.getStringParameter("font", layer) :
            textStyles.defaultStyle.id
        )
      ]);
    let styleName =
      isParameterSetInitially(layer, "textAlign") ?
        MemberExpression([
          styleName,
          FunctionCallExpression({
            "name": SwiftIdentifier("with"),
            "arguments": [
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("alignment")),
                "value":
                  SwiftIdentifier(
                    "." ++ Layer.getStringParameter("textAlign", layer)
                  )
              })
            ]
          })
        ]) :
        styleName;
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              (layer.name |> SwiftFormat.layerName) ++ "TextStyle"
            ),
          "annotation": None /* Some(TypeName("TextStyle")) */
        }),
      "init": Some(styleName),
      "block": None
    });
  };
  let constraintVariableDoc = variableName =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(variableName),
          "annotation": Some(OptionalType(TypeName("NSLayoutConstraint")))
        }),
      "init": None,
      "block": None
    });
  let paddingParameters = [
    {swiftName: "topPadding", lonaName: "paddingTop"},
    {swiftName: "trailingPadding", lonaName: "paddingRight"},
    {swiftName: "bottomPadding", lonaName: "paddingBottom"},
    {swiftName: "leadingPadding", lonaName: "paddingLeft"}
  ];
  let marginParameters = [
    {swiftName: "topMargin", lonaName: "marginTop"},
    {swiftName: "trailingMargin", lonaName: "marginRight"},
    {swiftName: "bottomMargin", lonaName: "marginBottom"},
    {swiftName: "leadingMargin", lonaName: "marginLeft"}
  ];
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
            VariableDeclaration({
              "modifiers": [AccessLevelModifier(PrivateModifier)],
              "pattern":
                IdentifierPattern({
                  "identifier":
                    SwiftIdentifier(variableName(marginParameter.swiftName)),
                  "annotation": Some(TypeName("CGFloat"))
                }),
              "init":
                Some(
                  LiteralExpression(
                    FloatingPoint(
                      Layer.getNumberParameter(marginParameter.lonaName, layer)
                    )
                  )
                ),
              "block": None
            });
          marginParameters |> List.map(createVariable);
        };
    let paddingVariables =
      switch layer.children {
      | [] => []
      | _ =>
        let createVariable = (paddingParameter: directionParameter) =>
          VariableDeclaration({
            "modifiers": [AccessLevelModifier(PrivateModifier)],
            "pattern":
              IdentifierPattern({
                "identifier":
                  SwiftIdentifier(variableName(paddingParameter.swiftName)),
                "annotation": Some(TypeName("CGFloat"))
              }),
            "init":
              Some(
                LiteralExpression(
                  FloatingPoint(
                    Layer.getNumberParameter(paddingParameter.lonaName, layer)
                  )
                )
              ),
            "block": None
          });
        paddingParameters |> List.map(createVariable);
      };
    marginVariables @ paddingVariables;
  };
  let pressableVariableDoc = (layer: Types.layer) => [
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, "hovered")
            ),
          "annotation": None
        }),
      "init": Some(LiteralExpression(Boolean(false))),
      "block": None
    }),
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, "pressed")
            ),
          "annotation": None
        }),
      "init": Some(LiteralExpression(Boolean(false))),
      "block": None
    }),
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, "onPress")
            ),
          "annotation": Some(OptionalType(TypeName("(() -> Void)")))
        }),
      "init": None,
      "block": None
    })
  ];
  let initParameterDoc = (parameter: Decode.parameter) =>
    Parameter({
      "externalName": None,
      "localName": parameter.name |> ParameterKey.toString,
      "annotation":
        parameter.ltype
        |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework),
      "defaultValue": None
    });
  let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier("self"),
          SwiftIdentifier(parameter.name |> ParameterKey.toString)
        ]),
      "operator": "=",
      "right": SwiftIdentifier(parameter.name |> ParameterKey.toString)
    });
  let initializerCoderDoc = () =>
    /* required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
       } */
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), RequiredModifier],
      "parameters": [
        Parameter({
          "externalName": Some("coder"),
          "localName": "aDecoder",
          "annotation": TypeName("NSCoder"),
          "defaultValue": None
        })
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
                SwiftIdentifier("\"init(coder:) has not been implemented\"")
            })
          ]
        })
      ]
    });
  let initializerDoc = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters":
        parameters
        |> List.filter(param => ! isFunctionParameter(param))
        |> List.map(initParameterDoc),
      "failable": None,
      "throws": false,
      "body":
        Document.joinGroups(
          Empty,
          [
            parameters
            |> List.filter(param => ! isFunctionParameter(param))
            |> List.map(initParameterAssignmentDoc),
            [
              MemberExpression([
                SwiftIdentifier("super"),
                FunctionCallExpression({
                  "name": SwiftIdentifier("init"),
                  "arguments": [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("frame")),
                      "value": SwiftIdentifier(".zero")
                    })
                  ]
                })
              ])
            ],
            [
              FunctionCallExpression({
                "name": SwiftIdentifier("setUpViews"),
                "arguments": []
              }),
              FunctionCallExpression({
                "name": SwiftIdentifier("setUpConstraints"),
                "arguments": []
              })
            ],
            [
              FunctionCallExpression({
                "name": SwiftIdentifier("update"),
                "arguments": []
              })
            ],
            needsTracking ? [AppkitPressable.addTrackingArea] : []
          ]
        )
    });
  let convenienceInitializerDoc = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), ConvenienceModifier],
      "parameters": [],
      "failable": None,
      "throws": false,
      "body":
        Document.joinGroups(
          Empty,
          [
            [
              MemberExpression([
                SwiftIdentifier("self"),
                FunctionCallExpression({
                  "name": SwiftIdentifier("init"),
                  "arguments":
                    parameters
                    |> List.filter(param => ! isFunctionParameter(param))
                    |> List.map((param: Decode.parameter) =>
                         FunctionCallArgument({
                           "name":
                             Some(
                               SwiftIdentifier(
                                 param.name |> ParameterKey.toString
                               )
                             ),
                           "value":
                             Document.defaultValueForLonaType(
                               swiftOptions.framework,
                               colors,
                               textStyles,
                               param.ltype
                             )
                         })
                       )
                })
              ])
            ]
          ]
        )
    });
  let memberOrSelfExpression = (firstIdentifier, statements) =>
    switch firstIdentifier {
    | "self" => MemberExpression(statements)
    | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
    };
  let parentNameOrSelf = (parent: Types.layer) =>
    parent === rootLayer ? "self" : parent.name |> SwiftFormat.layerName;
  let layerMemberExpression = (layer: Types.layer, statements) =>
    memberOrSelfExpression(parentNameOrSelf(layer), statements);
  let defaultValueForParameter =
    fun
    | "backgroundColor" =>
      MemberExpression([SwiftIdentifier("UIColor"), SwiftIdentifier("clear")])
    | "font"
    | "textStyle" =>
      MemberExpression([
        SwiftIdentifier("TextStyles"),
        SwiftIdentifier(textStyles.defaultStyle.id)
      ])
    | _ => LiteralExpression(Integer(0));
  let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
    let parameters = Layer.LayerMap.find_opt(layer, layerParameterAssignments);
    switch parameters {
    | None => LineComment(layer.name)
    | Some(parameters) =>
      let assignment = StringMap.find_opt(name, parameters);
      let parameterName =
        switch name {
        | "textStyle" => "font"
        | _ => name
        };
      let parameterValue = getParameter(layer, parameterName);
      let logic =
        switch (assignment, layer.typeName, parameterValue) {
        | (Some(assignment), _, _) => assignment
        | (None, Component(componentName), _) =>
          let param =
            getComponent(componentName)
            |> Decode.Component.parameters
            |> List.find((param: Types.parameter) =>
                 ParameterKey.toString(param.name) == name
               );
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
      let node =
        SwiftLogic.toSwiftAST(
          swiftOptions,
          colors,
          textStyles,
          rootLayer,
          logic
        );
      StatementListHelper(node);
    };
  };
  let containsImageWithBackgroundColor = () => {
    let hasBackgroundColor = (layer: Types.layer) =>
      isParameterAssigned(layer, "backgroundColor");
    imageLayers |> List.exists(hasBackgroundColor);
  };
  let helperClasses =
    switch swiftOptions.framework {
    | SwiftOptions.AppKit =>
      containsImageWithBackgroundColor() ?
        [
          [LineComment("MARK: - " ++ "ImageWithBackgroundColor"), Empty],
          SwiftHelperClass.generateImageWithBackgroundColor(
            options,
            swiftOptions
          )
        ]
        |> List.concat :
        []
    | SwiftOptions.UIKit => []
    };
  let setUpViewsDoc = (root: Types.layer) => {
    let setUpDefaultsDoc = () => {
      let filterParameters = ((name, _)) =>
        name != "flexDirection"
        && name != "justifyContent"
        && name != "alignSelf"
        && name != "alignItems"
        && name != "flex"
        /* && name != "font" */
        && ! Js.String.startsWith("padding", name)
        && ! Js.String.startsWith("margin", name)
        /* Handled by initial constraint setup */
        && name != "height"
        && name != "width"
        && name != "textAlign";
      let filterNotAssignedByLogic = (layer: Types.layer, (parameterName, _)) =>
        switch (Layer.LayerMap.find_opt(layer, assignments)) {
        | None => true
        | Some(parameters) =>
          switch (StringMap.find_opt(parameterName, parameters)) {
          | None => true
          | Some(_) => false
          }
        };
      let defineInitialLayerValues = (layer: Types.layer) =>
        layer.parameters
        |> StringMap.bindings
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
            "left": layerMemberExpression(layer, [SwiftIdentifier("boxType")]),
            "operator": "=",
            "right": SwiftIdentifier(".custom")
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("borderType")]),
            "operator": "=",
            "right":
              isParameterUsed(layer, "borderWidth") ?
                SwiftIdentifier(".lineBorder") : SwiftIdentifier(".noBorder")
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(
                layer,
                [SwiftIdentifier("contentViewMargins")]
              ),
            "operator": "=",
            "right": SwiftIdentifier(".zero")
          })
        ]
      | (SwiftOptions.AppKit, Text) => [
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("lineBreakMode")]),
            "operator": "=",
            "right": SwiftIdentifier(".byWordWrapping")
          })
        ]
      | (SwiftOptions.UIKit, Text) =>
        [
          isParameterSetInitially(layer, "numberOfLines") ?
            [] :
            [
              BinaryExpression({
                "left":
                  layerMemberExpression(
                    layer,
                    [SwiftIdentifier("numberOfLines")]
                  ),
                "operator": "=",
                "right": LiteralExpression(Integer(0))
              })
            ]
        ]
        |> List.concat
      | _ => []
      };
    let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
      switch parent {
      | None => []
      | Some(parent) => [
          FunctionCallExpression({
            "name":
              layerMemberExpression(parent, [SwiftIdentifier("addSubview")]),
            "arguments": [SwiftIdentifier(layer.name |> SwiftFormat.layerName)]
          })
        ]
      };
    FunctionDeclaration({
      "name": "setUpViews",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        Document.joinGroups(
          Empty,
          [
            Layer.flatmap(resetViewStyling, root) |> List.concat,
            Layer.flatmapParent(addSubviews, root) |> List.concat,
            setUpDefaultsDoc()
          ]
        )
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
      "right": SwiftIdentifier(variableName(parent, variable2))
    });
  };
  let generateConstraintWithInitialValue = (constr: Constraint.t, node) =>
    switch constr {
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
                "value": node
              })
            ]
          })
        ]
      )
    | Constraint.Relation(
        (layer1: Types.layer),
        edge1,
        relation,
        (layer2: Types.layer),
        edge2,
        _,
        _
      ) =>
      layerMemberExpression(
        layer1,
        [
          SwiftIdentifier(Constraint.anchorToString(edge1)),
          FunctionCallExpression({
            "name": SwiftIdentifier("constraint"),
            "arguments": [
              FunctionCallArgument({
                "name": Some(SwiftIdentifier(Constraint.cmpToString(relation))),
                "value":
                  layerMemberExpression(
                    layer2,
                    [SwiftIdentifier(Constraint.anchorToString(edge2))]
                  )
              }),
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("constant")),
                "value": node
              })
            ]
          })
        ]
      )
    };
  let generateConstantFromConstraint = (constr: Constraint.t) =>
    Constraint.(
      switch constr {
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
          "leadingMargin"
        )
      | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
      | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) =>
        negateNumber(
          constraintConstantExpression(
            layer,
            "bottomPadding",
            child,
            "bottomMargin"
          )
        )
      | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
      | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) =>
        negateNumber(
          constraintConstantExpression(
            layer,
            "trailingPadding",
            child,
            "trailingMargin"
          )
        )
      | Relation(child, Top, _, previousLayer, Bottom, _, PrimaryBetween) =>
        constraintConstantExpression(
          previousLayer,
          "bottomMargin",
          child,
          "topMargin"
        )
      | Relation(child, Leading, _, previousLayer, Trailing, _, PrimaryBetween) =>
        constraintConstantExpression(
          previousLayer,
          "trailingMargin",
          child,
          "leadingMargin"
        )
      | Relation(child, Width, Leq, layer, Width, _, FitContentSecondary) =>
        negateNumber(
          BinaryExpression({
            "left":
              constraintConstantExpression(
                layer,
                "leadingPadding",
                child,
                "leadingMargin"
              ),
            "operator": "+",
            "right":
              constraintConstantExpression(
                layer,
                "trailingPadding",
                child,
                "trailingMargin"
              )
          })
        )
      | Relation(child, Height, Leq, layer, Height, _, FitContentSecondary) =>
        negateNumber(
          BinaryExpression({
            "left":
              constraintConstantExpression(
                layer,
                "topPadding",
                child,
                "topMargin"
              ),
            "operator": "+",
            "right":
              constraintConstantExpression(
                layer,
                "bottomPadding",
                child,
                "bottomMargin"
              )
          })
        )
      | Relation(_, _, _, _, _, _, FlexSibling) =>
        LiteralExpression(FloatingPoint(0.0))
      | Dimension((layer: Types.layer), Height, _, _) =>
        let constant = Layer.getNumberParameter("height", layer);
        LiteralExpression(FloatingPoint(constant));
      | Dimension((layer: Types.layer), Width, _, _) =>
        let constant = Layer.getNumberParameter("width", layer);
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
          SwiftFormat.layerName(layer.name) ++ Format.upperFirst(anchorString)
      )
      ++ suffix;
    };
    switch constr {
    | Relation(
        (layer1: Types.layer),
        edge1,
        _,
        (layer2: Types.layer),
        _,
        _,
        FlexSibling
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
    Constraint.getConstraints
      /* For the purposes of layouts, we want to swap the custom component layer
         with the root layer from the custom component's definition. We should
         use the parameters of the custom component's root layer, since these
         determine layout. We should still use the type, name, and children of
         the custom component layer. */
      (
        (layer: Types.layer, name) => {
          let component = getComponent(name);
          let rootLayer =
            component |> Decode.Component.rootLayer(getComponent);
          {
            typeName: layer.typeName,
            name: layer.name,
            parameters: rootLayer.parameters,
            children: layer.children
          };
        },
        rootLayer
      );
  let setUpConstraintsDoc = (root: Types.layer) => {
    let translatesAutoresizingMask = (layer: Types.layer) =>
      BinaryExpression({
        "left":
          layerMemberExpression(
            layer,
            [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")]
          ),
        "operator": "=",
        "right": LiteralExpression(Boolean(false))
      });
    let getInitialValue = constr =>
      generateConstraintWithInitialValue(
        constr,
        generateConstantFromConstraint(constr)
      );
    let defineConstraint = def =>
      ConstantDeclaration({
        "modifiers": [],
        "init": Some(getInitialValue(def)),
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier(formatConstraintVariableName(def)),
            "annotation": None
          })
      });
    let setConstraintPriority = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier(formatConstraintVariableName(def)),
            SwiftIdentifier("priority")
          ]),
        "operator": "=",
        "right":
          MemberExpression([
            SwiftDocument.layoutPriorityTypeDoc(swiftOptions.framework),
            SwiftIdentifier(priorityName(Constraint.getPriority(def)))
          ])
      });
    let activateConstraints = () =>
      FunctionCallExpression({
        "name":
          MemberExpression([
            SwiftIdentifier("NSLayoutConstraint"),
            SwiftIdentifier("activate")
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
                     )
                )
              )
          })
        ]
      });
    let assignConstraint = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier("self"),
            SwiftIdentifier(formatConstraintVariableName(def))
          ]),
        "operator": "=",
        "right": SwiftIdentifier(formatConstraintVariableName(def))
      });
    let assignConstraintIdentifier = def =>
      BinaryExpression({
        "left":
          MemberExpression([
            SwiftIdentifier(formatConstraintVariableName(def)),
            SwiftIdentifier("identifier")
          ]),
        "operator": "=",
        "right": LiteralExpression(String(formatConstraintVariableName(def)))
      });
    FunctionDeclaration({
      "name": "setUpConstraints",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        Document.joinGroups(
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
                ...constraints |> List.map(assignConstraintIdentifier)
              ] :
              []
          ]
        )
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
      ! Js.String.includes("margin", name)
      && ! Js.String.includes("padding", name);
    let conditionallyAssigned = Logic.conditionallyAssignedIdentifiers(logic);
    let filterConditionallyAssigned = (layer: Types.layer, (name, _)) => {
      let isAssigned = ((_, value)) => value == ["layers", layer.name, name];
      conditionallyAssigned |> Logic.IdentifierSet.exists(isAssigned);
    };
    let defineInitialLayerValues = ((layer, propertyMap)) =>
      propertyMap
      |> StringMap.bindings
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
          assignments
          |> Layer.LayerMap.bindings
          |> List.map(defineInitialLayerValues)
          |> List.concat
        )
        @ SwiftLogic.toSwiftAST(
            swiftOptions,
            colors,
            textStyles,
            rootLayer,
            logic
          )
    });
  };
  TopLevelDeclaration({
    "statements":
      Document.joinGroups(
        Empty,
        [
          [
            SwiftDocument.importFramework(swiftOptions.framework),
            ImportDeclaration("Foundation")
          ],
          helperClasses,
          [LineComment("MARK: - " ++ name)],
          [
            ClassDeclaration({
              "name": name,
              "inherits": [TypeName(Types.View |> getLayerTypeName)],
              "modifier": Some(PublicModifier),
              "isFinal": false,
              "body":
                Document.joinGroups(
                  Empty,
                  [
                    [Empty, LineComment("MARK: Lifecycle")],
                    [initializerDoc()],
                    parameters
                    |> List.filter(param => ! isFunctionParameter(param))
                    |> List.length > 0 ?
                      [convenienceInitializerDoc()] : [],
                    [initializerCoderDoc()],
                    needsTracking ? [AppkitPressable.deinitTrackingArea] : [],
                    List.length(parameters) > 0 ?
                      [LineComment("MARK: Public")] : [],
                    parameters |> List.map(parameterVariableDoc),
                    [LineComment("MARK: Private")],
                    needsTracking ? [AppkitPressable.trackingAreaVar] : [],
                    nonRootLayers |> List.map(viewVariableDoc),
                    textLayers |> List.map(textStyleVariableDoc),
                    rootLayer
                    |> Layer.flatmap(spacingVariableDoc)
                    |> List.concat,
                    pressableLayers
                    |> List.map(pressableVariableDoc)
                    |> List.concat,
                    constraints
                    |> List.map(def =>
                         constraintVariableDoc(
                           formatConstraintVariableName(def)
                         )
                       ),
                    [setUpViewsDoc(rootLayer)],
                    [setUpConstraintsDoc(rootLayer)],
                    [updateDoc()],
                    needsTracking ?
                      AppkitPressable.mouseTrackingFunctions(
                        rootLayer,
                        pressableLayers
                      ) :
                      []
                  ]
                )
            })
          ]
        ]
      )
  });
};