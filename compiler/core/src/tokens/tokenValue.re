let getColorString = (value: LogicEvaluate.Value.t): option(string) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.color =>
    let value = fields#get("value");
    switch (value) {
    | Some(Some({memory: String(css)})) => Some(css)
    | _ => None
    };
  | _ => None
  };

let getColorValue =
    (value: LogicEvaluate.Value.t): option(TokenTypes.colorValue) =>
  switch (getColorString(value)) {
  | Some(css) => Some({css: css})
  | None => None
  };

let getShadowValue =
    (value: LogicEvaluate.Value.t): option(TokenTypes.shadowValue) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.shadow =>
    let [x, y, blur, radius] =
      ["x", "y", "blur", "radius"]
      |> List.map(name =>
           switch (fields#get(name)) {
           | Some(Some({memory: Number(value)})) => value
           | _ => 0.0
           }
         );
    let colorValue =
      switch (fields#get("color")) {
      | Some(Some(color)) when getColorValue(color) != None =>
        getColorValue(color) |> Js.Option.getExn
      | _ => {css: "black"}
      };
    Some({x, y, blur, radius, color: colorValue});
  | _ => None
  };

let create = (value: LogicEvaluate.Value.t): option(TokenTypes.tokenValue) =>
  /* Js.log(LogicEvaluate.Value.valueDescription(value)); */
  if (getColorValue(value) != None) {
    let tokenValue = getColorValue(value) |> Js.Option.getExn;
    Some(Color(tokenValue));
  } else if (getShadowValue(value) != None) {
    let tokenValue = getShadowValue(value) |> Js.Option.getExn;
    Some(Shadow(tokenValue));
  } else {
    None;
  };