open Monad;

let getField = (key: string, fields: LogicEvaluate.Value.recordMembers) =>
  switch (fields#get(key)) {
  | Some(Some(value)) => Some(value)
  | Some(None)
  | None => None
  };

let getColorString = (value: LogicEvaluate.Value.t): option(string) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.color =>
    switch (fields |> getField("value")) {
    | Some({memory: String(css)}) => Some(css)
    | _ => None
    }
  | _ => None
  };

let getColorValue =
    (value: LogicEvaluate.Value.t): option(TokenTypes.colorValue) =>
  switch (getColorString(value)) {
  | Some(css) => Some({css: css})
  | None => None
  };

let getOptional =
    (value: LogicEvaluate.Value.t): option(LogicEvaluate.Value.t) =>
  switch (value.type_, value.memory) {
  | (Cons("Optional", _), Enum("value", [wrappedValue])) =>
    Some(wrappedValue)
  | _ => None
  };

let getFontWeight =
    (value: LogicEvaluate.Value.t): option(TokenTypes.fontWeight) =>
  switch (value.type_, value.memory) {
  | (Cons("FontWeight", _), Enum(tag, _)) =>
    switch (tag) {
    | "ultraLight" => Some(X100)
    | "thin" => Some(X200)
    | "light" => Some(X300)
    | "regular" => Some(X400)
    | "medium" => Some(X500)
    | "semibold" => Some(X600)
    | "bold" => Some(X700)
    | "heavy" => Some(X800)
    | "black" => Some(X900)
    | _ =>
      Js.log("Bad FontWeight: " ++ tag);
      raise(Not_found);
    }
  | _ => None
  };

let getShadowValue =
    (value: LogicEvaluate.Value.t): option(TokenTypes.shadowValue) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.shadow =>
    let [x, y, blur, radius] =
      ["x", "y", "blur", "radius"]
      |> List.map(name => getField(name, fields))
      |> List.map((fieldValue: option(LogicEvaluate.Value.t)) =>
           switch (fieldValue) {
           | Some({memory: Number(value)}) => value
           | _ => 0.0
           }
         );
    let color =
      switch (fields#get("color")) {
      | Some(Some(color)) when getColorValue(color) != None =>
        getColorValue(color) |> Js.Option.getExn
      | _ => {css: "black"}
      };
    Some({x, y, blur, radius, color});
  | _ => None
  };

let getTextStyleValue =
    (value: LogicEvaluate.Value.t): option(TokenTypes.textStyleValue) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.textStyle =>
    let [fontSize, lineHeight, letterSpacing] =
      ["fontSize", "lineHeight", "letterSpacing"]
      |> List.map(name => getField(name, fields))
      |> List.map((fieldValue: option(LogicEvaluate.Value.t)) =>
           switch (fieldValue >>= getOptional) {
           | Some({memory: Number(value)}) => Some(value)
           | _ => None
           }
         );
    let [fontName, fontFamily] =
      ["fontName", "fontFamily"]
      |> List.map(name => getField(name, fields))
      |> List.map((fieldValue: option(LogicEvaluate.Value.t)) =>
           switch (fieldValue >>= getOptional) {
           | Some({memory: String(value)}) => Some(value)
           | _ => None
           }
         );
    let [color] =
      ["color"]
      |> List.map(name => getField(name, fields))
      |> List.map((fieldValue: option(LogicEvaluate.Value.t)) =>
           switch (fieldValue >>= getOptional >>= getColorValue) {
           | Some(colorValue) => Some(colorValue)
           | _ => None
           }
         );
    let [fontWeight] =
      ["fontWeight"]
      |> List.map(name => getField(name, fields))
      |> List.map((fieldValue: option(LogicEvaluate.Value.t)) =>
           switch (fieldValue >>= getFontWeight) {
           | Some(fontWeightValue) => fontWeightValue
           | _ => X400
           }
         );

    Some({
      fontName,
      fontFamily,
      fontSize,
      lineHeight,
      letterSpacing,
      color,
      fontWeight,
    });
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
  } else if (getTextStyleValue(value) != None) {
    let tokenValue = getTextStyleValue(value) |> Js.Option.getExn;
    Some(TextStyle(tokenValue));
  } else {
    None;
  };