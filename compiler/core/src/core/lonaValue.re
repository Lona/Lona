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
  | ParameterKey.Opacity => number(1.)
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
  | ParameterKey.ResizeMode => string("cover")
  /* Accessibility */
  | ParameterKey.AccessibilityLabel => string("")
  | ParameterKey.AccessibilityHint => string("")
  | ParameterKey.AccessibilityRole => string("")
  | ParameterKey.AccessibilityValue => string("")
  /* Interactivity */
  | ParameterKey.Pressed => boolean(false)
  | ParameterKey.Hovered => boolean(false)
  | ParameterKey.OnPress => null()
  };

let defaultValueForParameter = name => parameterDefaultValue(name);

let decodeNumber = (value: Types.lonaValue): float =>
  value.data |> Json.Decode.float;

let decodeUrl = (value: Types.lonaValue): string =>
  value.data |> Json.Decode.string;

let isOptionalTypeName = (typeName: string): bool =>
  Js.String.endsWith("?", typeName);

let isOptionalType = (ltype: Types.lonaType): bool =>
  switch (ltype) {
  | Reference(typeName) when isOptionalTypeName(typeName) => true
  | _ => false
  };

let unwrapOptionalType = (ltype: Types.lonaType): Types.lonaType =>
  switch (ltype) {
  | Reference(typeName) when isOptionalTypeName(typeName) =>
    let unwrappedTypeName =
      String.sub(typeName, 0, String.length(typeName) - 1);
    Reference(unwrappedTypeName);
  | _ =>
    Js.log2("Failed to unwrap type -- not an optional type", ltype);
    raise(Not_found);
  };

let decodeOptional = (value: Types.lonaValue): option(Types.lonaValue) =>
  switch (value.ltype) {
  | Reference(typeName) when isOptionalTypeName(typeName) =>
    let unwrappedType = unwrapOptionalType(value.ltype);
    let case = value.data |> Json.Decode.field("case", Json.Decode.string);
    switch (case) {
    | "Some" =>
      let unwrappedData = value.data |> Json.Decode.field("data", x => x);
      Some({ltype: unwrappedType, data: unwrappedData});
    | "None"
    | _ => None
    };
  | _ =>
    Js.log3(
      "Failed to unwrap value -- not an optional value",
      value.ltype,
      value.data,
    );
    raise(Not_found);
  };

let decodeCollapsedOptional =
    (value: Types.lonaValue): option(Types.lonaValue) =>
  value.data
  |> Json.Decode.either(Json.Decode.nullAs(None), unwrappedData =>
       (
         Some({ltype: value.ltype, data: unwrappedData}):
           option(Types.lonaValue)
       )
     );

/* Optional values are stored in 2 formats, depending on where they appear
   in the save file. Eventually these should be unified. One format is more compact,
   using special cases of types to store less data. In this function, we convert
   the compact format into the verbose format.

   E.g. in the more verbose format, Optional is specified as an object, { case, data }.
   In the compact format, we treat "null" data as the case "None" and just store
   the data field (not wrapped in an object). */
let expandDecodedValue = (value: Types.lonaValue): Types.lonaValue =>
  switch (
    /* Test if the type is optional and the data is not an object */
    value.ltype |> isOptionalType,
    value.data |> Json.Decode.optional(Json.Decode.dict(x => x)),
  ) {
  | (true, None) =>
    let caseName =
      switch (value |> decodeCollapsedOptional) {
      | Some(_) => "Some"
      | None => "None"
      };

    let obj = Js.Dict.empty();
    Js.Dict.set(obj, "case", Js.Json.string(caseName));
    Js.Dict.set(obj, "data", value.data);
    {ltype: value.ltype, data: Js.Json.object_(obj)};
  | _ => value
  };