type compilerTarget =
  | JavaScript
  | Swift
  | Xml
  | Reason;

type lonaFunctionParameter = {
  label: string,
  ltype: lonaType,
}
and lonaVariantCase = {
  tag: string,
  ltype: lonaType,
}
[@bs.deriving accessors]
and lonaType =
  | Reference(string)
  | Named(string, lonaType)
  | Array(lonaType)
  | Variant(list(lonaVariantCase))
  | Function(list(lonaFunctionParameter), lonaType);

let unitType = Reference("Unit");

let undefinedType = Reference("Undefined");

let booleanType = Reference("Boolean");

let numberType = Reference("Number");

let stringType = Reference("String");

let colorType = Named("Color", stringType);

let textStyleType = Named("TextStyle", stringType);

let shadowType = Named("Shadow", stringType);

let urlType = Named("URL", stringType);

let handlerType = Function([], Reference("Undefined"));

type lonaValue = {
  ltype: lonaType,
  data: Js.Json.t,
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
  defaultValue: option(Js.Json.t),
};

type layerType =
  | View
  | Text
  | Image
  | VectorGraphic
  | Animation
  | Children
  | Component(string)
  | Unknown;

let layerTypeToString = x =>
  switch (x) {
  | View => "View"
  | Text => "Text"
  | Image => "Image"
  | VectorGraphic => "VectorGraphic"
  | Animation => "Animation"
  | Children => "Children"
  | Component(value) => value
  | Unknown => "Unknown"
  };

type layerParameters = ParameterMap.t(lonaValue);

type platformId =
  | IOS
  | MacOS
  | ReactDOM
  | ReactNative
  | ReactSketchapp
  | ReasonCompiler;

type platformSpecificValue('a) = {
  iOS: 'a,
  macOS: 'a,
  reactDom: 'a,
  reactNative: 'a,
  reactSketchapp: 'a,
};

type accessLevel =
  | Private
  | Internal
  | Public;

type layerMetadata = {
  accessLevel: platformSpecificValue(accessLevel),
  backingElementClass: platformSpecificValue(option(string)),
};

type layer = {
  typeName: layerType,
  name: string,
  styles: list(Styles.namedStyles(option(lonaValue))),
  parameters: layerParameters,
  children: list(layer),
  metadata: layerMetadata,
};

let rec toString = (ltype: lonaType): string =>
  switch (ltype) {
  | Named(_, subtype) => "Named(" ++ toString(subtype) ++ ")"
  | Variant(cases) =>
    "Variant("
    ++ (cases |> List.map(case => case.tag) |> Format.joinWith(", "))
    ++ ")"
  | Array(subtype) => "Array(" ++ toString(subtype) ++ ")"
  | Function(params, returnType) =>
    "Function("
    ++ (
      params
      |> List.map((param: lonaFunctionParameter) =>
           param.label ++ ": " ++ toString(param.ltype)
         )
      |> Format.joinWith(", ")
    )
    ++ ") -> "
    ++ toString(returnType)
  | Reference(name) => "Reference(" ++ name ++ ")"
  };

let rec isFunction = (ltype: lonaType): bool =>
  switch (ltype) {
  | Named(_, subtype) => isFunction(subtype)
  | Function(_) => true
  | _ => false
  };