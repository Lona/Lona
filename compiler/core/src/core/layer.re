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

let isPrimitiveTypeName = (typeName: Types.layerType) =>
  switch typeName {
  | Types.View
  | Types.Text
  | Types.Image
  | Types.Animation => true
  | Types.Children
  | Types.Component(_)
  | Types.Unknown => false
  };

/* Parameter category is used to determine whether to put props in a
   style object or on the element when generating JSX */
type parameterCategory =
  | Style
  | Prop
  | Meta;

let getParameterCategory = (x: ParameterKey.t) =>
  switch x {
  | AlignItems => Style
  | AlignSelf => Style
  | Flex => Style
  | FlexDirection => Style
  | TextStyle => Style
  | JustifyContent => Style
  | MarginTop => Style
  | MarginRight => Style
  | MarginBottom => Style
  | MarginLeft => Style
  | PaddingTop => Style
  | PaddingRight => Style
  | PaddingBottom => Style
  | PaddingLeft => Style
  | Width => Style
  | Height => Style
  | BackgroundColor => Style
  | BorderColor => Style
  | BorderRadius => Style
  | BorderWidth => Style
  | TextAlign => Style
  /* Props */
  | NumberOfLines => Prop
  | Text => Prop
  | Image => Prop
  | OnPress => Prop
  | Custom(_) => Prop
  /* Meta: these are treated like props within Lona for simplicity, but they are
     not actually props. These must be translated into something platform-specific
     when generating code. E.g. when not `visible`, a React component should not
     be rendered at all. */
  | Pressed => Meta
  | Hovered => Meta
  | Visible => Meta
  };

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
    |> flatmap((layer: Types.layer) =>
         layer.parameters |> ParameterMap.bindings
       );
  List.concat(parameterLists) |> List.map(f(layer));
};

let getFlexDirection = (layer: Types.layer) =>
  switch (ParameterMap.find(ParameterKey.FlexDirection, layer.parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "column"
  };

let getStringParameterOpt = (parameterName, layer: Types.layer) =>
  switch (ParameterMap.find_opt(parameterName, layer.parameters)) {
  | Some(value) => Some(value.data |> Json.Decode.string)
  | None => None
  };

let getStringParameter = (parameterName, layer: Types.layer) =>
  switch (getStringParameterOpt(parameterName, layer)) {
  | Some(value) => value
  | None => ""
  };

let getNumberParameterOpt = (parameterName, layer: Types.layer) =>
  switch (ParameterMap.find(parameterName, layer.parameters)) {
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
  let flex = getNumberParameterOpt(Flex, layer);
  let width = getNumberParameterOpt(Width, layer);
  let height = getNumberParameterOpt(Height, layer);
  let alignSelf = getStringParameterOpt(AlignSelf, layer);
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
  let extract = key =>
    ParameterMap.find_opt(
      ParameterKey.fromString(prefix ++ key),
      layer.parameters
    );
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
        LayerMap.add(found, ParameterMap.add(propertyName, logicValue, x), acc)
      | None =>
        LayerMap.add(
          found,
          ParameterMap.add(propertyName, logicValue, ParameterMap.empty),
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
           updateAssignments(
             layerName,
             propertyName |> ParameterKey.fromString,
             item,
             acc
           )
         | _ => acc
         },
       LayerMap.empty
     );
};

/* Build a map from each layer, to a map from its parameter name to an assignment
   [layer: [parameterName: Logic.Assign]]
    */
let logicAssignmentsFromLayerParameters = layer => {
  let layerMap = ref(LayerMap.empty);
  let extractParameters = (layer: Types.layer) => {
    let parameterMap = ref(ParameterMap.empty);
    let extractParameter = ((parameterName, lonaValue: Types.lonaValue)) => {
      let receiver =
        Logic.Identifier(
          lonaValue.ltype,
          ["layers", layer.name, parameterName |> ParameterKey.toString]
        );
      let source = Logic.Literal(lonaValue);
      let assignment = Logic.Assign(source, receiver);
      parameterMap :=
        ParameterMap.add(parameterName, assignment, parameterMap^);
    };
    layer.parameters |> ParameterMap.bindings |> List.iter(extractParameter);
    layerMap := LayerMap.add(layer, parameterMap^, layerMap^);
  };
  let _ = layer |> flatmap(extractParameters);
  layerMap^;
};

let parameterIsStyle = key => getParameterCategory(key) == Style;

let splitParamsMap = params =>
  params |> ParameterMap.partition((key, _) => parameterIsStyle(key));

let parameterMapToLogicValueMap = params =>
  ParameterMap.map(item => Logic.Literal(item), params);

let mapBindings = (f, map) => map |> ParameterMap.bindings |> List.map(f);

let isViewLayer = (layer: Types.layer) => layer.typeName == Types.View;

let isTextLayer = (layer: Types.layer) => layer.typeName == Types.Text;

let isImageLayer = (layer: Types.layer) => layer.typeName == Types.Image;

let isComponentLayer = (layer: Types.layer) =>
  switch layer.typeName {
  | Component(_) => true
  | _ => false
  };

type availableTypeNames = {
  builtIn: list(Types.layerType),
  custom: list(string)
};

let getTypeNames = rootLayer => {
  let typeNames =
    rootLayer
    |> flatten
    |> List.map((layer: Types.layer) => layer.typeName)
    |> List.fold_left(
         (acc, item) => List.mem(item, acc) ? acc : [item, ...acc],
         []
       );
  let builtInTypeNames = typeNames |> List.filter(isPrimitiveTypeName);
  let customTypeNames =
    typeNames
    |> List.fold_left(
         (acc, item) =>
           switch item {
           | Types.Component(name) => [name, ...acc]
           | _ => acc
           },
         []
       );
  {builtIn: builtInTypeNames, custom: customTypeNames};
};