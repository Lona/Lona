let negateNumber = expression =>
  SwiftAst.PrefixExpression({"operator": "-", "expression": expression});

let priorityValue = (config: Config.t, priority): SwiftAst.node =>
  switch (priority) {
  | Constraint.Required =>
    SwiftAst.memberExpression([
      SwiftDocument.layoutPriorityTypeDoc(config.options.swift.framework),
      SwiftIdentifier("required"),
    ])
  | LowPlus1 =>
    BinaryExpression({
      "left":
        SwiftAst.memberExpression([
          SwiftDocument.layoutPriorityTypeDoc(config.options.swift.framework),
          SwiftIdentifier("defaultLow"),
        ]),
      "operator": "+",
      "right": SwiftAst.LiteralExpression(Integer(1)),
    })
  | Low =>
    SwiftAst.memberExpression([
      SwiftDocument.layoutPriorityTypeDoc(config.options.swift.framework),
      SwiftIdentifier("defaultLow"),
    ])
  };

let generateWithInitialValue =
    (
      layerMemberExpression,
      constr: Constraint.t,
      constantAst: option(SwiftAst.node),
    ) =>
  SwiftAst.(
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
                "value":
                  switch (constantAst) {
                  | None => LiteralExpression(FloatingPoint(0.0))
                  | Some(ast) => ast
                  },
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
            "arguments":
              [
                FunctionCallArgument({
                  "name":
                    Some(SwiftIdentifier(Constraint.cmpToString(relation))),
                  "value":
                    layerMemberExpression(
                      layer2,
                      [SwiftIdentifier(Constraint.anchorToString(edge2))],
                    ),
                }),
              ]
              @ (
                switch (constantAst) {
                | None => []
                | Some(ast) => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("constant")),
                      "value": ast,
                    }),
                  ]
                }
              ),
          }),
        ],
      )
    }
  );

type constraintDependency = {
  layer: Types.layer,
  key: ParameterKey.t,
};

let constraintDependencies =
    (constr: Constraint.t): list(constraintDependency) =>
  Constraint.(
    switch (constr) {
    | Relation(_, CenterX, _, _, CenterX, _, _)
    | Relation(_, CenterY, _, _, CenterY, _, _) => []
    | Relation(child, Top, _, layer, Top, _, PrimaryBefore)
    | Relation(child, Top, _, layer, Top, _, SecondaryBefore) => [
        {layer, key: BorderWidth},
        {layer, key: PaddingTop},
        {layer: child, key: MarginTop},
      ]
    | Relation(child, Leading, _, layer, Leading, _, PrimaryBefore)
    | Relation(child, Leading, _, layer, Leading, _, SecondaryBefore) => [
        {layer, key: BorderWidth},
        {layer, key: PaddingLeft},
        {layer: child, key: MarginLeft},
      ]
    | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
    | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) => [
        {layer, key: BorderWidth},
        {layer, key: PaddingBottom},
        {layer: child, key: MarginBottom},
      ]
    | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
    | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) => [
        {layer, key: BorderWidth},
        {layer, key: PaddingRight},
        {layer: child, key: MarginRight},
      ]
    | Relation(child, Top, _, previousLayer, Bottom, _, PrimaryBetween) => [
        {layer: previousLayer, key: MarginBottom},
        {layer: child, key: MarginTop},
      ]
    | Relation(child, Leading, _, previousLayer, Trailing, _, PrimaryBetween) => [
        {layer: previousLayer, key: MarginRight},
        {layer: child, key: MarginLeft},
      ]
    | Relation(child, Width, Leq, layer, Width, _, FitContentSecondary) => [
        {layer, key: BorderWidth},
        {layer, key: BorderWidth},
        {layer, key: PaddingLeft},
        {layer, key: PaddingRight},
        {layer: child, key: MarginLeft},
        {layer: child, key: MarginRight},
      ]
    | Relation(child, Height, Leq, layer, Height, _, FitContentSecondary) => [
        {layer, key: BorderWidth},
        {layer, key: BorderWidth},
        {layer, key: PaddingTop},
        {layer, key: PaddingBottom},
        {layer: child, key: MarginTop},
        {layer: child, key: MarginBottom},
      ]
    | Relation(_, _, _, _, _, _, FlexSibling) => []
    | Dimension(layer, Height, _, _) => [{layer, key: Height}]
    | Dimension(layer, Width, _, _) => [{layer, key: Width}]
    | _ =>
      Js.log("Unknown constraint types");
      raise(Not_found);
    }
  );

