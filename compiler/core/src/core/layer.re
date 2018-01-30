module LayerMap = {
  include
    Map.Make(
      {
        type t = Types.layer;
        let compare = (a: t, b: t) : int => compare(a.name, b.name);
      }
    );
  let find_opt = (key, map) =>
    switch (find(key, map)) {
    | item => Some(item)
    | exception Not_found => None
    };
};

let stylesSet =
  StringSet.of_list([
    "alignItems",
    "alignSelf",
    "flex",
    "flexDirection",
    "font",
    "justifyContent",
    "marginTop",
    "marginRight",
    "marginBottom",
    "marginLeft",
    "paddingTop",
    "paddingRight",
    "paddingBottom",
    "paddingLeft",
    "width",
    "height"
  ]);

let flatten = (layer: Types.layer) => {
  let rec inner = (acc, layer: Types.layer) => {
    let children = layer.children;
    List.flatten([acc, [layer], ...List.map(inner([]), children)]);
  };
  inner([], layer);
};

let find = (f, rootLayer: Types.layer) =>
  switch (List.find(f, flatten(rootLayer))) {
  | item => Some(item)
  | exception Not_found => None
  };

let findByName = (name, rootLayer: Types.layer) =>
  rootLayer |> find((layer: Types.layer) => layer.name == name);

let flatmapParent = (f, layer: Types.layer) => {
  let rec inner = (layer: Types.layer) =>
    (layer.children |> List.map(f(Some(layer))))
    @ (layer.children |> List.map(inner) |> List.concat);
  [f(None, layer)] @ inner(layer);
};

let findParent = (rootLayer: Types.layer, targetLayer: Types.layer) => {
  let containsChild = (parent: Types.layer) =>
    parent.children |> List.exists(child => child === targetLayer);
  rootLayer |> find(containsChild);
};

let flatmap = (f, layer: Types.layer) =>
  flatmapParent((_, layer) => f(layer), layer);

let flatmapParameters = (f, layer: Types.layer) => {
  let parameterLists =
    layer
    |> flatmap((layer: Types.layer) => layer.parameters |> StringMap.bindings);
  List.concat(parameterLists) |> List.map(f(layer));
};

