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

type _t =
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
  | "heightAnchor" => Height;

let cmpFromString =
  fun
  | "equalTo" => Eq
  | "lessThanOrEqualTo" => Leq
  | "greaterThanOrEqualTo" => Geq;

let cmpToString =
  fun
  | Eq => "equalTo"
  | Leq => "lessThanOrEqualTo"
  | Geq => "greaterThanOrEqualTo";

let getPriority =
  fun
  | Dimension(_, _, priority, _) => priority
  | Relation(_, _, _, _, _, priority, _) => priority;

let getRole =
  fun
  | Dimension(_, _, _, role) => role
  | Relation(_, _, _, _, _, _, role) => role;

/* module ConstraintMap = {
     include
       Map.Make(
         {
           type t = _t;
           let compare = (a: t, b: t) : int =>
             switch (a, b) {
             | (
                 Dimension(layer1, dimension1, _, _),
                 Dimension(layer2, dimension2, _, _)
               ) =>
               compare((layer1.name, dimension1), (layer2.name, dimension2))
             | (
                 Relation(layer1a, anchor1a, _, layer1b, anchor1b, _, _),
                 Relation(layer2a, anchor2a, _, layer2b, anchor2b, _, _)
               ) =>
               compare(
                 (layer1a.name, anchor1a, layer1b.name, anchor1b),
                 (layer2a.name, anchor2a, layer2b.name, anchor2b)
               )
             | (Relation(_), Dimension(_)) => (-1)
             | (Dimension(_), Relation(_)) => 1
             };
         }
       );
     let find_opt = (key, map) =>
       switch (find(key, map)) {
       | item => Some(item)
       | exception Not_found => None
       };
   }; */
type t = _t;

let getConstraints = (getRootLayerForComponentName, rootLayer: Types.layer) => {
  /* Any time we access a layer, we want to use its proxy if it has one.
     This is how we layout custom components.
     TODO: When we handle "Children" components, we'll need to find a use
     a different proxy */
  let getProxyLayer = (layer: Types.layer) =>
    switch (layer.typeName) {
    | Types.Component(name) => getRootLayerForComponentName(layer, name)
    | _ => layer
    };
  let constrainAxes = (layer: Types.layer) => {
    let layer = getProxyLayer(layer);
    let direction = Layer.getFlexDirection(layer);
    let isColumn = direction == "column";
    let primaryBeforeAnchor = isColumn ? Top : Leading;
    let primaryAfterAnchor = isColumn ? Bottom : Trailing;
    let primaryCenterAnchor = isColumn ? CenterY : CenterX;
    let secondaryBeforeAnchor = isColumn ? Leading : Top;
    let secondaryAfterAnchor = isColumn ? Trailing : Bottom;
    let secondaryCenterAnchor = isColumn ? CenterX : CenterY;
    let primaryDimensionAnchor = isColumn ? Height : Width;
    let secondaryDimensionAnchor = isColumn ? Width : Height;
    let height = Layer.getNumberParameterOpt(Height, layer);
    let width = Layer.getNumberParameterOpt(Width, layer);
    let sizingRules =
      layer |> Layer.getSizingRules(Layer.findParent(rootLayer, layer));
    let primarySizingRule = isColumn ? sizingRules.height : sizingRules.width;
    let secondarySizingRule =
      isColumn ? sizingRules.width : sizingRules.height;
    let flexChildren =
      layer.children
      |> List.map(getProxyLayer)
      |> List.filter((child: Types.layer) =>
           Layer.getNumberParameter(Flex, child) === 1.0
         );
    let addConstraints = (index, child: Types.layer) => {
      let childSizingRules = child |> Layer.getSizingRules(Some(layer));
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
        | x when x == List.length(layer.children) - 1 =>
          /* If the parent view has a fixed dimension, we don't need to add a constraint...
             unless any child has "flex: 1", in which case we do still need the constraint. */
          let needsPrimaryAfterConstraint =
            switch (primarySizingRule, List.length(flexChildren)) {
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
          let previousLayer = List.nth(layer.children, index - 1);
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
          Layer.getStringParameterOpt(AlignItems, layer),
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
    /* Children with "flex: 1" should all have equal dimensions along the primary axis */
    let flexChildrenConstraints =
      switch (flexChildren) {
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
      layer.children
      |> List.map(getProxyLayer)
      |> List.map(fitContentSecondaryConstraint)
      |> List.concat;
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
      @ [flexChildrenConstraints]
      @ [fitContentSecondaryConstraints]
      @ (
        layer.children
        |> List.map(getProxyLayer)
        |> List.mapi(addConstraints)
      );
    constraints |> List.concat;
  };
  rootLayer |> Layer.flatmap(constrainAxes) |> List.concat;
};