let isValueNegated = (constr: Constraint.t): bool =>
  Constraint.(
    switch (constr) {
    | Relation(_, CenterX, _, _, CenterX, _, _)
    | Relation(_, CenterY, _, _, CenterY, _, _) => false
    | Relation(_child, Top, _, _layer, Top, _, PrimaryBefore)
    | Relation(_child, Top, _, _layer, Top, _, SecondaryBefore) => false
    | Relation(_child, Leading, _, _layer, Leading, _, PrimaryBefore)
    | Relation(_child, Leading, _, _layer, Leading, _, SecondaryBefore) =>
      false
    | Relation(_child, Bottom, _, _layer, Bottom, _, PrimaryAfter)
    | Relation(_child, Bottom, _, _layer, Bottom, _, SecondaryAfter) => true
    | Relation(_child, Trailing, _, _layer, Trailing, _, SecondaryAfter)
    | Relation(_child, Trailing, _, _layer, Trailing, _, PrimaryAfter) => true
    | Relation(_child, Top, _, _previousLayer, Bottom, _, PrimaryBetween) =>
      false
    | Relation(
        _child,
        Leading,
        _,
        _previousLayer,
        Trailing,
        _,
        PrimaryBetween,
      ) =>
      false
    | Relation(_child, Width, Leq, _layer, Width, _, FitContentSecondary) =>
      true
    | Relation(_child, Height, Leq, _layer, Height, _, FitContentSecondary) =>
      true
    | Relation(_, _, _, _, _, _, FlexSibling) => false
    | Dimension(_layer, Height, _, _) => false
    | Dimension(_layer, Width, _, _) => false
    | _ =>
      Js.log("Unknown constraint types");
      raise(Not_found);
    }
  );

/* Can this constraint be updated in logic? */
let isDynamic = (assignments, constr: Constraint.t) => {
  let dependencies = constraintDependencies(constr);

  let isAssigned = dependency =>
    SwiftComponentParameter.isAssigned(
      assignments,
      dependency.layer,
      dependency.key,
    );

  dependencies |> List.exists(isAssigned);
};

let generateConstraintConstant =
    (
      swiftOptions: SwiftOptions.options,
      config: Config.t,
      constr: Constraint.t,
    )
    : option(SwiftAst.node) => {
  let dependencies = constraintDependencies(constr);
  let direction = isValueNegated(constr) ? (-1.0) : 1.0;

  let lonaValues =
    dependencies
    |> List.map((dependency: constraintDependency) =>
         switch (
           SwiftComponentParameter.get(dependency.layer, dependency.key)
         ) {
         | None => []
         | Some(value) => [value]
         }
       )
    |> List.concat;

  switch (lonaValues) {
  | [] => None
  | [value] =>
    let float = value |> LonaValue.decodeNumber;
    let float = float *. direction;
    float == 0.0 ?
      None : Some(SwiftDocument.lonaValue(config, LonaValue.number(float)));
  | _ =>
    let floats = lonaValues |> List.map(LonaValue.decodeNumber);
    let float = List.fold_left((a, b) => a +. b, 0.0, floats);
    let float = float *. direction;
    float == 0.0 ?
      None : Some(SwiftDocument.lonaValue(config, LonaValue.number(float)));
  };
};

