type fontWeight =
  | X100
  | X200
  | X300
  | X400
  | X500
  | X600
  | X700
  | X800
  | X900
and colorValueColorValue = {css: string}
and colorValue =
  | ColorValue(colorValueColorValue)
and textStyleValueTextStyleValue = {
  fontName: option(string),
  fontFamily: option(string),
  fontWeight,
  fontSize: option(float),
  lineHeight: option(float),
  letterSpacing: option(float),
  color: option(colorValue),
}
and textStyleValue =
  | TextStyleValue(textStyleValueTextStyleValue)
and shadowValueShadowValue = {
  x: float,
  y: float,
  blur: float,
  radius: float,
  color: colorValue,
}
and shadowValue =
  | ShadowValue(shadowValueShadowValue)
and tokenValue =
  | Color(colorValue)
  | Shadow(shadowValue)
  | TextStyle(textStyleValue)
and tokenToken = {
  qualifiedName: list(string),
  value: tokenValue,
}
and token =
  | Token(tokenToken)
and convertedFileContents =
  | FlatTokens(list(token))
and convertedFileConvertedFile = {
  inputPath: string,
  outputPath: string,
  name: string,
  contents: convertedFileContents,
}
and convertedFile =
  | ConvertedFile(convertedFileConvertedFile)
and convertedWorkspaceConvertedWorkspace = {
  files: list(convertedFile),
  flatTokensSchemaVersion: string,
}
and convertedWorkspace =
  | ConvertedWorkspace(convertedWorkspaceConvertedWorkspace);

module Decode = {
  let rec fontWeight: Js.Json.t => fontWeight =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "100" => X100
      | "200" => X200
      | "300" => X300
      | "400" => X400
      | "500" => X500
      | "600" => X600
      | "700" => X700
      | "800" => X800
      | "900" => X900
      | _ =>
        Js.log("Error decoding fontWeight");
        raise(Not_found);
      };
    }
  and colorValue: Js.Json.t => colorValue =
    (json: Js.Json.t) =>
      ColorValue({css: Json.Decode.field("css", Json.Decode.string, json)})
  and textStyleValue: Js.Json.t => textStyleValue =
    (json: Js.Json.t) =>
      TextStyleValue({
        fontName:
          Json.Decode.optional(
            Json.Decode.field("fontName", Json.Decode.string),
            json,
          ),
        fontFamily:
          Json.Decode.optional(
            Json.Decode.field("fontFamily", Json.Decode.string),
            json,
          ),
        fontWeight: Json.Decode.field("fontWeight", fontWeight, json),
        fontSize:
          Json.Decode.optional(
            Json.Decode.field("fontSize", Json.Decode.float),
            json,
          ),
        lineHeight:
          Json.Decode.optional(
            Json.Decode.field("lineHeight", Json.Decode.float),
            json,
          ),
        letterSpacing:
          Json.Decode.optional(
            Json.Decode.field("letterSpacing", Json.Decode.float),
            json,
          ),
        color:
          Json.Decode.optional(Json.Decode.field("color", colorValue), json),
      })
  and shadowValue: Js.Json.t => shadowValue =
    (json: Js.Json.t) =>
      ShadowValue({
        x: Json.Decode.field("x", Json.Decode.float, json),
        y: Json.Decode.field("y", Json.Decode.float, json),
        blur: Json.Decode.field("blur", Json.Decode.float, json),
        radius: Json.Decode.field("radius", Json.Decode.float, json),
        color: Json.Decode.field("color", colorValue, json),
      })
  and tokenValue: Js.Json.t => tokenValue =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "color" =>
        let rec decoded = colorValue(data);
        Color(decoded);
      | "shadow" =>
        let rec decoded = shadowValue(data);
        Shadow(decoded);
      | "textStyle" =>
        let rec decoded = textStyleValue(data);
        TextStyle(decoded);
      | _ =>
        Js.log("Error decoding tokenValue");
        raise(Not_found);
      };
    }
  and token: Js.Json.t => token =
    (json: Js.Json.t) =>
      Token({
        qualifiedName:
          Json.Decode.field(
            "qualifiedName",
            Json.Decode.list(Json.Decode.string),
            json,
          ),
        value: Json.Decode.field("value", tokenValue, json),
      })
  and convertedFileContents: Js.Json.t => convertedFileContents =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "flatTokens" =>
        let rec decoded = Json.Decode.list(token, data);
        FlatTokens(decoded);
      | _ =>
        Js.log("Error decoding convertedFileContents");
        raise(Not_found);
      };
    }
  and convertedFile: Js.Json.t => convertedFile =
    (json: Js.Json.t) =>
      ConvertedFile({
        inputPath: Json.Decode.field("inputPath", Json.Decode.string, json),
        outputPath: Json.Decode.field("outputPath", Json.Decode.string, json),
        name: Json.Decode.field("name", Json.Decode.string, json),
        contents: Json.Decode.field("contents", convertedFileContents, json),
      })
  and convertedWorkspace: Js.Json.t => convertedWorkspace =
    (json: Js.Json.t) =>
      ConvertedWorkspace({
        files:
          Json.Decode.field("files", Json.Decode.list(convertedFile), json),
        flatTokensSchemaVersion:
          Json.Decode.field(
            "flatTokensSchemaVersion",
            Json.Decode.string,
            json,
          ),
      });
};