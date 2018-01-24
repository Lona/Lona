include Types;

open Json.Decode;

let parameterTypeMap =
  [
    ("text", Types.stringType),
    ("visible", Types.booleanType),
    ("numberOfLines", Types.numberType),
    ("backgroundColor", Types.colorType),
    ("image", Types.urlType),
    /* Styles */
    ("alignItems", Types.stringType),
    ("alignSelf", Types.stringType),
    ("flex", Types.numberType),
    ("flexDirection", Types.stringType),
    ("font", Types.textStyleType),
    ("justifyContent", Types.stringType),
    ("marginTop", Types.numberType),
    ("marginRight", Types.numberType),
    ("marginBottom", Types.numberType),
    ("marginLeft", Types.numberType),
    ("paddingTop", Types.numberType),
    ("paddingRight", Types.numberType),
    ("paddingBottom", Types.numberType),
    ("paddingLeft", Types.numberType),
    ("borderRadius", Types.numberType),
    ("width", Types.numberType),
    ("height", Types.numberType)
  ]
  |> StringMap.fromList;

exception UnknownParameter(string);

let parameterType = (name) =>
  switch (StringMap.find(name, parameterTypeMap)) {
  | item => item
  | exception Not_found =>
    /* Js.log2("Unknown built-in parameter when deserializing:", name);
       Reference("BuiltIn-Null") */
    raise(UnknownParameter(name))
  };

module Types = {
  let lonaType = (json) => {
    let referenceType = (json) => json |> string |> ((x) => Reference(x));
    let namedType = (json) => {
      let named = field("alias", string, json);
      let ltype = field("of", string, json);
      Named(named, Reference(ltype))
    };
    json |> either(referenceType, namedType)
  };
};

module Parameters = {
  let parameter = (json) => {
    name: json |> field("name", string),
    ltype: json |> field("type", Types.lonaType),
    defaultValue: json |> optional(field("defaultValue", (x) => x))
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
      |> StringMap.mapi((key, value) => {ltype: parameterType(key), data: value});
    {
      typeName: field("type", layerType, json),
      name: field("name", string, json),
      parameters: field("parameters", parameterDictionary, json),
      children: field("children", list(layer), json)
    }
  };
};

exception UnknownLogicValue(string);

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
      let ltype = field("type", Types.lonaType, json);
      let path = field("path", list(string), json);
      Logic.Identifier(ltype, path)
    };
    let literal = (json) => {
      let ltype = field("type", Types.lonaType, json);
      let data = field("data", (x) => x, json);
      Logic.Literal({ltype, data})
    };
    switch (field("type", string, json)) {
    | "identifier" => field("value", identifier, json)
    | "value" => field("value", literal, json)
    | value => raise(UnknownLogicValue(value))
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