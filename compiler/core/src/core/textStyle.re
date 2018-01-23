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

let normalizeFontWeight =
  fun
  | Some("normal") => Some("400")
  | Some("bold") => Some("700")
  | Some(_) as value => value
  | None => None;

let parseFile = (filename) => {
  let content = Node.Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseTextStyle = (json) => {
    id: json |> field("id", string),
    name: json |> optional(field("name", string)),
    fontName: json |> optional(field("fontName", string)),
    fontFamily: json |> optional(field("fontFamily", string)),
    fontWeight: json |> optional(field("fontWeight", string)) |> normalizeFontWeight,
    fontSize: json |> optional(field("fontSize", float)),
    lineHeight: json |> optional(field("lineHeight", float)),
    letterSpacing: json |> optional(field("letterSpacing", float)),
    color: json |> optional(field("color", string))
  };
  field("styles", list(parseTextStyle), parsed)
};

let find = (textStyles: list(t), id: string) =>
  switch (textStyles |> List.find((textStyle) => textStyle.id == id)) {
  | color => Some(color)
  | exception Not_found => None
  };