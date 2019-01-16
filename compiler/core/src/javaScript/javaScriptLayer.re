let canBeFocused = (layer: Types.layer): bool =>
  switch (
    layer.parameters |> ParameterMap.find_opt(ParameterKey.AccessibilityType)
  ) {
  | Some(value) =>
    switch (value.data |> Js.Json.classify) {
    | Js.Json.JSONString("element") => true
    | _ => false
    }
  | None => false
  };

let needsRef = (layer: Types.layer): bool => layer |> canBeFocused;

module Hierarchy = {
  /* TODO we need to traverse the layer hierarchy to determine the
     correct layers/order. It's not enough to filter by canBeFocused,
     since a `container` at the root could specify totally different
     layers. */
  let needsFocusHandling = (layer: Types.layer): bool =>
    layer |> Layer.flatten |> List.exists(canBeFocused);

  let accessibilityElements = (rootLayer: Types.layer): list(Types.layer) => {
    let rec inner =
            (acc: list(Types.layer), layer: Types.layer): list(Types.layer) =>
      acc
      @ (
        switch (Layer.accessibilityType(layer)) {
        | None => []
        | Auto => layer.children |> List.fold_left(inner, [])
        | Element(_) => [layer]
        | Container(elements) =>
          elements
          |> List.map(name => Layer.findByName(name, layer))
          |> Sequence.compact
          |> List.map(inner([]))
          |> List.concat
        }
      );

    inner([], rootLayer);
  };
};