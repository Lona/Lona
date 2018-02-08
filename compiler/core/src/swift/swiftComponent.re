module Format = SwiftFormat;

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

let generate =
    (
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      name,
      colors,
      textStyles: TextStyle.file,
      json
    ) => {
  let rootLayer = json |> Decode.Component.rootLayer;
  /* Remove the root element */
  let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
  let logic = json |> Decode.Component.logic;
  let logic =
    Logic.enforceSingleAssignment(
      (_, path) => [
        "_" ++ Format.variableNameFromIdentifier(rootLayer.name, path)
      ],
      (_, path) =>
        Logic.Literal(LonaValue.defaultValueForParameter(List.nth(path, 2))),
      logic
    );
  let layerParameterAssignments =
    Layer.logicAssignmentsFromLayerParameters(rootLayer);
  let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
  let parameters = json |> Decode.Component.parameters;
  open Ast;
  let priorityName =
    fun
    | Constraint.Required => "required"
    | Low => "defaultLow";
  let typeAnnotationDoc =
    fun
    | Types.Reference(typeName) =>
      switch typeName {
      | "Boolean" => TypeName("Bool")
      | _ => TypeName(typeName)
      }
    | Named(name, _) => TypeName(name);
  let parameterVariableDoc = (parameter: Decode.parameter) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(parameter.name),
          "annotation": Some(parameter.ltype |> typeAnnotationDoc)
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
  let getLayerTypeName = layerType =>
    switch (swiftOptions.framework, layerType) {
    | (UIKit, Types.View) => "UIView"
    | (UIKit, Text) => "UILabel"
    | (UIKit, Image) => "UIImageView"
    | (AppKit, Types.View) => "NSBox"
    | (AppKit, Text) => "NSTextField"
    | (AppKit, Image) => "NSImageView"
    | _ => "TypeUnknown"
    };
  let getLayerInitCall = layerType => {
    let typeName = SwiftIdentifier(layerType |> getLayerTypeName);
    switch (swiftOptions.framework, layerType) {
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
    | _ => FunctionCallExpression({"name": typeName, "arguments": []})
    };
  };
  let viewVariableDoc = (layer: Types.layer) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(layer.name |> Format.layerName),
          "annotation": None /*Some(layer.typeName |> viewTypeDoc)*/
        }),
      "init": Some(getLayerInitCall(layer.typeName)),
      "block": None
    });
  let textStyleVariableDoc = (layer: Types.layer) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier((layer.name |> Format.layerName) ++ "TextStyle"),
          "annotation": None /* Some(TypeName("AttributedFont")) */
        }),
      "init":
        Some(
          MemberExpression([
            SwiftIdentifier("TextStyles"),
            SwiftIdentifier(textStyles.defaultStyle.id)
          ])
        ),
      "block": None
    });
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
        variable : Format.layerName(layer.name) ++ Format.upperFirst(variable);
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
  let initParameterDoc = (parameter: Decode.parameter) =>
    Parameter({
      "externalName": None,
      "localName": parameter.name,
      "annotation": parameter.ltype |> typeAnnotationDoc,
      "defaultValue": None
    });
  let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier("self"),
          SwiftIdentifier(parameter.name)
        ]),
      "operator": "=",
      "right": SwiftIdentifier(parameter.name)
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
      "parameters": parameters |> List.map(initParameterDoc),
      "failable": None,
      "body":
        Document.joinGroups(
          Empty,
          [
            parameters |> List.map(initParameterAssignmentDoc),
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
    parent === rootLayer ? "self" : parent.name |> Format.layerName;
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
      let logic =
        switch assignment {
        | None =>
          Logic.defaultAssignmentForLayerParameter(
            colors,
            textStyles,
            layer,
            name
          )
        | Some(assignment) => assignment
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
        && name != "width";
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
      switch layer.typeName {
      | View => [
          BinaryExpression({
            "left": layerMemberExpression(layer, [SwiftIdentifier("boxType")]),
            "operator": "=",
            "right": SwiftIdentifier(".custom")
          }),
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("borderType")]),
            "operator": "=",
            "right": SwiftIdentifier(".noBorder")
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
      | Text => [
          BinaryExpression({
            "left":
              layerMemberExpression(layer, [SwiftIdentifier("lineBreakMode")]),
            "operator": "=",
            "right": SwiftIdentifier(".byWordWrapping")
          })
        ]
      | _ => []
      };
    let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
      switch parent {
      | None => []
      | Some(parent) => [
          FunctionCallExpression({
            "name":
              layerMemberExpression(parent, [SwiftIdentifier("addSubview")]),
            "arguments": [SwiftIdentifier(layer.name |> Format.layerName)]
          })
        ]
      };
    FunctionDeclaration({
      "name": "setUpViews",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [],
      "result": None,
      "body":
        Document.joinGroups(
          Empty,
          [
            swiftOptions.framework == SwiftOptions.AppKit ?
              Layer.flatmap(resetViewStyling, root) |> List.concat : [],
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
        variable : Format.layerName(layer.name) ++ Format.upperFirst(variable);
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
      | _ => raise(Not_found)
      }
    );
  let formatConstraintVariableName = (constr: Constraint.t) => {
    open Constraint;
    let formatAnchorVariableName = (layer: Types.layer, anchor, suffix) => {
      let anchorString = Constraint.anchorToString(anchor);
      (
        layer === rootLayer ?
          anchorString :
          Format.layerName(layer.name) ++ Format.upperFirst(anchorString)
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
      Format.layerName(layer1.name)
      ++ Format.upperFirst(Format.layerName(layer2.name))
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
  let constraints = Constraint.getConstraints(rootLayer);
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
      "body":
        List.concat([
          root |> Layer.flatmap(translatesAutoresizingMask),
          [Empty],
          constraints |> List.map(defineConstraint),
          constraints
          |> List.filter(def => Constraint.getPriority(def) == Low)
          |> List.map(setConstraintPriority),
          [Empty],
          [activateConstraints()],
          [Empty],
          constraints |> List.map(assignConstraint),
          [Empty, LineComment("For debugging")],
          constraints |> List.map(assignConstraintIdentifier)
        ])
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
  let textLayers =
    nonRootLayers
    |> List.filter((layer: Types.layer) => layer.typeName == Types.Text);
  TopLevelDeclaration({
    "statements": [
      SwiftDocument.importFramework(swiftOptions.framework),
      ImportDeclaration("Foundation"),
      Empty,
      LineComment("MARK: - " ++ name),
      Empty,
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
              [initializerCoderDoc()],
              List.length(parameters) > 0 ? [LineComment("MARK: Public")] : [],
              parameters |> List.map(parameterVariableDoc),
              [LineComment("MARK: Private")],
              nonRootLayers |> List.map(viewVariableDoc),
              textLayers |> List.map(textStyleVariableDoc),
              rootLayer |> Layer.flatmap(spacingVariableDoc) |> List.concat,
              constraints
              |> List.map(def =>
                   constraintVariableDoc(formatConstraintVariableName(def))
                 ),
              [setUpViewsDoc(rootLayer)],
              [setUpConstraintsDoc(rootLayer)],
              [updateDoc()]
            ]
          )
      }),
      Empty
    ]
  });
};