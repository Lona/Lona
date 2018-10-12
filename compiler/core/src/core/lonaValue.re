let null = (): Types.lonaValue => {
  ltype: Types.undefinedType,
  data: Js.Json.null,
};

let boolean = value: Types.lonaValue => {
  ltype: Types.booleanType,
  data: Js.Json.boolean(value),
};

let number = value: Types.lonaValue => {
  ltype: Types.numberType,
  data: Js.Json.number(value),
};

let string = value: Types.lonaValue => {
  ltype: Types.stringType,
  data: Js.Json.string(value),
};

let color = value: Types.lonaValue => {
  ltype: Types.colorType,
  data: Js.Json.string(value),
};

let textStyle = value: Types.lonaValue => {
  ltype: Types.textStyleType,
  data: Js.Json.string(value),
};

let url = value: Types.lonaValue => {
  ltype: Types.urlType,
  data: Js.Json.string(value),
};

let parameterDefaultValue = key =>
  switch (key) {
  | ParameterKey.Text => string("")
  | ParameterKey.Visible => boolean(true)
  | ParameterKey.NumberOfLines => number(0.)
  | ParameterKey.BackgroundColor => color("transparent")
  | ParameterKey.Image => url("")
  /* Styles */
  | ParameterKey.AlignItems => string("stretch")
  | ParameterKey.AlignSelf => string("flex-start")
  | ParameterKey.Flex => number(0.)
  | ParameterKey.Display => null()
  | ParameterKey.TextAlign => string("left")
  | ParameterKey.FlexDirection => string("column")
  | ParameterKey.TextStyle => textStyle("defaultStyle") /* ? */
  | ParameterKey.JustifyContent => string("flex-start")
  | ParameterKey.MarginTop => number(0.)
  | ParameterKey.MarginRight => number(0.)
  | ParameterKey.MarginBottom => number(0.)
  | ParameterKey.MarginLeft => number(0.)
  | ParameterKey.PaddingTop => number(0.)
  | ParameterKey.PaddingRight => number(0.)
  | ParameterKey.PaddingBottom => number(0.)
  | ParameterKey.PaddingLeft => number(0.)
  | ParameterKey.BorderRadius => number(0.)
  | ParameterKey.BorderWidth => number(0.)
  | ParameterKey.BorderColor => color("transparent")
  | ParameterKey.Width => number(0.)
  | ParameterKey.Height => number(0.)
  /* Interactivity */
  | ParameterKey.Pressed => boolean(false)
  | ParameterKey.Hovered => boolean(false)
  | ParameterKey.OnPress => null()
  };

let defaultValueForParameter = name => parameterDefaultValue(name);

let decodeNumber = (value: Types.lonaValue): float =>
  value.data |> Json.Decode.float;

let isOptionalType = (ltype: Types.lonaType): bool =>
  switch (ltype) {
  | Reference(typeName) when Js.String.endsWith("?", typeName) => true
  | _ => false
  };

let unwrapOptionalType = (ltype: Types.lonaType): Types.lonaType =>
  switch (ltype) {
  | Reference(typeName) when Js.String.endsWith("?", typeName) =>
    let unwrappedTypeName =
      String.sub(typeName, 0, String.length(typeName) - 1);
    Reference(unwrappedTypeName);
  | _ =>
    Js.log2("Failed to unwrap type -- not an optional type", ltype);
    raise(Not_found);
  };

let unwrapOptional = (value: Types.lonaValue): Types.lonaValue =>
  switch (value.ltype) {
  | Reference(typeName) when Js.String.endsWith("?", typeName) =>
    let unwrappedType = unwrapOptionalType(value.ltype);
    let unwrappedData = value.data |> Json.Decode.field("data", x => x);
    {ltype: unwrappedType, data: unwrappedData};
  | _ =>
    Js.log3(
      "Failed to unwrap value -- not an optional value",
      value.ltype,
      value.data,
    );
    raise(Not_found);
  };