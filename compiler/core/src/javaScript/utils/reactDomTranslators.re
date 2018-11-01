let styleUnit = "px";

let convertUnitlessStyle = value =>
  string_of_int(value |> Json.Decode.int) ++ styleUnit;

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
  | Types.Animation => "Animation"
  | Types.Children => "Children"
  | Types.Component(value) => value
  | _ => "Unknown"
  };

let variableNames = variable =>
  switch (variable) {
  | ParameterKey.Image => "src"
  | ParameterKey.OnPress => "onClick"
  | _ => variable |> ParameterKey.toString
  };