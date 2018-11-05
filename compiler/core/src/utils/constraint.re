type layoutPriority =
  | Required
  | Low;

type anchor =
  | Width
  | Height
  | Top
  | Bottom
  | Leading
  | Trailing
  | CenterX
  | CenterY;

type cmp =
  | Eq
  | Geq
  | Leq;

type role =
  | PrimaryBefore
  | PrimaryBetween
  | PrimaryAfter
  | PrimaryCenter
  | SecondaryBefore
  | SecondaryAfter
  | SecondaryCenter
  | FitContentSecondary
  | FlexSibling
  | PrimaryDimension
  | SecondaryDimension;

type t =
  | Dimension(Types.layer, anchor, layoutPriority, role)
  | Relation(
      Types.layer,
      anchor,
      cmp,
      Types.layer,
      anchor,
      layoutPriority,
      role,
    );

type visibilityCombination = {
  rootLayer: Types.layer,
  visibleLayers: list(Types.layer),
  constraints: list(t),
};

let anchorToString =
  fun
  | Top => "topAnchor"
  | Bottom => "bottomAnchor"
  | Leading => "leadingAnchor"
  | Trailing => "trailingAnchor"
  | CenterX => "centerXAnchor"
  | CenterY => "centerYAnchor"
  | Width => "widthAnchor"
  | Height => "heightAnchor";

let anchorFromString =
  fun
  | "topAnchor" => Top
  | "bottomAnchor" => Bottom
  | "leadingAnchor" => Leading
  | "trailingAnchor" => Trailing
  | "centerXAnchor" => CenterX
  | "centerYAnchor" => CenterY
  | "widthAnchor" => Width
  | "heightAnchor" => Height
  | _ => raise(Not_found);

let cmpFromString =
  fun
  | "equalTo" => Eq
  | "lessThanOrEqualTo" => Leq
  | "greaterThanOrEqualTo" => Geq
  | _ => raise(Not_found);

let cmpToString =
  fun
  | Eq => "equalTo"
  | Leq => "lessThanOrEqualTo"
  | Geq => "greaterThanOrEqualTo";

let priorityToString =
  fun
  | Low => "low"
  | Required => "required";

let toString = const =>
  switch (const) {
  | Dimension(layer, anchor, priority, _) =>
    priorityToString(priority)
    ++ " : "
    ++ layer.name
    ++ "."
    ++ anchorToString(anchor)
  | Relation(layer1, anchor1, cmp, layer2, anchor2, priority, _) =>
    priorityToString(priority)
    ++ " : "
    ++ layer1.name
    ++ "."
    ++ anchorToString(anchor1)
    ++ " "
    ++ cmpToString(cmp)
    ++ " "
    ++ layer2.name
    ++ "."
    ++ anchorToString(anchor2)
  };

let getPriority =
  fun
  | Dimension(_, _, priority, _) => priority
  | Relation(_, _, _, _, _, priority, _) => priority;

let getRole =
  fun
  | Dimension(_, _, _, role) => role
  | Relation(_, _, _, _, _, _, role) => role;

let reverse = (const: t) =>
  switch (const) {
  | Dimension(_) => const
  | Relation(layer1, anchor1, cmp, layer2, anchor2, priority, role) =>
    let cmp =
      switch (cmp) {
      | Leq => Geq
      | Geq => Leq
      | Eq => Eq
      };
    Relation(layer2, anchor2, cmp, layer1, anchor1, priority, role);
  };

/* Compare two constraints */
let strictEqual = (a: t, b: t): bool =>
  switch (a, b) {
  | (
      Dimension(layerA, anchorA, priorityA, _),
      Dimension(layerB, anchorB, priorityB, _),
    ) =>
    Layer.equal(layerA, layerB)
    && anchorA == anchorB
    && priorityA == priorityB
  | (
      Relation(layer1A, anchor1A, cmpA, layer2A, anchor2A, priorityA, _),
      Relation(layer1B, anchor1B, cmpB, layer2B, anchor2B, priorityB, _),
    ) =>
    Layer.equal(layer1A, layer1B)
    && anchor1A == anchor1B
    && cmpA == cmpB
    && Layer.equal(layer2A, layer2B)
    && anchor2A == anchor2B
    && priorityA == priorityB
  | _ => false
  };

