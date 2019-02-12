let isFunction = (config: Config.t, param: Types.parameter) =>
  Types.isFunction(Config.Type.resolve(config, param.ltype));

let isSetInitially = (layer: Types.layer, parameter) =>
  ParameterMap.mem(parameter, layer.parameters);

let get = (layer: Types.layer, parameter) =>
  ParameterMap.find_opt(parameter, layer.parameters);

let isAssigned = (assignments, layer: Types.layer, parameter) => {
  let assignedParameters = Layer.LayerMap.find_opt(layer, assignments);
  switch (assignedParameters) {
  | Some(parameters) => ParameterMap.mem(parameter, parameters)
  | None => false
  };
};

let isConditionallyAssigned =
    (logic: Logic.logicNode, layer: Types.layer, key: ParameterKey.t): bool =>
  Logic.conditionallyAssignedIdentifiers(logic)
  |> Logic.IdentifierSet.exists(((_, value)) =>
       value == ["layers", layer.name, key |> ParameterKey.toString]
     );

let isUsed = (assignments, layer: Types.layer, parameter) =>
  isAssigned(assignments, layer, parameter)
  || isSetInitially(layer, parameter);

let paddingAndMarginKeys = [
  ParameterKey.PaddingTop,
  PaddingRight,
  PaddingBottom,
  PaddingLeft,
  MarginTop,
  MarginRight,
  MarginBottom,
  MarginLeft,
];

let isPaddingOrMargin = key => List.mem(key, paddingAndMarginKeys);

let isEquatable = (config: Config.t, param: Types.parameter): bool =>
  !isFunction(config, param);

let getVectorAssetUrl = (layer: Types.layer) =>
  switch (get(layer, ParameterKey.Image)) {
  | None =>
    Js.log(
      "Error: VectorGraphic "
      ++ layer.name
      ++ " is missing the `image` parameter.",
    );
    raise(Not_found);
  | Some(value) => value |> LonaValue.decodeUrl
  };

let allVectorAssets = (rootLayer: Types.layer): list(string) =>
  rootLayer
  |> Layer.vectorGraphicLayers
  |> List.map(getVectorAssetUrl)
  |> Sequence.dedupe((item, list) => List.mem(item, list));

let allVectorAssignments =
    (rootLayer: Types.layer, logic: Logic.logicNode, asset: string)
    : list(Layer.vectorAssignment) => {
  let layerContainingAsset =
    rootLayer
    |> Layer.vectorGraphicLayers
    |> List.filter(layer => asset == getVectorAssetUrl(layer));

  layerContainingAsset
  |> List.map(layer => Layer.vectorAssignments(layer, logic))
  |> List.concat
  |> Sequence.dedupe((item: Layer.vectorAssignment, list) =>
       List.exists(
         (other: Layer.vectorAssignment) =>
           item.elementName == other.elementName
           && item.paramKey == other.paramKey,
         list,
       )
     );
};

/* let paddingParameterNameTranslations = [
     {swiftName: "topPadding", lonaName: PaddingTop},
     {swiftName: "trailingPadding", lonaName: PaddingRight},
     {swiftName: "bottomPadding", lonaName: PaddingBottom},
     {swiftName: "leadingPadding", lonaName: PaddingLeft},
   ];

   let marginParameterNameTranslations = [
     {swiftName: "topMargin", lonaName: MarginTop},
     {swiftName: "trailingMargin", lonaName: MarginRight},
     {swiftName: "bottomMargin", lonaName: MarginBottom},
     {swiftName: "leadingMargin", lonaName: MarginLeft},
   ]; */