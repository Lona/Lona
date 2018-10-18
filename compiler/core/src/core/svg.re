type point = {
  x: float,
  y: float,
};

type size = {
  width: float,
  height: float,
};

type rect = {
  origin: point,
  size,
};

type strokeLineCap =
  | Butt
  | Round
  | Square;

type style = {
  fill: option(string),
  stroke: option(string),
  strokeWidth: float,
  strokeLineCap,
};

type circleParams = {
  center: point,
  radius: float,
  style,
};

type pathCommand =
  | Move(point)
  | Line(point)
  | QuadCurve(point, point)
  | CubicCurve(point, point, point)
  | Close;

type pathParams = {
  commands: list(pathCommand),
  style,
};

type svgParams = {viewBox: option(rect)};

type node =
  | Circle(list(string), circleParams)
  | Path(list(string), pathParams)
  | Svg(list(string), svgParams, list(node));

module Decode = {
  open Json.Decode;

  exception Error(string);

  let point = (json: Js.Json.t): point => {
    let x = json |> field("x", float);
    let y = json |> field("y", float);
    {x, y};
  };

  let size = (json: Js.Json.t): size => {
    let width = json |> field("width", float);
    let height = json |> field("height", float);
    {width, height};
  };

  let rect = (json: Js.Json.t): rect => {
    let origin = json |> point;
    let size = json |> size;
    {size, origin};
  };

  let strokeLineCap = (json: Js.Json.t): strokeLineCap => {
    let strokeLineCap = json |> string;
    switch (strokeLineCap) {
    | "butt" => Butt
    | "round" => Round
    | "square" => Square
    | _ =>
      raise(Error("Failed to decode svg strokeLineCap: " ++ strokeLineCap))
    };
  };

  let style = (json: Js.Json.t): style => {
    let fill = json |> optional(field("fill", string));
    let stroke = json |> optional(field("stroke", string));
    let strokeWidth = json |> field("strokeWidth", float);
    let strokeLineCap = json |> field("strokeLineCap", strokeLineCap);
    {fill, stroke, strokeWidth, strokeLineCap};
  };

  let pathCommand = (json: Js.Json.t): pathCommand => {
    let type_ = json |> field("type", string);
    switch (type_) {
    | "line" => Line(json |> field("to", point))
    | "move" => Move(json |> field("to", point))
    | "quadCurve" =>
      QuadCurve(
        json |> field("to", point),
        json |> field("controlPoint", point),
      )
    | "cubicCurve" =>
      CubicCurve(
        json |> field("to", point),
        json |> field("controlPoint1", point),
        json |> field("controlPoint2", point),
      )
    | "close" => Close
    | _ =>
      raise(Error("Failed to decode svg path command of type: " ++ type_))
    };
  };

  let circleParams = (json: Js.Json.t): circleParams => {
    let radius = json |> field("radius", float);
    let center = json |> field("center", point);
    let style = json |> field("style", style);
    {radius, center, style};
  };

  let pathParams = (json: Js.Json.t): pathParams => {
    let commands = json |> field("commands", list(pathCommand));
    let style = json |> field("style", style);
    {commands, style};
  };

  let svgParams = (json: Js.Json.t): svgParams => {
    let viewBox = json |> optional(field("viewBox", rect));
    {viewBox: viewBox};
  };

  let rec node = (json: Js.Json.t): node => {
    let type_ = json |> field("type", string);
    let elementPath = json |> field("elementPath", list(string));
    /* Js.log2("JSON", json); */
    switch (type_) {
    | "svg" =>
      Svg(
        elementPath,
        json |> field("params", svgParams),
        json |> field("children", list(node)),
      )
    | "path" => Path(elementPath, json |> field("params", pathParams))
    | "circle" => Circle(elementPath, json |> field("params", circleParams))
    | _ => raise(Error("Failed to decode svg node of type: " ++ type_))
    };
  };
};

module ToString = {
  let strokeLineCap = (strokeLineCap: strokeLineCap): string =>
    switch (strokeLineCap) {
    | Butt => "butt"
    | Round => "round"
    | Square => "square"
    };

  let rec node = (node_: node): string =>
    switch (node_) {
    | Svg(_, _, children) =>
      "<svg>"
      ++ (children |> List.map(node) |> Format.joinWith("\n"))
      ++ "</svg>"
    | Circle(_) => "<circle>"
    | Path(_) => "<path />"
    };
};

[@bs.module]
external parseRaw: string => Js.Promise.t(Js.Json.t) = "../utils/convertSvg";

let parse = (data: string): Js.Promise.t(node) =>
  Js.Promise.(
    parseRaw(data)
    |> then_(json => {
         Js.log("DECODE");
         switch (Decode.node(json)) {
         | result =>
           Js.log("OK");
           resolve(result);
         | exception e =>
           Js.log2("ERROR", e);
           reject(e);
         };
       })
  );