let formatConstraintVariableName =
    (
      combinations: list(Constraint.visibilityCombination),
      rootLayer: Types.layer,
      const: Constraint.t,
    ) => {
  open Constraint;

  let verbose = !Constraint.isAlwaysActivated(combinations, const);

  let formatAnchorVariableName = (layer: Types.layer, anchor) => {
    let anchorString = Constraint.anchorToString(anchor);
    Layer.equal(layer, rootLayer) ?
      anchorString :
      SwiftFormat.layerName(layer.name) ++ Format.upperFirst(anchorString);
  };
  switch (const) {
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
    formatAnchorVariableName(layer1, edge1) ++ "ParentConstraint"
  | Relation(
      (layer1: Types.layer),
      edge1,
      _,
      (layer2: Types.layer),
      edge2,
      _,
      _,
    ) =>
    if (verbose) {
      formatAnchorVariableName(layer1, edge1)
      ++ Format.upperFirst(formatAnchorVariableName(layer2, edge2))
      ++ "Constraint";
    } else {
      formatAnchorVariableName(layer1, edge1) ++ "Constraint";
    }
  | Dimension((layer: Types.layer), dimension, _, _) =>
    formatAnchorVariableName(layer, dimension) ++ "Constraint"
  };
};

let isFillTextLayer = (parent: option(Types.layer), layer: Types.layer): bool => {
  let layout = Layer.getLayout(parent, layer.parameters);
  switch (layer.typeName, layout.width) {
  | (Text, Fill) => true
  | _ => false
  };
};

let setUpFunction =
    (
      swiftOptions: SwiftOptions.options,
      config: Config.t,
      assignmentsFromLogic,
      layerMemberExpression,
      rootLayer: Types.layer,
    ) => {
  open SwiftAst;

  let combinations =
    Constraint.visibilityCombinations(
      config,
      assignmentsFromLogic,
      rootLayer,
    );

  let visibilityLayers =
    Constraint.visibilityLayers(assignmentsFromLogic, rootLayer)
    |> List.sort(Layer.compare);

  let setContentCompressionResistance = (layer, value, axis) =>
    FunctionCallExpression({
      "name":
        layerMemberExpression(
          layer,
          [SwiftIdentifier("setContentCompressionResistancePriority")],
        ),
      "arguments": [
        FunctionCallArgument({name: None, value}),
        FunctionCallArgument({
          name: Some(SwiftIdentifier("for")),
          value: axis,
        }),
      ],
    });

  let setContentHuggingPriority = (layer, value, axis) =>
    FunctionCallExpression({
      "name":
        layerMemberExpression(
          layer,
          [SwiftIdentifier("setContentHuggingPriority")],
        ),
      "arguments": [
        FunctionCallArgument({name: None, value}),
        FunctionCallArgument({
          name: Some(SwiftIdentifier("for")),
          value: axis,
        }),
      ],
    });

  let intrinsicSizeConstraints =
    rootLayer
    |> Layer.flatmapParent((parent: option(Types.layer), layer: Types.layer) =>
         switch (layer.typeName) {
         | Text =>
           let layout = Layer.getLayout(parent, layer.parameters);
           let widthPriority =
             switch (layout.width) {
             | Fill => ".defaultLow"
             | FitContent => ".defaultHigh"
             | Fixed(_) => ".defaultHigh"
             };
           let heightPriority =
             switch (layout.height) {
             | Fill => ".defaultLow"
             | FitContent => ".defaultHigh"
             | Fixed(_) => ".defaultHigh"
             };
           [
             setContentCompressionResistance(
               layer,
               SwiftIdentifier(widthPriority),
               SwiftIdentifier(".horizontal"),
             ),
             setContentHuggingPriority(
               layer,
               SwiftIdentifier(widthPriority),
               SwiftIdentifier(".horizontal"),
             ),
             setContentCompressionResistance(
               layer,
               SwiftIdentifier(heightPriority),
               SwiftIdentifier(".vertical"),
             ),
             setContentHuggingPriority(
               layer,
               SwiftIdentifier(heightPriority),
               SwiftIdentifier(".vertical"),
             ),
           ];
         | _ => []
         }
       )
    |> List.concat;

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
  let defineConstraint = const => {
    let constant = generateConstraintConstant(swiftOptions, config, const);
    ConstantDeclaration({
      "modifiers": [],
      "init":
        Some(
          generateWithInitialValue(layerMemberExpression, const, constant),
        ),
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              formatConstraintVariableName(combinations, rootLayer, const),
            ),
          "annotation": None,
        }),
    });
  };
  let setConstraintPriority = const =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier(
            formatConstraintVariableName(combinations, rootLayer, const),
          ),
          SwiftIdentifier("priority"),
        ]),
      "operator": "=",
      "right": priorityValue(config, Constraint.getPriority(const)),
    });
  let initialConditionalConstraints =
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
    });
  let activateConstraints = () => {
    let activated =
      LiteralExpression(
        Array(
          Constraint.alwaysConstraints(combinations)
          |> List.map(const =>
               SwiftIdentifier(
                 formatConstraintVariableName(combinations, rootLayer, const),
               )
             ),
        ),
      );
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
            if (visibilityLayers == []) {
              activated;
            } else {
              BinaryExpression({
                "left": activated,
                "operator": "+",
                "right": initialConditionalConstraints,
              });
            },
        }),
      ],
    });
  };
  let assignConstraint = const =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier("self"),
          SwiftIdentifier(
            formatConstraintVariableName(combinations, rootLayer, const),
          ),
        ]),
      "operator": "=",
      "right":
        SwiftIdentifier(
          formatConstraintVariableName(combinations, rootLayer, const),
        ),
    });
  let assignConstraintIdentifier = const =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier(
            formatConstraintVariableName(combinations, rootLayer, const),
          ),
          SwiftIdentifier("identifier"),
        ]),
      "operator": "=",
      "right":
        LiteralExpression(
          String(
            formatConstraintVariableName(combinations, rootLayer, const),
          ),
        ),
    });

  let allConstraints = Constraint.allConstraints(combinations);
  let alwaysConstraints = Constraint.alwaysConstraints(combinations);
  let conditionalConstraints =
    Constraint.conditionalConstraints(combinations);

  FunctionDeclaration({
    "name": "setUpConstraints",
    "attributes": [],
    "modifiers": [AccessLevelModifier(PrivateModifier)],
    "parameters": [],
    "result": None,
    "throws": false,
    "body":
      SwiftDocument.joinGroups(
        Empty,
        [
          rootLayer |> Layer.flatmap(translatesAutoresizingMask),
          intrinsicSizeConstraints,
          allConstraints |> List.map(defineConstraint),
          /* Priority */
          allConstraints
          |> List.filter(const => Constraint.getPriority(const) != Required)
          |> List.map(setConstraintPriority),
          /* Assign to member variables */
          conditionalConstraints |> List.map(assignConstraint),
          alwaysConstraints
          |> List.filter(isDynamic(assignmentsFromLogic))
          |> List.map(assignConstraint),
          /* Activation */
          List.length(alwaysConstraints) > 0 ? [activateConstraints()] : [],
          /* Debug identifiers */
          swiftOptions.debugConstraints && List.length(allConstraints) > 0 ?
            [
              LineComment("For debugging"),
              ...allConstraints |> List.map(assignConstraintIdentifier),
            ] :
            [],
        ],
      ),
  });
};

