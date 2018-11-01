let compare = (a: Types.layer, b: Types.layer): int =>
  compare(a.name, b.name);

let equal = (a: Types.layer, b: Types.layer): bool => compare(a, b) == 0;

module LayerMap = {
  include Map.Make({
    type t = Types.layer;
    let compare = compare;
  });
  let find_opt = (key, map) =>
    switch (find(key, map)) {
    | item => Some(item)
    | exception Not_found => None
    };
};

let isPrimitiveTypeName = (typeName: Types.layerType) =>
  switch (typeName) {
  | Types.View
  | Types.Text
  | Types.Image
  | Types.VectorGraphic
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
  switch (x) {
  | AlignItems => Style
  | AlignSelf => Style
  | Display => Style
  | Flex => Style
  | FlexDirection => Style
  | TextStyle => Style
  | JustifyContent => Style
  | MarginTop => Style
  | MarginRight => Style
  | MarginBottom => Style
  | MarginLeft => Style
  | Overflow => Style
  | PaddingTop => Style
  | PaddingRight => Style
  | PaddingBottom => Style
  | PaddingLeft => Style
  | Width => Style
  | MaxWidth => Style
  | Height => Style
  | MaxHeight => Style
  | BackgroundColor => Style
  | BorderColor => Style
  | BorderRadius => Style
  | BorderWidth => Style
  | TextAlign => Style
  | Shadow => Style
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

let isViewLayer = (layer: Types.layer) => layer.typeName == Types.View;

let isTextLayer = (layer: Types.layer) => layer.typeName == Types.Text;

let isImageLayer = (layer: Types.layer) => layer.typeName == Types.Image;

let isVectorGraphicLayer = (layer: Types.layer) =>
  layer.typeName == Types.VectorGraphic;

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

let rec filter =
        (f: Types.layer => bool, layer: Types.layer): option(Types.layer) =>
  if (f(layer)) {
    let children = layer.children |> List.map(filter(f)) |> Sequence.compact;
    Some({...layer, children});
  } else {
    None;
  };

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

let getFlexDirection = (parameters: Types.layerParameters) =>
  switch (ParameterMap.find(ParameterKey.FlexDirection, parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "column"
  };

let getAlignItems = (parameters: Types.layerParameters) =>
  switch (ParameterMap.find(ParameterKey.AlignItems, parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "flex-start"
  };

let getJustifyContent = (parameters: Types.layerParameters) =>
  switch (ParameterMap.find(ParameterKey.JustifyContent, parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "flex-start"
  };

let getStringParameterOpt = (parameterName, parameters: Types.layerParameters) =>
  switch (ParameterMap.find_opt(parameterName, parameters)) {
  | Some(value) => Some(value.data |> Json.Decode.string)
  | None => None
  };

let getStringParameter = (parameterName, parameters: Types.layerParameters) =>
  switch (getStringParameterOpt(parameterName, parameters)) {
  | Some(value) => value
  | None => ""
  };

let getNumberParameterOpt = (parameterName, parameters: Types.layerParameters) =>
  switch (ParameterMap.find(parameterName, parameters)) {
  | value => Some(value.data |> Json.Decode.float)
  | exception Not_found => None
  };

let getNumberParameter = (parameterName, parameters: Types.layerParameters) =>
  switch (getNumberParameterOpt(parameterName, parameters)) {
  | Some(value) => value
  | None => 0.0
  };

type dimensionSizingRules = {
  width: Layout.sizingRule,
  height: Layout.sizingRule,
};

/* Lona save format uses React Native defaults, so the top-level layer has a column parent */
let getSizingRules =
    (parent: option(Types.layer), parameters: Types.layerParameters) => {
  let parentDirection =
    switch (parent) {
    | Some(parent) => getFlexDirection(parent.parameters)
    | None => "column"
    };
  let flex = getNumberParameterOpt(Flex, parameters);
  let width = getNumberParameterOpt(Width, parameters);
  let height = getNumberParameterOpt(Height, parameters);
  let alignSelf = getStringParameterOpt(AlignSelf, parameters);
  let widthSizingRule =
    switch (parentDirection, flex, width, alignSelf) {
    | ("row", Some(1.0), _, _) => Layout.Fill
    | ("row", _, Some(value), _) => Layout.Fixed(value)
    | ("row", _, _, _) => Layout.FitContent
    | (_, _, _, Some("stretch")) => Layout.Fill
    | (_, _, Some(value), _) => Layout.Fixed(value)
    | (_, _, _, _) => Layout.FitContent
    };
  let heightSizingRule =
    switch (parentDirection, flex, height, alignSelf) {
    | ("row", _, _, Some("stretch")) => Layout.Fill
    | ("row", _, Some(value), _) => Layout.Fixed(value)
    | ("row", _, _, _) => Layout.FitContent
    | (_, Some(1.0), _, _) => Layout.Fill
    | (_, _, Some(value), _) => Layout.Fixed(value)
    | (_, _, _, _) => Layout.FitContent
    };
  {width: widthSizingRule, height: heightSizingRule};
};

let getLayout =
    (parent: option(Types.layer), parameters: Types.layerParameters)
    : Layout.t => {
  let {width, height} = getSizingRules(parent, parameters);
  let direction = getFlexDirection(parameters) |> Layout.FromString.direction;
  let justifyContent =
    switch (getStringParameterOpt(ParameterKey.JustifyContent, parameters)) {
    | Some(value) => value |> Layout.FromString.childrenAlignment
    | None => Unspecified
    };
  let alignItems =
    switch (getStringParameterOpt(ParameterKey.AlignItems, parameters)) {
    | Some(value) => value |> Layout.FromString.childrenAlignment
    | None => Unspecified
    };
  let horizontalAlignment =
    switch (direction) {
    | Row => justifyContent
    | Column => alignItems
    };
  let verticalAlignment =
    switch (direction) {
    | Row => alignItems
    | Column => justifyContent
    };
  {direction, width, height, horizontalAlignment, verticalAlignment};
};

let printSizingRule =
  fun
  | Layout.Fill => "fill"
  | FitContent => "fitContent"
  | Fixed(value) => "fixed(" ++ string_of_float(value) ++ ")";

type edgeInsets = {
  top: float,
  right: float,
  bottom: float,
  left: float,
};

let getInsets = (prefix, layer: Types.layer) => {
  let directions = ["Top", "Right", "Bottom", "Left"];
  let extract = key =>
    ParameterMap.find_opt(
      ParameterKey.fromString(prefix ++ key),
      layer.parameters,
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

type vectorParamKey =
  | Fill
  | Stroke;

let vectorParamKeyToString = paramKey =>
  switch (paramKey) {
  | Fill => "fill"
  | Stroke => "stroke"
  };

let vectorParamKeyFromString = (key: string): vectorParamKey =>
  switch (key) {
  | "fill" => Fill
  | "stroke" => Stroke
  | _ =>
    Js.log("Invalid vector param key");
    raise(Not_found);
  };

type vectorAssignment = {
  elementName: string,
  paramKey: vectorParamKey,
  originalIdentifierPath: list(string),
};

let hasDynamicVectorParam =
    (
      vectorAssignments: list(vectorAssignment),
      variableName: string,
      paramKey: vectorParamKey,
    )
    : bool =>
  vectorAssignments
  |> Sequence.firstWhere((vectorAssignment: vectorAssignment) =>
       vectorAssignment.elementName == variableName
       && vectorAssignment.paramKey == paramKey
     )
  != None;

let vectorAssignments =
    (layer: Types.layer, node: Logic.logicNode): list(vectorAssignment) =>
  Logic.assignedIdentifiers(node)
  |> Logic.IdentifierSet.elements
  |> List.map(((_, id)) =>
       switch (id) {
       | ["layers", layerName, "vector", elementName, paramKey]
           when layerName == layer.name =>
         let paramKey = paramKey |> vectorParamKeyFromString;
         Some({elementName, paramKey, originalIdentifierPath: id});
       | _ => None
       }
     )
  |> Sequence.compact;

let vectorGraphicLayers = (layer: Types.layer): list(Types.layer) =>
  layer |> flatten |> List.filter(isVectorGraphicLayer);

let parameterAssignmentsFromLogic = (layer, node) => {
  let identifiers = Logic.assignedIdentifiers(node);
  let updateAssignments = (layerName, propertyName, logicValue, acc) =>
    switch (findByName(layerName, layer)) {
    | Some(found) =>
      switch (LayerMap.find_opt(found, acc)) {
      | Some(x) =>
        LayerMap.add(
          found,
          ParameterMap.add(propertyName, logicValue, x),
          acc,
        )
      | None =>
        LayerMap.add(
          found,
          ParameterMap.add(propertyName, logicValue, ParameterMap.empty),
          acc,
        )
      }
    | None => acc
    };
  identifiers
  |> Logic.IdentifierSet.elements
  |> List.map(((type_, path)) => Logic.Identifier(type_, path))
  |> List.fold_left(
       (acc, item) =>
         switch (item) {
         | Logic.Identifier(_, [_, layerName, propertyName]) =>
           updateAssignments(
             layerName,
             propertyName |> ParameterKey.fromString,
             item,
             acc,
           )
         | _ => acc
         },
       LayerMap.empty,
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
          ["layers", layer.name, parameterName |> ParameterKey.toString],
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

let isComponentLayer = (layer: Types.layer) =>
  switch (layer.typeName) {
  | Component(_) => true
  | _ => false
  };

type availableTypeNames = {
  builtIn: list(Types.layerType),
  custom: list(string),
};

let getTypeNames = rootLayer => {
  let typeNames =
    rootLayer
    |> flatten
    |> List.map((layer: Types.layer) => layer.typeName)
    |> List.fold_left(
         (acc, item) => List.mem(item, acc) ? acc : [item, ...acc],
         [],
       );
  let builtInTypeNames = typeNames |> List.filter(isPrimitiveTypeName);
  let customTypeNames =
    typeNames
    |> List.fold_left(
         (acc, item) =>
           switch (item) {
           | Types.Component(name) => [name, ...acc]
           | _ => acc
           },
         [],
       );
  {builtIn: builtInTypeNames, custom: customTypeNames};
};

/* For the purposes of layouts, we want to swap the custom component layer
   with the root layer from the custom component's definition. We should
   use the parameters of the custom component's root layer, since these
   determine layout. We should still use the type, name, and children of
   the custom component layer. */
let getRootLayerForComponentName =
    (getComponent: string => Js.Json.t, layer: Types.layer, name): Types.layer => {
  let component = getComponent(name);
  let rootLayer = component |> Decode.Component.rootLayer(getComponent);
  {
    typeName: layer.typeName,
    styles: layer.styles,
    name: layer.name,
    parameters: rootLayer.parameters,
    children: layer.children,
    metadata: layer.metadata,
  };
};

/* Any time we access a layer, we want to use its proxy if it has one.
   This is how we layout custom components.
   TODO: When we handle "Children" components, we'll need to find/use
   a different proxy */
let getProxyLayer = (getComponent: string => Js.Json.t, layer: Types.layer) =>
  switch (layer.typeName) {
  | Types.Component(name) =>
    getRootLayerForComponentName(getComponent, layer, name)
  | _ => layer
  };