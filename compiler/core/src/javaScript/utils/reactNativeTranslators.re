let variableNames = variable =>
  switch (variable) {
  | ParameterKey.Image => "source"
  | _ => variable |> ParameterKey.toString
  };