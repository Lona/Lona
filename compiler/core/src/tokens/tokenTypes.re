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
and colorValue = colorValueColorValue
and textStyleValueTextStyleValue = {
  fontName: option(string),
  fontFamily: option(string),
  fontWeight,
  fontSize: option(float),
  lineHeight: option(float),
  letterSpacing: option(float),
  color: option(colorValue),
}
and textStyleValue = textStyleValueTextStyleValue
and shadowValueShadowValue = {
  x: float,
  y: float,
  blur: float,
  radius: float,
  color: colorValue,
}
and shadowValue = shadowValueShadowValue
and tokenValue =
  | Color(colorValue)
  | Shadow(shadowValue)
  | TextStyle(textStyleValue)
and tokenToken = {
  qualifiedName: list(string),
  value: tokenValue,
}
and token = tokenToken
and convertedFileContents =
  | FlatTokens(list(token))
and convertedFileConvertedFile = {
  inputPath: string,
  outputPath: string,
  name: string,
  contents: convertedFileContents,
}
and convertedFile = convertedFileConvertedFile
and convertedWorkspaceConvertedWorkspace = {
  files: list(convertedFile),
  flatTokensSchemaVersion: string,
}
and convertedWorkspace = convertedWorkspaceConvertedWorkspace;

module Decode = {
  let rec fontWeight: Js.Json.t => fontWeight =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.string(json);
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
    (json: Js.Json.t) => {
      css: Json.Decode.field("css", Json.Decode.string, json),
    }
  and textStyleValue: Js.Json.t => textStyleValue =
    (json: Js.Json.t) => {
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
    }
  and shadowValue: Js.Json.t => shadowValue =
    (json: Js.Json.t) => {
      x: Json.Decode.field("x", Json.Decode.float, json),
      y: Json.Decode.field("y", Json.Decode.float, json),
      blur: Json.Decode.field("blur", Json.Decode.float, json),
      radius: Json.Decode.field("radius", Json.Decode.float, json),
      color: Json.Decode.field("color", colorValue, json),
    }
  and tokenValue: Js.Json.t => tokenValue =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("value", x => x, json);
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
    (json: Js.Json.t) => {
      qualifiedName:
        Json.Decode.field(
          "qualifiedName",
          Json.Decode.list(Json.Decode.string),
          json,
        ),
      value: Json.Decode.field("value", tokenValue, json),
    }
  and convertedFileContents: Js.Json.t => convertedFileContents =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("value", x => x, json);
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
    (json: Js.Json.t) => {
      inputPath: Json.Decode.field("inputPath", Json.Decode.string, json),
      outputPath: Json.Decode.field("outputPath", Json.Decode.string, json),
      name: Json.Decode.field("name", Json.Decode.string, json),
      contents: Json.Decode.field("contents", convertedFileContents, json),
    }
  and convertedWorkspace: Js.Json.t => convertedWorkspace =
    (json: Js.Json.t) => {
      files:
        Json.Decode.field("files", Json.Decode.list(convertedFile), json),
      flatTokensSchemaVersion:
        Json.Decode.field(
          "flatTokensSchemaVersion",
          Json.Decode.string,
          json,
        ),
    };
};

module Encode = {
  let rec fontWeight: fontWeight => Js.Json.t =
    (value: fontWeight) =>
      switch (value) {
      | X100 => Json.Encode.string("100")
      | X200 => Json.Encode.string("200")
      | X300 => Json.Encode.string("300")
      | X400 => Json.Encode.string("400")
      | X500 => Json.Encode.string("500")
      | X600 => Json.Encode.string("600")
      | X700 => Json.Encode.string("700")
      | X800 => Json.Encode.string("800")
      | X900 => Json.Encode.string("900")
      }
  and colorValue: colorValue => Js.Json.t =
    (value: colorValue) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [("css", Json.Encode.string(value.css))],
        ),
      )
  and textStyleValue: textStyleValue => Js.Json.t =
    (value: textStyleValue) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "fontName",
              Json.Encode.nullable(Json.Encode.string, value.fontName),
            ),
            (
              "fontFamily",
              Json.Encode.nullable(Json.Encode.string, value.fontFamily),
            ),
            ("fontWeight", fontWeight(value.fontWeight)),
            (
              "fontSize",
              Json.Encode.nullable(Json.Encode.float, value.fontSize),
            ),
            (
              "lineHeight",
              Json.Encode.nullable(Json.Encode.float, value.lineHeight),
            ),
            (
              "letterSpacing",
              Json.Encode.nullable(Json.Encode.float, value.letterSpacing),
            ),
            ("color", Json.Encode.nullable(colorValue, value.color)),
          ],
        ),
      )
  and shadowValue: shadowValue => Js.Json.t =
    (value: shadowValue) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("x", Json.Encode.float(value.x)),
            ("y", Json.Encode.float(value.y)),
            ("blur", Json.Encode.float(value.blur)),
            ("radius", Json.Encode.float(value.radius)),
            ("color", colorValue(value.color)),
          ],
        ),
      )
  and tokenValue: tokenValue => Js.Json.t =
    (value: tokenValue) =>
      switch (value) {
      | Color(value0) =>
        let rec case = Json.Encode.string("color");
        let rec encoded = colorValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      | Shadow(value0) =>
        let rec case = Json.Encode.string("shadow");
        let rec encoded = shadowValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      | TextStyle(value0) =>
        let rec case = Json.Encode.string("textStyle");
        let rec encoded = textStyleValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      }
  and token: token => Js.Json.t =
    (value: token) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "qualifiedName",
              Json.Encode.list(Json.Encode.string, value.qualifiedName),
            ),
            ("value", tokenValue(value.value)),
          ],
        ),
      )
  and convertedFileContents: convertedFileContents => Js.Json.t =
    (value: convertedFileContents) =>
      switch (value) {
      | FlatTokens(value0) =>
        let rec case = Json.Encode.string("flatTokens");
        let rec encoded = Json.Encode.list(token, value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      }
  and convertedFile: convertedFile => Js.Json.t =
    (value: convertedFile) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("inputPath", Json.Encode.string(value.inputPath)),
            ("outputPath", Json.Encode.string(value.outputPath)),
            ("name", Json.Encode.string(value.name)),
            ("contents", convertedFileContents(value.contents)),
          ],
        ),
      )
  and convertedWorkspace: convertedWorkspace => Js.Json.t =
    (value: convertedWorkspace) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("files", Json.Encode.list(convertedFile, value.files)),
            (
              "flatTokensSchemaVersion",
              Json.Encode.string(value.flatTokensSchemaVersion),
            ),
          ],
        ),
      );
};