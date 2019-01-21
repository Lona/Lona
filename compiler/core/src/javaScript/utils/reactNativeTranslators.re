let variableNames = variable =>
  switch (variable) {
  | ParameterKey.Image => "source"
  | ParameterKey.OnAccessibilityActivate => "onAccessibilityTap"
  | _ => variable |> ParameterKey.toString
  };