let styleUnit = "px";

let convertUnitlessStyle = (value: Js.Json.t) =>
  switch (value |> Js.Json.classify) {
  | Js.Json.JSONString(string) => string
  | Js.Json.JSONNumber(float) => Format.floatToString(float) ++ "px"
  | _ =>
    Js.log("Invalid unitless value");
    raise(Not_found);
  };

let isUnitNumberParameter = key =>
  switch (key) {
  | ParameterKey.MarginTop => true
  | ParameterKey.MarginRight => true
  | ParameterKey.MarginBottom => true
  | ParameterKey.MaxHeight => true
  | ParameterKey.MaxWidth => true
  | ParameterKey.MarginLeft => true
  | ParameterKey.PaddingTop => true
  | ParameterKey.PaddingRight => true
  | ParameterKey.PaddingBottom => true
  | ParameterKey.PaddingLeft => true
  | ParameterKey.Width => true
  | ParameterKey.Height => true
  | ParameterKey.BorderRadius => true
  | ParameterKey.BorderWidth => true
  | _ => false
  };

let layerTypeTags = layerType =>
  switch (layerType) {
  | Types.View => "div"
  | Types.Text => "span"
  | Types.Image => "img"
  | Types.VectorGraphic => "svg"
  | Types.Animation => "Animation"
  | Types.Children => "Children"
  | Types.Component(value) => value
  | _ => "UnknownLayerTypeTag"
  };

let variableNames = variable =>
  switch (variable) {
  | ParameterKey.Image => "src"
  | ParameterKey.OnPress => "onClick"
  | ParameterKey.AccessibilityLabel => "aria-label"
  | _ => variable |> ParameterKey.toString
  };

let styleVariableNames = variable =>
  switch (variable) {
  | ParameterKey.ResizeMode => "objectFit"
  | _ => variable |> ParameterKey.toString
  };

let resizeMode = value =>
  switch (value) {
  | "stretch" => "fill"
  | "cover" => "cover"
  | "contain" => "contain"
  | _ =>
    Js.log("Invalid resizeMode");
    raise(Not_found);
  };