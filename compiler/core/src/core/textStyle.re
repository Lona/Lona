type t = {
  id: string,
  name: option(string),
  fontName: option(string),
  fontFamily: option(string),
  fontWeight: option(string),
  fontSize: option(float),
  lineHeight: option(float),
  letterSpacing: option(float),
  color: option(string)
};

type file = {
  styles: list(t),
  defaultStyle: t
};

let emptyStyle = {
  id: "defaultStyle",
  name: None,
  fontName: None,
  fontFamily: None,
  fontWeight: None,
  fontSize: None,
  lineHeight: None,
  letterSpacing: None,
  color: None
};

let normalizeFontWeight =
  fun
  | Some("normal") => Some("400")
  | Some("bold") => Some("700")
  | Some(_) as value => value
  | None => None;

let normalizeId = (string) => Js.String.replaceByRe([%re "/\\+/g"], "Plus", string);

let find = (textStyles: list(t), id: string) => {
  let normalizedId = normalizeId(id);
  switch (textStyles |> List.find((textStyle) => textStyle.id == normalizedId)) {
  | textStyle => Some(textStyle)
  | exception Not_found => None
  }
};

let parseFile = (filename) => {
  let content = Node.Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseTextStyle = (json) => {
    id: json |> field("id", string) |> normalizeId,
    name: json |> optional(field("name", string)),
    fontName: json |> optional(field("fontName", string)),
    fontFamily: json |> optional(field("fontFamily", string)),
    fontWeight: json |> optional(field("fontWeight", string)) |> normalizeFontWeight,
    fontSize: json |> optional(field("fontSize", Json.Decode.float)),
    lineHeight: json |> optional(field("lineHeight", Json.Decode.float)),
    letterSpacing: json |> optional(field("letterSpacing", Json.Decode.float)),
    color: json |> optional(field("color", string))
  };
  let styles = parsed |> field("styles", list(parseTextStyle));
  let defaultStyle =
    switch (parsed |> optional(field("defaultStyleName", string))) {
    | None => emptyStyle
    | Some(id) =>
      switch (find(styles, id)) {
      | None => emptyStyle
      | Some(textStyle) => textStyle
      }
    };
  {styles, defaultStyle}
};