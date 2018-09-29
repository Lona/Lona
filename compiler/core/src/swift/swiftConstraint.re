let negateNumber = expression =>
  SwiftAst.PrefixExpression({"operator": "-", "expression": expression});

let priorityName =
  fun
  | Constraint.Required => "required"
  | Low => "defaultLow";

let constantExpression =
    (
      swiftOptions: SwiftOptions.options,
      colors,
      textStyles,
      assignmentsFromLayerParameters,
      rootLayer: Types.layer,
      layer: Types.layer,
      variable1: ParameterKey.t,
      parent: Types.layer,
      variable2: ParameterKey.t,
    )
    : option(SwiftAst.node) => {
  let variableName = (layer: Types.layer, variable: ParameterKey.t) => {
    let variableNameString = variable |> ParameterKey.toString;

    layer === rootLayer ?
      variableNameString :
      SwiftFormat.layerName(layer.name)
      ++ Format.upperFirst(variableNameString);
  };

  switch (
    SwiftComponentParameter.get(layer, variable1),
    SwiftComponentParameter.get(layer, variable2),
  ) {
  | (None, None) => None
  | (Some(a), None)
  | (None, Some(a)) =>
    Some(
      SwiftDocument.lonaValue(swiftOptions.framework, colors, textStyles, a),
    )
  | (Some(a), Some(b)) =>
    Some(
      SwiftAst.(
        BinaryExpression({
          "left":
            SwiftDocument.lonaValue(
              swiftOptions.framework,
              colors,
              textStyles,
              a,
            ),
          "operator": "+",
          "right":
            SwiftDocument.lonaValue(
              swiftOptions.framework,
              colors,
              textStyles,
              b,
            ),
        })
      ),
    )
  };
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
            "arguments":
              switch (constantAst) {
              | None => []
              | Some(ast) => [
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("equalToConstant")),
                    "value": ast,
                  }),
                ]
              },
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
        {layer, key: PaddingTop},
        {layer: child, key: MarginTop},
      ]
    | Relation(child, Leading, _, layer, Leading, _, PrimaryBefore)
    | Relation(child, Leading, _, layer, Leading, _, SecondaryBefore) => [
        {layer, key: PaddingLeft},
        {layer: child, key: MarginLeft},
      ]
    | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
    | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) => [
        {layer, key: PaddingBottom},
        {layer: child, key: MarginBottom},
      ]
    | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
    | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) => [
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
        {layer, key: PaddingLeft},
        {layer: child, key: MarginLeft},
        {layer, key: PaddingRight},
        {layer: child, key: MarginRight},
      ]
    | Relation(child, Height, Leq, layer, Height, _, FitContentSecondary) => [
        {layer, key: PaddingTop},
        {layer: child, key: MarginTop},
        {layer, key: PaddingBottom},
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

let generateConstantFromConstraint =
    (
      swiftOptions: SwiftOptions.options,
      colors,
      textStyles,
      assignmentsFromLayerParameters,
      rootLayer: Types.layer,
      constr: Constraint.t,
    )
    : option(SwiftAst.node) => {
  let constantExpression =
    constantExpression(
      swiftOptions,
      colors,
      textStyles,
      assignmentsFromLayerParameters,
      rootLayer,
    );

  SwiftAst.(
    Constraint.(
      switch (constr) {
      /* Currently centering doesn't require any constants, since a centered view also
         has a pair of before/after constraints that include the constants */
      | Relation(_, CenterX, _, _, CenterX, _, _)
      | Relation(_, CenterY, _, _, CenterY, _, _) => None
      | Relation(child, Top, _, layer, Top, _, PrimaryBefore)
      | Relation(child, Top, _, layer, Top, _, SecondaryBefore) =>
        constantExpression(
          layer,
          ParameterKey.PaddingTop,
          child,
          ParameterKey.MarginTop,
        )
      | Relation(child, Leading, _, layer, Leading, _, PrimaryBefore)
      | Relation(child, Leading, _, layer, Leading, _, SecondaryBefore) =>
        constantExpression(
          layer,
          ParameterKey.PaddingLeft,
          child,
          ParameterKey.MarginLeft,
        )
      | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
      | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) =>
        let expression =
          constantExpression(
            layer,
            ParameterKey.PaddingBottom,
            child,
            ParameterKey.MarginBottom,
          );
        switch (expression) {
        | Some(e) => Some(negateNumber(e))
        | None => None
        };
      | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
      | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) =>
        let expression =
          constantExpression(
            layer,
            ParameterKey.PaddingRight,
            child,
            ParameterKey.MarginRight,
          );
        switch (expression) {
        | Some(e) => Some(negateNumber(e))
        | None => None
        };
      | Relation(child, Top, _, previousLayer, Bottom, _, PrimaryBetween) =>
        constantExpression(
          previousLayer,
          ParameterKey.MarginBottom,
          child,
          ParameterKey.MarginTop,
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
        constantExpression(
          previousLayer,
          ParameterKey.MarginRight,
          child,
          ParameterKey.MarginLeft,
        )
      | Relation(child, Width, Leq, layer, Width, _, FitContentSecondary) =>
        let leftExpression =
          constantExpression(
            layer,
            ParameterKey.PaddingLeft,
            child,
            ParameterKey.MarginLeft,
          );

        let rightExpression =
          constantExpression(
            layer,
            ParameterKey.PaddingRight,
            child,
            ParameterKey.MarginRight,
          );

        switch (leftExpression, rightExpression) {
        | (None, None) => None
        | (Some(a), None)
        | (None, Some(a)) => Some(negateNumber(a))
        | (Some(a), Some(b)) =>
          Some(
            negateNumber(
              BinaryExpression({"left": a, "operator": "+", "right": b}),
            ),
          )
        };
      | Relation(child, Height, Leq, layer, Height, _, FitContentSecondary) =>
        let leftExpression =
          constantExpression(
            layer,
            ParameterKey.PaddingTop,
            child,
            ParameterKey.MarginTop,
          );

        let rightExpression =
          constantExpression(
            layer,
            ParameterKey.PaddingBottom,
            child,
            ParameterKey.MarginBottom,
          );

        switch (leftExpression, rightExpression) {
        | (None, None) => None
        | (Some(a), None)
        | (None, Some(a)) => Some(negateNumber(a))
        | (Some(a), Some(b)) =>
          Some(
            negateNumber(
              BinaryExpression({"left": a, "operator": "+", "right": b}),
            ),
          )
        };

      | Relation(_, _, _, _, _, _, FlexSibling) => None
      | Dimension((layer: Types.layer), Height, _, _) =>
        let constant = Layer.getNumberParameter(Height, layer);
        Some(LiteralExpression(FloatingPoint(constant)));
      | Dimension((layer: Types.layer), Width, _, _) =>
        let constant = Layer.getNumberParameter(Width, layer);
        Some(LiteralExpression(FloatingPoint(constant)));
      | _ =>
        Js.log("Unknown constraint types");
        raise(Not_found);
      }
    )
  );
};

