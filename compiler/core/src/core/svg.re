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
    | "line" =>
      let data = json |> field("data", x => x);
      Line(data |> field("to", point));
    | "move" =>
      let data = json |> field("data", x => x);
      Move(data |> field("to", point));
    | "quadCurve" =>
      let data = json |> field("data", x => x);
      QuadCurve(
        data |> field("to", point),
        data |> field("controlPoint", point),
      );
    | "cubicCurve" =>
      let data = json |> field("data", x => x);
      CubicCurve(
        data |> field("to", point),
        data |> field("controlPoint1", point),
        data |> field("controlPoint2", point),
      );
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
    let data = json |> field("data", x => x);
    let elementPath = data |> field("elementPath", list(string));
    switch (type_) {
    | "svg" =>
      Svg(
        elementPath,
        data |> field("params", svgParams),
        data |> field("children", list(node)),
      )
    | "path" => Path(elementPath, data |> field("params", pathParams))
    | "circle" => Circle(elementPath, data |> field("params", circleParams))
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

let parse = data => parseRaw(data);

let decode = (data: string): Js.Promise.t(node) =>
  Js.Promise.(
    parseRaw(data)
    |> then_(json =>
         switch (Decode.node(json)) {
         | result => resolve(result)
         | exception e =>
           Js.log2("SVG decoding error", e);
           reject(e);
         }
       )
  );

let elementName = (elementPath: list(string)): string =>
  Format.joinWith("_", elementPath);

let find = (rootNode: node, name: string): option(node) => {
  let matchesPath = (node, elementPath) =>
    if (elementName(elementPath) == name) {
      Some(node);
    } else {
      None;
    };

  let rec inner = node =>
    switch (node) {
    | Svg(elementPath, _, children) =>
      switch (matchesPath(node, elementPath)) {
      | Some(match) => Some(match)
      | None =>
        switch (children |> List.map(inner) |> Sequence.compact) {
        | [] => None
        | [child, ..._] => Some(child)
        }
      }
    | Path(elementPath, _)
    | Circle(elementPath, _) => matchesPath(node, elementPath)
    };

  inner(rootNode);
};