let getFlexDirection = (layer: Types.layer) =>
  switch (StringMap.find("flexDirection", layer.parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "column"
  };

let getStringParameterOpt = (parameterName, layer: Types.layer) =>
  switch (StringMap.find(parameterName, layer.parameters)) {
  | value => Some(value.data |> Json.Decode.string)
  | exception Not_found => None
  };

let getNumberParameterOpt = (parameterName, layer: Types.layer) =>
  switch (StringMap.find(parameterName, layer.parameters)) {
  | value => Some(value.data |> Json.Decode.float)
  | exception Not_found => None
  };

let getNumberParameter = (parameterName, layer: Types.layer) =>
  switch (getNumberParameterOpt(parameterName, layer)) {
  | Some(value) => value
  | None => 0.0
  };

type dimensionSizingRules = {
  width: Types.sizingRule,
  height: Types.sizingRule
};

let getSizingRules = (parent: option(Types.layer), layer: Types.layer) => {
  let parentDirection =
    switch parent {
    | Some(parent) => getFlexDirection(parent)
    | None => "column"
    };
  let flex = getNumberParameterOpt("flex", layer);
  let width = getNumberParameterOpt("width", layer);
  let height = getNumberParameterOpt("height", layer);
  let alignSelf = getStringParameterOpt("alignSelf", layer);
  let widthSizingRule =
    switch (parentDirection, flex, width, alignSelf) {
    | ("row", Some(1.0), _, _) => Types.Fill
    | ("row", _, Some(value), _) => Types.Fixed(value)
    | ("row", _, _, _) => Types.FitContent
    | (_, _, _, Some("stretch")) => Types.Fill
    | (_, _, Some(value), _) => Types.Fixed(value)
    | (_, _, _, _) => Types.FitContent
    };
  let heightSizingRule =
    switch (parentDirection, flex, height, alignSelf) {
    | ("row", _, _, Some("stretch")) => Types.Fill
    | ("row", _, Some(value), _) => Types.Fixed(value)
    | ("row", _, _, _) => Types.FitContent
    | (_, Some(1.0), _, _) => Types.Fill
    | (_, _, Some(value), _) => Types.Fixed(value)
    | (_, _, _, _) => Types.FitContent
    };
  {width: widthSizingRule, height: heightSizingRule};
};

let printSizingRule =
  fun
  | Types.Fill => "fill"
  | FitContent => "fitContent"
  | Fixed(value) => "fixed(" ++ string_of_float(value) ++ ")";

type edgeInsets = {
  top: float,
  right: float,
  bottom: float,
  left: float
};

let getInsets = (prefix, layer: Types.layer) => {
  let directions = ["Top", "Right", "Bottom", "Left"];
  let extract = key => StringMap.find_opt(prefix ++ key, layer.parameters);
  let unwrap =
    fun
    | Some((value: Types.lonaValue)) => value.data |> Json.Decode.float
    | None => 0.0;
  let values = directions |> List.map(extract) |> List.map(unwrap);
  let [top, right, bottom, left] = values;
  {top, right, bottom, left};
};

let getPadding = getInsets("padding");

let getMargin = getInsets("margin");

let parameterAssignmentsFromLogic = (layer, node) => {
  let identifiers = Logic.accessedIdentifiers(node);
  let updateAssignments = (layerName, propertyName, logicValue, acc) =>
    switch (findByName(layerName, layer)) {
    | Some(found) =>
      switch (LayerMap.find_opt(found, acc)) {
      | Some(x) =>
        LayerMap.add(found, StringMap.add(propertyName, logicValue, x), acc)
      | None =>
        LayerMap.add(
          found,
          StringMap.add(propertyName, logicValue, StringMap.empty),
          acc
        )
      }
    | None => acc
    };
  identifiers
  |> Logic.IdentifierSet.elements
  |> List.map(((type_, path)) => Logic.Identifier(type_, path))
  |> List.fold_left(
       (acc, item) =>
         switch item {
         | Logic.Identifier(_, [_, layerName, propertyName]) =>
           updateAssignments(layerName, propertyName, item, acc)
         | _ => acc
         },
       LayerMap.empty
     );
};

let logicAssignmentsFromLayerParameters = layer => {
  let layerMap = ref(LayerMap.empty);
  let extractParameters = (layer: Types.layer) => {
    let stringMap = ref(StringMap.empty);
    let extractParameter = ((parameterName, lonaValue: Types.lonaValue)) => {
      let receiver =
        Logic.Identifier(
          lonaValue.ltype,
          ["layers", layer.name, parameterName]
        );
      let source = Logic.Literal(lonaValue);
      let assignment = Logic.Assign(source, receiver);
      stringMap := StringMap.add(parameterName, assignment, stringMap^);
    };
    layer.parameters |> StringMap.bindings |> List.iter(extractParameter);
    layerMap := LayerMap.add(layer, stringMap^, layerMap^);
  };
  let _ = layer |> flatmap(extractParameters);
  layerMap^;
};

let parameterIsStyle = name => StringSet.has(name, stylesSet);

let splitParamsMap = params =>
  params |> StringMap.partition((key, _) => parameterIsStyle(key));

let parameterMapToLogicValueMap = params =>
  StringMap.map(item => Logic.Literal(item), params);

let layerTypeToString = x =>
  switch x {
  | Types.View => "View"
  | Text => "Text"
  | Image => "Image"
  | Animation => "Animation"
  | Children => "Children"
  | Component => "Component"
  | Unknown => "Unknown"
  };

let mapBindings = (f, map) => map |> StringMap.bindings |> List.map(f);
