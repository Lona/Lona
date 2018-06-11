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

let parameterDefaultValue = (key) => {
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
  }
};

let defaultValueForParameter = name => parameterDefaultValue(name);