let formatConstraintVariableName =
    (rootLayer: Types.layer, constr: Constraint.t) => {
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

let calculateConstraints = (getComponent, rootLayer: Types.layer) =>
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

let setUpFunction =
    (
      swiftOptions: SwiftOptions.options,
      colors,
      textStyles,
      getComponent,
      assignmentsFromLayerParameters,
      assignmentsFromLogic,
      layerMemberExpression,
      root: Types.layer,
    ) => {
  open SwiftAst;
  let constraints = calculateConstraints(getComponent, root);
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
  let defineConstraint = def => {
    let constant =
      generateConstantFromConstraint(
        swiftOptions,
        colors,
        textStyles,
        assignmentsFromLayerParameters,
        root,
        def,
      );
    ConstantDeclaration({
      "modifiers": [],
      "init":
        Some(generateWithInitialValue(layerMemberExpression, def, constant)),
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(formatConstraintVariableName(root, def)),
          "annotation": None,
        }),
    });
  };
  let setConstraintPriority = def =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier(formatConstraintVariableName(root, def)),
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
                     SwiftIdentifier(formatConstraintVariableName(root, def))
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
          SwiftIdentifier(formatConstraintVariableName(root, def)),
        ]),
      "operator": "=",
      "right": SwiftIdentifier(formatConstraintVariableName(root, def)),
    });
  let assignConstraintIdentifier = def =>
    BinaryExpression({
      "left":
        MemberExpression([
          SwiftIdentifier(formatConstraintVariableName(root, def)),
          SwiftIdentifier("identifier"),
        ]),
      "operator": "=",
      "right":
        LiteralExpression(String(formatConstraintVariableName(root, def))),
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
          constraints
          |> List.filter(isDynamic(assignmentsFromLogic))
          |> List.map(assignConstraint),
          swiftOptions.debugConstraints && List.length(constraints) > 0 ?
            [
              LineComment("For debugging"),
              ...constraints |> List.map(assignConstraintIdentifier),
            ] :
            [],
        ],
      ),
  });
};