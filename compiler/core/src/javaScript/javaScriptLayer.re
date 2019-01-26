let rec canBeFocused = (config: Config.t, layer: Types.layer): bool =>
  switch (layer.typeName) {
  | Component(componentName) =>
    let getComponent = Config.Find.component(config);
    let component = Config.Find.component(config, componentName);
    let rootLayer = component |> Decode.Component.rootLayer(getComponent);
    rootLayer |> Layer.flatten |> List.exists(canBeFocused(config));
  | _ =>
    switch (Layer.accessibilityType(layer)) {
    | Element(_) => true
    | _ => false
    }
  };

let needsRef = (config: Config.t, layer: Types.layer): bool =>
  config.options.javaScript.framework == ReactDOM
  && layer
  |> canBeFocused(config);

let getStyleVariables =
    (
      assignments: Layer.LayerMap.t(ParameterMap.t(Logic.logicValue)),
      layer: Types.layer,
    ) =>
  switch (Layer.LayerMap.find_opt(layer, assignments)) {
  | Some(map) =>
    map |> ParameterMap.filter((key, _) => Layer.parameterIsStyle(key))
  | None => ParameterMap.empty
  };

let getPropVariables =
    (
      assignments: Layer.LayerMap.t(ParameterMap.t(Logic.logicValue)),
      layer: Types.layer,
    ) =>
  switch (Layer.LayerMap.find_opt(layer, assignments)) {
  | Some(map) =>
    map |> ParameterMap.filter((key, _) => !Layer.parameterIsStyle(key))
  | None => ParameterMap.empty
  };

let hasAccessibilityActivate = (assignments, layer) =>
  ParameterMap.mem(
    OnAccessibilityActivate,
    getPropVariables(assignments, layer),
  );

module Hierarchy = {
  let needsFocusHandling = (config: Config.t, layer: Types.layer): bool =>
    layer |> Layer.flatten |> List.exists(canBeFocused(config));

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