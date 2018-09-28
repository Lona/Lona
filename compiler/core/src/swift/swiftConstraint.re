let negateNumber = expression =>
  SwiftAst.PrefixExpression({"operator": "-", "expression": expression});

let priorityName =
  fun
  | Constraint.Required => "required"
  | Low => "defaultLow";

let constantExpression =
    (
      rootLayer: Types.layer,
      layer: Types.layer,
      variable1,
      parent: Types.layer,
      variable2,
    ) => {
  let variableName = (layer: Types.layer, variable) =>
    layer === rootLayer ?
      variable :
      SwiftFormat.layerName(layer.name) ++ Format.upperFirst(variable);
  SwiftAst.(
    BinaryExpression({
      "left": SwiftIdentifier(variableName(layer, variable1)),
      "operator": "+",
      "right": SwiftIdentifier(variableName(parent, variable2)),
    })
  );
};

let generateWithInitialValue =
    (layerMemberExpression, constr: Constraint.t, node) =>
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
    }
  );

let generateConstantFromConstraint =
    (rootLayer: Types.layer, constr: Constraint.t) =>
  SwiftAst.(
    Constraint.(
      switch (constr) {
      /* Currently centering doesn't require any constants, since a centered view also
         has a pair of before/after constraints that include the constants */
      | Relation(_, CenterX, _, _, CenterX, _, _)
      | Relation(_, CenterY, _, _, CenterY, _, _) =>
        LiteralExpression(FloatingPoint(0.0))
      | Relation(child, Top, _, layer, Top, _, PrimaryBefore)
      | Relation(child, Top, _, layer, Top, _, SecondaryBefore) =>
        constantExpression(rootLayer, layer, "topPadding", child, "topMargin")
      | Relation(child, Leading, _, layer, Leading, _, PrimaryBefore)
      | Relation(child, Leading, _, layer, Leading, _, SecondaryBefore) =>
        constantExpression(
          rootLayer,
          layer,
          "leadingPadding",
          child,
          "leadingMargin",
        )
      | Relation(child, Bottom, _, layer, Bottom, _, PrimaryAfter)
      | Relation(child, Bottom, _, layer, Bottom, _, SecondaryAfter) =>
        negateNumber(
          constantExpression(
            rootLayer,
            layer,
            "bottomPadding",
            child,
            "bottomMargin",
          ),
        )
      | Relation(child, Trailing, _, layer, Trailing, _, SecondaryAfter)
      | Relation(child, Trailing, _, layer, Trailing, _, PrimaryAfter) =>
        negateNumber(
          constantExpression(
            rootLayer,
            layer,
            "trailingPadding",
            child,
            "trailingMargin",
          ),
        )
      | Relation(child, Top, _, previousLayer, Bottom, _, PrimaryBetween) =>
        constantExpression(
          rootLayer,
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
        constantExpression(
          rootLayer,
          previousLayer,
          "trailingMargin",
          child,
          "leadingMargin",
        )
      | Relation(child, Width, Leq, layer, Width, _, FitContentSecondary) =>
        negateNumber(
          BinaryExpression({
            "left":
              constantExpression(
                rootLayer,
                layer,
                "leadingPadding",
                child,
                "leadingMargin",
              ),
            "operator": "+",
            "right":
              constantExpression(
                rootLayer,
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
              constantExpression(
                rootLayer,
                layer,
                "topPadding",
                child,
                "topMargin",
              ),
            "operator": "+",
            "right":
              constantExpression(
                rootLayer,
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
    )
  );

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
      getComponent,
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
  let getInitialValue = constr =>
    generateWithInitialValue(
      layerMemberExpression,
      constr,
      generateConstantFromConstraint(root, constr),
    );
  let defineConstraint = def =>
    ConstantDeclaration({
      "modifiers": [],
      "init": Some(getInitialValue(def)),
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(formatConstraintVariableName(root, def)),
          "annotation": None,
        }),
    });
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