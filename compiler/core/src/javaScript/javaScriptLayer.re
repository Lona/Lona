let canBeFocused = (layer: Types.layer): bool =>
  switch (Layer.accessibilityType(layer)) {
  | Element(_) => true
  | _ => false
  };

let needsRef = (layer: Types.layer): bool => layer |> canBeFocused;

module Hierarchy = {
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