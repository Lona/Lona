type t = {
  id: string,
  name: string,
  value: string,
  comment: option(string)
};

type colorValue =
  | Inline(string)
  | Reference(t);

let parseFile = content => {
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseColor = json => {
    id: field("id", string, json),
    name: field("name", string, json),
    value: field("value", string, json),
    comment: json |> optional(field("comment", string))
  };
  field("colors", list(parseColor), parsed);
};

let find = (colors: list(t), id: string) =>
  switch (colors |> List.find(color => color.id == id)) {
  | color => Some(color)
  | exception Not_found => None
  };
