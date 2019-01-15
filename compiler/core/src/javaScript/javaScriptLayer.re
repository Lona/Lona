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
  let needsFocusHandling = (layer: Types.layer): bool =>
    layer |> Layer.flatten |> List.exists(canBeFocused);
};