type layoutPriority =
  | Required
  | Low;

type anchor =
  | Width
  | Height
  | Top
  | Bottom
  | Leading
  | Trailing;

type cmp =
  | Eq
  | Geq
  | Leq;

type role =
  | PrimaryBefore
  | PrimaryBetween
  | PrimaryAfter
  | SecondaryBefore
  | SecondaryAfter
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
      role
    );

let anchorToString =
  fun
  | Top => "topAnchor"
  | Bottom => "bottomAnchor"
  | Leading => "leadingAnchor"
  | Trailing => "trailingAnchor"
  | Width => "widthAnchor"
  | Height => "heightAnchor";

let anchorFromString =
  fun
  | "topAnchor" => Top
  | "bottomAnchor" => Bottom
  | "leadingAnchor" => Leading
  | "trailingAnchor" => Trailing
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
  | Dimension(_, _, role, _) => role
  | Relation(_, _, _, _, _, role, _) => role;

module ConstraintMap = {
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
};

type t = _t;