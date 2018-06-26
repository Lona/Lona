type t = {
  id: string,
  name: option(string),
  color: option(string),
  x: option(float),
  y: option(float),
  blur: option(float),
};

type file = {
  defaultShadow: t,
  shadows: list(t),
};

let emptyShadow = {
  id: "defaultShadowName",
  name: None,
  color: None,
  x: None,
  y: None,
  blur: None,
};

let find = (shadows: list(t), id: string) =>
  switch (shadows |> List.find(t => t.id === id)) {
  | shadow => Some(shadow)
  | exception Not_found => None
  };

let parseFile = content => {
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseShadow = json => {
    id: json |> field("id", string),
    name: json |> optional(field("name", string)),
    color: json |> optional(field("color", string)),
    x: json |> optional(field("x", Json.Decode.float)),
    y: json |> optional(field("y", Json.Decode.float)),
    blur: json |> optional(field("blur", Json.Decode.float)),
  };

  let shadows = parsed |> field("shadows", list(parseShadow));

  let defaultShadow =
    switch (parsed |> optional(field("defaultShadowName", string))) {
    | None => emptyShadow
    | Some(id) =>
      switch (find(shadows, id)) {
      | None => emptyShadow
      | Some(shadow) => shadow
      }
    };

  {shadows, defaultShadow};
};