/* Each combination of view visibility must return the layout constraints
   necessary for the visible views.

   Generate the following:

   private func conditionalConstraints(titleViewIsHidden: Bool) -> [NSLayoutConstraint] {
     var constraints: [NSLayoutConstraint?] = []

     switch (titleViewIsHidden) {
     case (true):
       constraints = [
         bottomViewTopAnchorInnerViewBottomAnchorConstraint
       ]
     case (false):
       constraints = [
         titleViewTopAnchorInnerViewBottomAnchorConstraint,
       ]
     }

     return constraints.compactMap({ $0 })
   } */
let conditionalConstraintsFunction =
    (getComponent, assignmentsFromLogic, rootLayer: Types.layer) => {
  open SwiftAst;

  let combinations =
    Constraint.visibilityCombinations(
      getComponent,
      assignmentsFromLogic,
      rootLayer,
    );

  let visibilityLayers =
    Constraint.visibilityLayers(assignmentsFromLogic, rootLayer)
    |> List.sort(Layer.compare);

  FunctionDeclaration({
    "name": "conditionalConstraints",
    "attributes": [],
    "modifiers": [AccessLevelModifier(PrivateModifier)],
    "parameters":
      visibilityLayers
      |> List.map((layer: Types.layer) =>
           Parameter({
             "externalName": None,
             "localName": SwiftFormat.layerName(layer.name) ++ "IsHidden",
             "defaultValue": None,
             "annotation": TypeName("Bool"),
           })
         ),
    "result": Some(ArrayType(TypeName("NSLayoutConstraint"))),
    "throws": false,
    "body": [
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("constraints"),
            "annotation":
              Some(
                ArrayType(OptionalType(TypeName("NSLayoutConstraint"))),
              ),
          }),
        "init": None,
        "block": None,
      }),
      Empty,
      SwitchStatement({
        "expression":
          TupleExpression(
            visibilityLayers
            |> List.map((layer: Types.layer) =>
                 SwiftIdentifier(
                   SwiftFormat.layerName(layer.name) ++ "IsHidden",
                 )
               ),
          ),
        "cases":
          combinations
          |> List.map((combination: Constraint.visibilityCombination) =>
               CaseLabel({
                 "patterns": [
                   TuplePattern(
                     visibilityLayers
                     |> List.map((layer: Types.layer) =>
                          ExpressionPattern({
                            "value":
                              LiteralExpression(
                                Boolean(
                                  List.exists(
                                    other => Layer.equal(other, layer),
                                    combination.visibleLayers,
                                  ),
                                ),
                              ),
                          })
                        ),
                   ),
                 ],
                 "statements": [
                   BinaryExpression({
                     "left": SwiftIdentifier("constraints"),
                     "operator": "=",
                     "right":
                       LiteralExpression(
                         Array(
                           combination.constraints
                           |> List.filter((const: Constraint.t) =>
                                !
                                  Constraint.isAlwaysActivated(
                                    combinations,
                                    const,
                                  )
                              )
                           |> List.map((const: Constraint.t) =>
                                SwiftIdentifier(
                                  formatConstraintVariableName(
                                    combinations,
                                    rootLayer,
                                    const,
                                  ),
                                )
                              ),
                         ),
                       ),
                   }),
                 ],
               })
             ),
      }),
      Empty,
      ReturnStatement(
        Some(
          FunctionCallExpression({
            "name":
              SwiftAst.Builders.memberExpression([
                "constraints",
                "compactMap",
              ]),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value": CodeBlock({"statements": [SwiftIdentifier("$0")]}),
              }),
            ],
          }),
        ),
      ),
    ],
  });
};