/* Compare two constraints. Relation order is irrelevant */
let semanticEqual = (a: t, b: t): bool =>
  switch (a, b) {
  | (Dimension(_) as a, Dimension(_) as b) => strictEqual(a, b)
  | (Relation(_) as a, Relation(_) as b) =>
    strictEqual(a, b)
    || strictEqual(reverse(a), b)
    || strictEqual(a, reverse(b))
    || strictEqual(reverse(a), reverse(b))
  | _ => strictEqual(a, b)
  };

let getConstraints =
    (getComponent: string => Js.Json.t, rootLayer: Types.layer) => {
  let constrainAxes = (originalLayer: Types.layer) => {
    let isComponentLayer = Layer.isComponentLayer(originalLayer);
    let layer = Layer.getProxyLayer(getComponent, originalLayer);
    let children =
      originalLayer.children |> List.map(Layer.getProxyLayer(getComponent));

    let direction = Layer.getFlexDirection(layer.parameters);
    let isColumn = direction == "column";
    let primaryBeforeAnchor = isColumn ? Top : Leading;
    let primaryAfterAnchor = isColumn ? Bottom : Trailing;
    /* let primaryCenterAnchor = isColumn ? CenterY : CenterX; */
    let secondaryBeforeAnchor = isColumn ? Leading : Top;
    let secondaryAfterAnchor = isColumn ? Trailing : Bottom;
    let secondaryCenterAnchor = isColumn ? CenterX : CenterY;
    let primaryDimensionAnchor = isColumn ? Height : Width;
    let secondaryDimensionAnchor = isColumn ? Width : Height;
    let height = Layer.getNumberParameterOpt(Height, layer.parameters);
    let width = Layer.getNumberParameterOpt(Width, layer.parameters);
    let sizingRules =
      layer.parameters
      |> Layer.getSizingRules(
           isComponentLayer ? None : Layer.findParent(rootLayer, layer),
         );
    let primarySizingRule = isColumn ? sizingRules.height : sizingRules.width;
    let secondarySizingRule =
      isColumn ? sizingRules.width : sizingRules.height;

    let fillChildren =
      children
      |> List.filter((child: Types.layer) => {
           let proxyChild = Layer.getProxyLayer(getComponent, child);
           let childSizingRules =
             proxyChild.parameters
             |> Layer.getSizingRules(
                  Layer.isComponentLayer(child) ? None : Some(layer),
                );
           let primarySizingRule =
             isColumn ? childSizingRules.height : childSizingRules.width;
           primarySizingRule == Layout.Fill;
         });

    let addConstraints = (index, child: Types.layer) => {
      let childSizingRules =
        child.parameters |> Layer.getSizingRules(Some(layer));
      let childSecondarySizingRule =
        isColumn ? childSizingRules.width : childSizingRules.height;
      let firstViewConstraints =
        switch (index) {
        | 0 => [
            Relation(
              child,
              primaryBeforeAnchor,
              Eq,
              layer,
              primaryBeforeAnchor,
              Required,
              PrimaryBefore,
            ),
          ]
        | _ => []
        };
      let lastViewConstraints =
        switch (index) {
        | x when x == List.length(children) - 1 =>
          /* If the parent view has a Fixed dimension, we don't need to add a constraint...
             unless any child has a Fill dimension, in which case we do still need the constraint. */
          let needsPrimaryAfterConstraint =
            switch (primarySizingRule, List.length(fillChildren)) {
            | (Fill, count) when count == 0 => false
            | (Fixed(_), count) when count == 0 => false
            | (_, _) => true
            };
          needsPrimaryAfterConstraint ?
            [
              Relation(
                child,
                primaryAfterAnchor,
                Eq,
                layer,
                primaryAfterAnchor,
                Required,
                PrimaryAfter,
              ),
            ] :
            [];
        | _ => []
        };
      let middleViewConstraints =
        switch (index) {
        | 0 => []
        | _ =>
          let previousLayer = List.nth(children, index - 1);
          [
            Relation(
              child,
              primaryBeforeAnchor,
              Eq,
              previousLayer,
              primaryAfterAnchor,
              Required,
              PrimaryBetween,
            ),
          ];
        };
      let secondaryBeforeEqConstraint =
        Relation(
          child,
          secondaryBeforeAnchor,
          Eq,
          layer,
          secondaryBeforeAnchor,
          Required,
          SecondaryBefore,
        );
      let secondaryAfterEqConstraint =
        Relation(
          child,
          secondaryAfterAnchor,
          Eq,
          layer,
          secondaryAfterAnchor,
          Required,
          SecondaryAfter,
        );
      let secondaryCenterConstraint =
        Relation(
          child,
          secondaryCenterAnchor,
          Eq,
          layer,
          secondaryCenterAnchor,
          Required,
          SecondaryCenter,
        );
      let secondaryAfterLeqConstraint =
        Relation(
          child,
          secondaryAfterAnchor,
          Leq,
          layer,
          secondaryAfterAnchor,
          Required,
          SecondaryAfter,
        );
      let secondaryBeforeGeqConstraint =
        Relation(
          child,
          secondaryBeforeAnchor,
          Geq,
          layer,
          secondaryBeforeAnchor,
          Required,
          SecondaryBefore,
        );
      let secondaryAfterFlexibleConstraint =
        switch (secondarySizingRule, childSecondarySizingRule) {
        | (Fill, FitContent) => [secondaryAfterLeqConstraint]
        | (_, Fixed(_)) => [] /* Width/height constraints are added outside the child loop */
        | (_, Fill)
        | (_, FitContent) => [secondaryAfterEqConstraint]
        };
      let secondaryBeforeFlexibleConstraint =
        switch (secondarySizingRule, childSecondarySizingRule) {
        | (Fill, FitContent) => [secondaryBeforeGeqConstraint]
        | (_, Fixed(_)) => [] /* Width/height constraints are added outside the child loop */
        | (_, Fill)
        | (_, FitContent) => [secondaryBeforeEqConstraint]
        };
      let secondaryConstraints =
        switch (
          Layer.getStringParameterOpt(AlignItems, layer.parameters),
          childSecondarySizingRule,
        ) {
        /* Fixed children don't need either side of the secondary axis anchored to the parent.
           The secondary dimension will be constrained in the outer loop to handle fit content. */
        | (Some("center"), Fixed(_)) => [secondaryCenterConstraint]
        /* Fit or fill children still need the sides constrained in addition to being centered.
           Since the constraints are Leq/Geq, this shouldn't be overconstrained. (Actually, if even one
           constraint is Leq/Geq, this seems to work) */
        | (Some("center"), _) =>
          secondaryBeforeFlexibleConstraint
          @ [secondaryCenterConstraint]
          @ secondaryAfterFlexibleConstraint
        /* With flex-end alignment, we want to do the opposite of flex-start alignment, flipping
           both the before and after constraints. */
        | (Some("flex-end"), _) =>
          secondaryBeforeFlexibleConstraint @ [secondaryAfterEqConstraint]
        /* This is the default flex-start case. */
        | _ =>
          [secondaryBeforeEqConstraint] @ secondaryAfterFlexibleConstraint
        };
      firstViewConstraints
      @ lastViewConstraints
      @ middleViewConstraints
      @ secondaryConstraints;
    };
    /* Children set to Fill should all have equal dimensions along the primary axis */
    let fillChildrenConstraints =
      switch (fillChildren) {
      | [first, ...rest] when List.length(rest) > 0 =>
        let sameAnchor = primaryDimensionAnchor;
        let sameAnchorConstraint = (anchor, layer) =>
          Relation(first, anchor, Eq, layer, anchor, Required, FlexSibling);
        rest |> List.map(sameAnchorConstraint(sameAnchor));
      | _ => []
      };
    /* If the parent's secondary axis is set to "fit content", this ensures
       the secondary axis dimension is greater than every child's. */
    /*
       We need these constraints to be low priority. A "FitContent" view needs height >= each
       of its children. Yet a "Fill" sibling needs to have height unspecified, and
       a side anchor equal to the side of the "FitContent" view.
       This layout is ambiguous (I think), despite no warnings at runtime. The "FitContent" view's
       height constraints seem to take priority over the "Fill" view's height constraints, and the
       "FitContent" view steals the height of the "Fill" view. We solve this by lowering the priority
       of the "FitContent" view's height.
     */
    let fitContentSecondaryConstraint = child =>
      switch (secondarySizingRule) {
      | FitContent => [
          Relation(
            child,
            secondaryDimensionAnchor,
            Leq,
            layer,
            secondaryDimensionAnchor,
            Low,
            FitContentSecondary,
          ),
        ]
      | _ => []
      };
    let fitContentSecondaryConstraints =
      children |> List.map(fitContentSecondaryConstraint) |> List.concat;
    let heightConstraint =
      switch (height) {
      | Some(_) => [
          Dimension(
            layer,
            Height,
            Required,
            isColumn ? PrimaryDimension : SecondaryDimension,
          ),
        ]
      | None => []
      };
    let widthConstraint =
      switch (width) {
      | Some(_) => [
          Dimension(
            layer,
            Width,
            Required,
            isColumn ? SecondaryDimension : PrimaryDimension,
          ),
        ]
      | None => []
      };
    let constraints =
      [heightConstraint, widthConstraint]
      @ [fillChildrenConstraints]
      @ [fitContentSecondaryConstraints]
      @ (children |> List.mapi(addConstraints));
    constraints |> List.concat;
  };
  rootLayer |> Layer.flatmap(constrainAxes) |> List.concat;
};

