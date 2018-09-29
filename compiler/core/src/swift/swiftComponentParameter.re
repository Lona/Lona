let isFunction = (param: Types.parameter) => param.ltype == Types.handlerType;

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