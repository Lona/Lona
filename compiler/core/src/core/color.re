type t = {
  id: string,
  name: string,
  value: string,
  comment: option(string),
  shouldGenerateCode: Types.platformSpecificValue(bool),
};

type colorValue =
  | Inline(string)
  | Reference(t);

module Metadata = {
  open Json.Decode;
  let valueDecoder = (decoder, defaultValue, json) =>
    switch (optional(decoder, json)) {
    | Some(value) => value
    | None => defaultValue
    };
  let fieldDecoder = (decoder, defaultValue, keyPath, json) =>
    switch (optional(at(keyPath, x => x), json)) {
    | Some(fieldJson) => valueDecoder(decoder, defaultValue, fieldJson)
    | None => defaultValue
    };
  let platformSpecificValue =
      (pathPrefix, fieldDecoder, json: Js.Json.t)
      : Types.platformSpecificValue('a) => {
    iOS: fieldDecoder(pathPrefix @ ["ios"], json),
    macOS: fieldDecoder(pathPrefix @ ["macos"], json),
    reactDom: fieldDecoder(pathPrefix @ ["reactdom"], json),
    reactNative: fieldDecoder(pathPrefix @ ["reactnative"], json),
    reactSketchapp: fieldDecoder(pathPrefix @ ["reactSketchapp"], json),
  };
};

let parseFile = content => {
  let parsed = content |> Js.Json.parseExn;
  open Json.Decode;
  let parseColor = json => {
    id: field("id", string, json),
    name: field("name", string, json),
    value: field("value", string, json),
    comment: json |> optional(field("comment", string)),
    shouldGenerateCode:
      json
      |> Metadata.platformSpecificValue(
           ["metadata", "shouldGenerateCode"],
           Metadata.fieldDecoder(Json.Decode.bool, true),
         ),
  };
  field("colors", list(parseColor), parsed);
};

let find = (colors: list(t), id: string) =>
  switch (colors |> List.find(color => color.id == id)) {
  | color => Some(color)
  | exception Not_found => None
  };