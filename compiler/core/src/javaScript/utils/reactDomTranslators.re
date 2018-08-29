open ParameterKey;

let isUnitNumberParameter = key =>
  switch key {
  | MarginTop => true
  | MarginRight => true
  | MarginBottom => true
  | MarginLeft => true
  | PaddingTop => true
  | PaddingRight => true
  | PaddingBottom => true
  | PaddingLeft => true
  | Width => true
  | Height => true
  | BorderRadius => true
  | BorderWidth => true
  | _ => false
  };

let layerTypeTags = layerType =>
  switch layerType {
  | Types.View => "div"
  | Types.Text => "span"
  | Types.Image => "img"
  | Types.Animation => "Animation"
  | Types.Children => "Children"
  | Types.Component(value) => value
  | _ => "Unknown"
  };

let variableNames = variable =>
  switch variable {
  | ParameterKey.OnPress => "onClick"
  | _ => variable |> ParameterKey.toString
  };
