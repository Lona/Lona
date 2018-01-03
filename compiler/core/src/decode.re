include Types;

open Json.Decode;

module Types = {
  let lonaType = (json) => {
    let referenceType = (json) => json |> string |> ((x) => Reference(x));
    let namedType = (json) => {
      let named = field("alias", string, json);
      let type_ = field("of", string, json);
      Named(named, Reference(type_))
    };
    json |> either(referenceType, namedType)
  };
};

module Parameters = {
  let parameter = (json) => {
    let name = field("name", string, json);
    let type_ = field("type", Types.lonaType, json);
    let defaultValue = json |> optional(field("defaultValue", (x) => x));
    Parameter(name, type_, defaultValue)
  };
};

module Layer = {
  let layerType = (json) =>
    switch (string(json)) {
    | "View" => View
    | "Text" => Text
    | "Image" => Image
    | "Animation" => Animation
    | "Children" => Children
    | "Component" => Component
    | _ => Unknown
    };
  let rec layer = (json) => {
    let parameterDictionary = (json) =>
      json
      |> Js.Json.decodeObject
      |> Js.Option.getExn
      |> StringMap.fromJsDict
      |> StringMap.mapi((key, value) => Value(Layer.parameterType(key), value));
    let parameters = field("parameters", parameterDictionary, json);
    let type_ = field("type", layerType, json);
    let name = field("name", string, json);
    let children = field("children", list(layer), json);
    Layer(type_, name, parameters, children)
  };
};

let rec logicNode = (json) => {
  let cmp = (json) =>
    switch (string(json)) {
    | "equal to" => Eq
    | "not equal to" => Neq
    | "greater than" => Gt
    | "greater than or equal to" => Gte
    | "less than" => Lt
    | "less than or equal to" => Lte
    | _ => Unknown
    };
  let value = (json) => {
    let identifier = (json) => {
      let type_ = field("type", Types.lonaType, json);
      let path = field("path", list(string), json);
      Logic.Identifier(type_, path)
    };
    let literal = (json) => {
      let type_ = field("type", Types.lonaType, json);
      let data = field("data", (x) => x, json);
      Logic.Literal(Value(type_, data))
    };
    switch (field("type", string, json)) {
    | "identifier" => field("value", identifier, json)
    | "value" => field("value", literal, json)
    | _ => None
    }
  };
  let nodes = at(["nodes"], list(logicNode), json);
  let arg = (path, decoder) => at(["function", "arguments", ...path], decoder, json);
  switch (at(["function", "name"], string, json)) {
  | "assign(lhs, to rhs)" => Logic.Assign(arg(["lhs"], value), arg(["rhs"], value))
  | "if(lhs, is cmp, rhs)" =>
    If(arg(["lhs"], value), arg(["cmp", "value", "data"], cmp), arg(["rhs"], value), Block(nodes))
  | "if(value)" => IfExists(arg(["value"], value), Block(nodes))
  | "add(lhs, to rhs, and assign to value)" =>
    Add(arg(["lhs"], value), arg(["rhs"], value), arg(["value"], value))
  | _ => None
  }
};

module Component = {
  let parameters = (json) => field("parameters", list(Parameters.parameter), json);
  let rootLayer = (json) => field("rootLayer", Layer.layer, json);
  let logic = (json) => Logic.Block(field("logic", list(logicNode), json));
};