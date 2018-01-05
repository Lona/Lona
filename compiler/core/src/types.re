type compilerTarget =
  | JavaScript
  | Swift;

type lonaType =
  | Reference(string)
  | Named(string, lonaType);

type lonaValue =
  | Value(lonaType, Js.Json.t);

type cmp =
  | Eq
  | Neq
  | Gt
  | Gte
  | Lt
  | Lte
  | Unknown;

type parameter =
  | Parameter(string, lonaType, option(Js.Json.t));

type layerType =
  | View
  | Text
  | Image
  | Animation
  | Children
  | Component
  | Unknown;

type layer =
  | Layer(layerType, string, StringMap.t(lonaValue), list(layer));