let dedupe =
  Sequence.dedupe((const, list) =>
    List.exists(other => semanticEqual(other, const), list)
  );

let visibilityLayers =
    (assignmentsFromLogic, rootLayer: Types.layer): list(Types.layer) =>
  rootLayer
  |> Layer.flatten
  |> List.filter((layer: Types.layer) =>
       SwiftComponentParameter.isAssigned(
         assignmentsFromLogic,
         layer,
         Visible,
       )
       /* Layers with visibility hardcoded in theory don't need to be generated
          at all, and don't need any constraints. However, this would be difficult
          to determine perfectly, so a simpler solution is to delete the layer from
          the .component file if it is always hidden. */
       || SwiftComponentParameter.isSetInitially(layer, Visible)
     );

let visibilityCombinations =
    (getComponent, assignmentsFromLogic, rootLayer: Types.layer)
    : list(visibilityCombination) => {
  let layers = visibilityLayers(assignmentsFromLogic, rootLayer);

  Sequence.combinations(layers)
  |> List.map(visibleLayers => {
       /* The root must always be visible, so getExn is safe */
       let rootLayer =
         rootLayer
         |> Layer.filter(layer => !List.mem(layer, visibleLayers))
         |> Js.Option.getExn;

       {
         rootLayer,
         visibleLayers,
         constraints: getConstraints(getComponent, rootLayer),
       };
     });
};

let isAlwaysActivated =
    (visibilityCombinations: list(visibilityCombination), const): bool =>
  visibilityCombinations
  |> List.for_all((combination: visibilityCombination) =>
       List.exists(
         other => semanticEqual(other, const),
         combination.constraints,
       )
     );

let alwaysConstraints = (combinations: list(visibilityCombination)): list(t) =>
  combinations
  |> List.map((combination: visibilityCombination) =>
       combination.constraints
     )
  |> List.concat
  |> List.filter(isAlwaysActivated(combinations))
  |> dedupe;

let conditionalConstraints =
    (combinations: list(visibilityCombination)): list(t) =>
  combinations
  |> List.map((combination: visibilityCombination) =>
       combination.constraints
     )
  |> List.concat
  |> List.filter(const => !isAlwaysActivated(combinations, const))
  |> dedupe;

let allConstraints = (combinations: list(visibilityCombination)): list(t) =>
  alwaysConstraints(combinations) @ conditionalConstraints(combinations);