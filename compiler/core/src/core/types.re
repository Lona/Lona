type compilerTarget =
  | JavaScript
  | Swift
  | Xml;

[@bs.deriving accessors]
type lonaType =
  | Reference(string)
  | Named(string, lonaType)
  | Function(
      list(
        {
          .
          "label": string,
          "type": lonaType
        }
      ),
      lonaType
    );

let undefinedType = Reference("Undefined");

let referenceFromJs = ltype =>
  switch ltype {
  | Reference(name) => Some(name)
  | _ => None
  };

let booleanType = Reference("Boolean");

let numberType = Reference("Number");

let stringType = Reference("String");

let colorType = Named("Color", stringType);

let textStyleType = Named("TextStyle", stringType);

let urlType = Named("URL", stringType);

let handlerType = Function([], Reference("Undefined"));

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

[@bs.deriving jsConverter]
type parameter = {
  name: ParameterKey.t,
  ltype: lonaType,
  defaultValue: option(Js.Json.t)
};

type layerType =
  | View
  | Text
  | Image
  | Animation
  | Children
  | Component(string)
  | Unknown;

type layer = {
  typeName: layerType,
  name: string,
  parameters: StringMap.t(lonaValue),
  children: list(layer)
};

type sizingRule =
  | Fill
  | FitContent
  | Fixed(float);