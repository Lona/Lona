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
  qualifiedName: Reason.List.t(string),
  value: tokenValue,
}
and token = tokenToken
and convertedFileContents =
  | FlatTokens(Reason.List.t(token))
  | MdxString(string)
and convertedFileConvertedFile = {
  inputPath: string,
  outputPath: string,
  name: string,
  contents: convertedFileContents,
}
and convertedFile = convertedFileConvertedFile
and convertedWorkspaceConvertedWorkspace = {
  files: Reason.List.t(convertedFile),
  flatTokensSchemaVersion: string,
}
and convertedWorkspace = convertedWorkspaceConvertedWorkspace;

module Decode = {
  let rec decodeFontWeight: Js.Json.t => fontWeight =
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
  and decodeColorValue: Js.Json.t => colorValue =
    (json: Js.Json.t) => {
      css: Json.Decode.field("css", Json.Decode.string, json),
    }
  and decodeTextStyleValue: Js.Json.t => textStyleValue =
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
      fontWeight: Json.Decode.field("fontWeight", decodeFontWeight, json),
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
        Json.Decode.optional(
          Json.Decode.field("color", decodeColorValue),
          json,
        ),
    }
  and decodeShadowValue: Js.Json.t => shadowValue =
    (json: Js.Json.t) => {
      x: Json.Decode.field("x", Json.Decode.float, json),
      y: Json.Decode.field("y", Json.Decode.float, json),
      blur: Json.Decode.field("blur", Json.Decode.float, json),
      radius: Json.Decode.field("radius", Json.Decode.float, json),
      color: Json.Decode.field("color", decodeColorValue, json),
    }
  and decodeTokenValue: Js.Json.t => tokenValue =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("value", x => x, json);
      switch (case) {
      | "color" =>
        let rec decoded = decodeColorValue(data);
        Color(decoded);
      | "shadow" =>
        let rec decoded = decodeShadowValue(data);
        Shadow(decoded);
      | "textStyle" =>
        let rec decoded = decodeTextStyleValue(data);
        TextStyle(decoded);
      | _ =>
        Js.log("Error decoding tokenValue");
        raise(Not_found);
      };
    }
  and decodeToken: Js.Json.t => token =
    (json: Js.Json.t) => {
      qualifiedName:
        Json.Decode.field(
          "qualifiedName",
          Reason.List.decode(Json.Decode.string),
          json,
        ),
      value: Json.Decode.field("value", decodeTokenValue, json),
    }
  and decodeConvertedFileContents: Js.Json.t => convertedFileContents =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("value", x => x, json);
      switch (case) {
      | "flatTokens" =>
        let rec decoded = Reason.List.decode(decodeToken, data);
        FlatTokens(decoded);
      | "mdxString" =>
        let rec decoded = Json.Decode.string(data);
        MdxString(decoded);
      | _ =>
        Js.log("Error decoding convertedFileContents");
        raise(Not_found);
      };
    }
  and decodeConvertedFile: Js.Json.t => convertedFile =
    (json: Js.Json.t) => {
      inputPath: Json.Decode.field("inputPath", Json.Decode.string, json),
      outputPath: Json.Decode.field("outputPath", Json.Decode.string, json),
      name: Json.Decode.field("name", Json.Decode.string, json),
      contents:
        Json.Decode.field("contents", decodeConvertedFileContents, json),
    }
  and decodeConvertedWorkspace: Js.Json.t => convertedWorkspace =
    (json: Js.Json.t) => {
      files:
        Json.Decode.field(
          "files",
          Reason.List.decode(decodeConvertedFile),
          json,
        ),
      flatTokensSchemaVersion:
        Json.Decode.field(
          "flatTokensSchemaVersion",
          Json.Decode.string,
          json,
        ),
    };
};

module Encode = {
  let rec encodeFontWeight: fontWeight => Js.Json.t =
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
  and encodeColorValue: colorValue => Js.Json.t =
    (value: colorValue) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [("css", Json.Encode.string(value.css))],
        ),
      )
  and encodeTextStyleValue: textStyleValue => Js.Json.t =
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
            ("fontWeight", encodeFontWeight(value.fontWeight)),
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
            ("color", Json.Encode.nullable(encodeColorValue, value.color)),
          ],
        ),
      )
  and encodeShadowValue: shadowValue => Js.Json.t =
    (value: shadowValue) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("x", Json.Encode.float(value.x)),
            ("y", Json.Encode.float(value.y)),
            ("blur", Json.Encode.float(value.blur)),
            ("radius", Json.Encode.float(value.radius)),
            ("color", encodeColorValue(value.color)),
          ],
        ),
      )
  and encodeTokenValue: tokenValue => Js.Json.t =
    (value: tokenValue) =>
      switch (value) {
      | Color(value0) =>
        let rec case = Json.Encode.string("color");
        let rec encoded = encodeColorValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      | Shadow(value0) =>
        let rec case = Json.Encode.string("shadow");
        let rec encoded = encodeShadowValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      | TextStyle(value0) =>
        let rec case = Json.Encode.string("textStyle");
        let rec encoded = encodeTextStyleValue(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      }
  and encodeToken: token => Js.Json.t =
    (value: token) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "qualifiedName",
              Reason.List.encode(Json.Encode.string, value.qualifiedName),
            ),
            ("value", encodeTokenValue(value.value)),
          ],
        ),
      )
  and encodeConvertedFileContents: convertedFileContents => Js.Json.t =
    (value: convertedFileContents) =>
      switch (value) {
      | FlatTokens(value0) =>
        let rec case = Json.Encode.string("flatTokens");
        let rec encoded = Reason.List.encode(encodeToken, value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      | MdxString(value0) =>
        let rec case = Json.Encode.string("mdxString");
        let rec encoded = Json.Encode.string(value0);
        Json.Encode.object_([("type", case), ("value", encoded)]);
      }
  and encodeConvertedFile: convertedFile => Js.Json.t =
    (value: convertedFile) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("inputPath", Json.Encode.string(value.inputPath)),
            ("outputPath", Json.Encode.string(value.outputPath)),
            ("name", Json.Encode.string(value.name)),
            ("contents", encodeConvertedFileContents(value.contents)),
          ],
        ),
      )
  and encodeConvertedWorkspace: convertedWorkspace => Js.Json.t =
    (value: convertedWorkspace) =>
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("files", Reason.List.encode(encodeConvertedFile, value.files)),
            (
              "flatTokensSchemaVersion",
              Json.Encode.string(value.flatTokensSchemaVersion),
            ),
          ],
        ),
      );
};