let layoutSubviewsFunction =
    (_config: Config.t, layerMemberExpression, rootLayer: Types.layer)
    : SwiftAst.node =>
  SwiftAst.(
    FunctionDeclaration({
      "name": "layoutSubviews",
      "attributes": [],
      "modifiers": [OverrideModifier, AccessLevelModifier(PublicModifier)],
      "parameters": [],
      "result": None,
      "throws": false,
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            [Builders.functionCall(["super", "layoutSubviews"], [])],
            rootLayer
            |> Layer.flatmapParent((parent, layer) =>
                 if (isFillTextLayer(parent, layer)) {
                   [
                     /* if subtitleView.preferredMaxLayoutWidth != subtitleView.bounds.width {
                            subtitleView.preferredMaxLayoutWidth = subtitleView.bounds.width
                        } */
                     IfStatement({
                       "condition":
                         BinaryExpression({
                           "left":
                             layerMemberExpression(
                               layer,
                               [SwiftIdentifier("preferredMaxLayoutWidth")],
                             ),
                           "operator": "!=",
                           "right":
                             layerMemberExpression(
                               layer,
                               [
                                 SwiftIdentifier("bounds"),
                                 SwiftIdentifier("width"),
                               ],
                             ),
                         }),
                       "block": [
                         BinaryExpression({
                           "left":
                             layerMemberExpression(
                               layer,
                               [SwiftIdentifier("preferredMaxLayoutWidth")],
                             ),
                           "operator": "=",
                           "right":
                             layerMemberExpression(
                               layer,
                               [
                                 SwiftIdentifier("bounds"),
                                 SwiftIdentifier("width"),
                               ],
                             ),
                         }),
                       ],
                     }),
                   ];
                 } else {
                   [];
                 }
               )
            |> List.concat,
          ],
        ),
    })
  );