exception UnknownAccessLevel(string);

let accessLevel = (json: Js.Json.t) =>
  switch (Json.Decode.string(json)) {
  | "private" => Types.Private
  | "internal" => Types.Internal
  | "public" => Types.Public
  | level =>
    Js.log("ERROR: Bad access level");
    raise(UnknownAccessLevel(level));
  };

let valueDecoder = (decoder, defaultValue, json) =>
  switch (Json.Decode.optional(decoder, json)) {
  | Some(value) => value
  | None => defaultValue
  };

let fieldDecoder = (decoder, defaultValue, keyPath, json) =>
  switch (Json.Decode.optional(Json.Decode.at(keyPath, x => x), json)) {
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