let null = () : Types.lonaValue => {
  ltype: Types.undefinedType,
  data: Js.Json.null
};

let boolean = value : Types.lonaValue => {
  ltype: Types.booleanType,
  data: Js.Json.boolean(Js.Boolean.to_js_boolean(value))
};

let number = value : Types.lonaValue => {
  ltype: Types.numberType,
  data: Js.Json.number(value)
};

let string = value : Types.lonaValue => {
  ltype: Types.stringType,
  data: Js.Json.string(value)
};

let color = value : Types.lonaValue => {
  ltype: Types.colorType,
  data: Js.Json.string(value)
};

let textStyle = value : Types.lonaValue => {
  ltype: Types.textStyleType,
  data: Js.Json.string(value)
};

let url = value : Types.lonaValue => {
  ltype: Types.urlType,
  data: Js.Json.string(value)
};

let parameterDefaultValueMap =
  [
    ("text", string("")),
    ("visible", boolean(true)),
    ("numberOfLines", number(0.)),
    ("backgroundColor", color("transparent")),
    ("image", url("")),
    /* Styles */
    ("alignItems", string("stretch")),
    ("alignSelf", string("flex-start")),
    ("flex", number(0.)),
    ("flexDirection", string("column")),
    ("font", textStyle("defaultStyle")),
    ("textStyle", textStyle("defaultStyle")), /* ? */
    ("justifyContent", string("flex-start")),
    ("marginTop", number(0.)),
    ("marginRight", number(0.)),
    ("marginBottom", number(0.)),
    ("marginLeft", number(0.)),
    ("paddingTop", number(0.)),
    ("paddingRight", number(0.)),
    ("paddingBottom", number(0.)),
    ("paddingLeft", number(0.)),
    ("borderRadius", number(0.)),
    ("borderWidth", number(0.)),
    ("borderColor", color("transparent")),
    ("width", number(0.)),
    ("height", number(0.)),
    /* Interactivity */
    ("pressed", boolean(false)),
    ("hovered", boolean(false)),
    ("onPress", null())
  ]
  |> StringMap.fromList;

let defaultValueForParameter = name =>
  StringMap.find(name, parameterDefaultValueMap);