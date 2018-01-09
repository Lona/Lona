type compilerTarget =
  | JavaScript
  | Swift;

type lonaType =
  | Reference(string)
  | Named(string, lonaType);

let colorType = Named("Color", Reference("String"));

let urlType = Named("URL", Reference("String"));

type lonaValue = {
  ltype: lonaType,
  data: Js.Json.t
};

type cmp =
  | Eq
  | Neq
  | Gt
  | Gte
  | Lt
  | Lte
  | Unknown;

type parameter = {
  name: string,
  ltype: lonaType,
  defaultValue: option(Js.Json.t)
};

type layerType =
  | View
  | Text
  | Image
  | Animation
  | Children
  | Component
  | Unknown;

type layer = {
  typeName: layerType,
  name: string,
  parameters: StringMap.t(lonaValue),
  children: list(layer)
};