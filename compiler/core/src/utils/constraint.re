type anchor =
  | Width
  | Height
  | Top
  | Bottom
  | Leading
  | Trailing;

type relation =
  | Eq
  | Geq
  | Leq;

type _t =
  | Dimension(Types.layer, anchor, float)
  | Edge(Types.layer, anchor, relation, Types.layer, anchor, float);

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

let relationFromString =
  fun
  | "equalTo" => Eq
  | "lessThanOrEqualTo" => Leq
  | "greaterThanOrEqualTo" => Geq;

let relationToString =
  fun
  | Eq => "equalTo"
  | Leq => "lessThanOrEqualTo"
  | Geq => "greaterThanOrEqualTo";

module ConstraintMap = {
  include
    Map.Make(
      {
        type t = _t;
        let compare = (a: t, b: t) : int =>
          switch (a, b) {
          | (
              Dimension(layer1, dimension1, _),
              Dimension(layer2, dimension2, _)
            ) =>
            compare((layer1.name, dimension1), (layer2.name, dimension2))
          | (
              Edge(layer1a, anchor1a, _, layer1b, anchor1b, _),
              Edge(layer2a, anchor2a, _, layer2b, anchor2b, _)
            ) =>
            compare(
              (layer1a.name, anchor1a, layer1b.name, anchor1b),
              (layer2a.name, anchor2a, layer2b.name, anchor2b)
            )
          | (Edge(_), Dimension(_)) => (-1)
          | (Dimension(_), Edge(_)) => 1
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