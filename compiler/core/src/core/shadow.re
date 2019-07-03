type t = {
  id: string,
  name: string,
  color: string,
  x: float,
  y: float,
  blur: float,
};

type file = {
  styles: list(t),
  defaultStyle: t,
};

type shadowValue =
  | Inline(string)
  | Reference(t);

let emptyStyle = {
  id: "defaultShadow",
  name: "",
  color: "black",
  x: 0.,
  y: 0.,
  blur: 0.,
};

let defaultFile = {styles: [emptyStyle], defaultStyle: emptyStyle};

let find = (shadows: list(t), id: string) =>
  switch (shadows |> List.find(shadow => shadow.id == id)) {
  | shadow => Some(shadow)
  | exception Not_found => None
  };

let parseFile = content => {
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;

  let parseShadow = json => {
    id: field("id", string, json),
    name: field("name", string, json),
    color: field("color", string, json),
    x: field("x", float, json),
    y: field("y", float, json),
    blur: field("blur", float, json),
  };

  let shadows = parsed |> field("shadows", list(parseShadow));
  let defaultStyle =
    switch (parsed |> optional(field("defaultStyleName", string))) {
    | None => emptyStyle
    | Some(id) =>
      switch (find(shadows, id)) {
      | None => emptyStyle
      | Some(textStyle) => textStyle
      }
    };

  {styles: shadows, defaultStyle};
};