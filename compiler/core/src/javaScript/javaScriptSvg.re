let stringPoint = (point: Svg.point): string =>
  [point.x, point.y]
  |> List.map(Format.floatToString)
  |> Format.joinWith(",");

let stringPathCommand = (command: Svg.pathCommand): string =>
  switch (command) {
  | Move(point) => "M" ++ stringPoint(point)
  | Line(point) => "L" ++ stringPoint(point)
  | QuadCurve(point, controlPoint) =>
    "Q" ++ stringPoint(controlPoint) ++ " " ++ stringPoint(point)
  | CubicCurve(point, controlPoint1, controlPoint2) =>
    "C"
    ++ stringPoint(controlPoint1)
    ++ " "
    ++ stringPoint(controlPoint2)
    ++ " "
    ++ stringPoint(point)
  | Close => "Z"
  };

let styleAttributes =
    (
      vectorAssignments: list(Layer.vectorAssignment),
      variableName: string,
      style: Svg.style,
    )
    : list(JavaScriptAst.node) => {
  let hasDynamicFill =
    Layer.hasDynamicVectorParam(vectorAssignments, variableName, Fill);

  let hasDynamicStroke =
    Layer.hasDynamicVectorParam(vectorAssignments, variableName, Stroke);

  let strokeWidth =
    JavaScriptAst.JSXAttribute({
      name: "stroke-width",
      value: StringLiteral(style.strokeWidth |> Format.floatToString),
    });

  let strokeLineCap =
    JavaScriptAst.JSXAttribute({
      name: "stroke-linecap",
      value: StringLiteral(style.strokeLineCap |> Svg.ToString.strokeLineCap),
    });

  JavaScriptAst.(
    [
      switch (hasDynamicFill, style.fill) {
      | (true, Some(fill)) => [
          JSXAttribute({
            name: "fill",
            value:
              BinaryExpression({
                left: Identifier(["props", variableName ++ "Fill"]),
                operator: Or,
                right: StringLiteral(fill),
              }),
          }),
        ]
      | (true, None) => [
          JSXAttribute({
            name: "fill",
            value:
              BinaryExpression({
                left: Identifier(["props", variableName ++ "Fill"]),
                operator: Or,
                right: StringLiteral("none"),
              }),
          }),
        ]
      | (false, Some(fill)) => [
          JSXAttribute({name: "fill", value: StringLiteral(fill)}),
        ]
      | (false, None) => [
          JSXAttribute({name: "fill", value: StringLiteral("none")}),
        ]
      },
      switch (hasDynamicStroke, style.stroke) {
      | (true, Some(stroke)) => [
          JSXAttribute({
            name: "stroke",
            value:
              BinaryExpression({
                left: Identifier(["props", variableName ++ "Stroke"]),
                operator: Or,
                right: StringLiteral(stroke),
              }),
          }),
          strokeWidth,
          strokeLineCap,
        ]
      | (true, None) => [
          JSXAttribute({
            name: "stroke",
            value:
              BinaryExpression({
                left: Identifier(["props", variableName ++ "Stroke"]),
                operator: Or,
                right: StringLiteral("none"),
              }),
          }),
          strokeWidth,
          strokeLineCap,
        ]
      | (false, Some(stroke)) => [
          JSXAttribute({name: "stroke", value: StringLiteral(stroke)}),
          strokeWidth,
          strokeLineCap,
        ]
      | (false, None) => []
      },
    ]
    |> List.concat
  );
};

let rec convertNode =
        (
          jsOptions: JavaScriptOptions.options,
          vectorAssignments: list(Layer.vectorAssignment),
          node: Svg.node,
        )
        : JavaScriptAst.node =>
  JavaScriptAst.(
    switch (node) {
    | Svg(_, params, children) =>
      JSXElement({
        tag: "svg",
        attributes:
          [
            [
              JSXAttribute({
                name: "style",
                value: Identifier(["props", "style"]),
              }),
            ],
            switch (params.viewBox) {
            | Some(viewBox) => [
                JSXAttribute({
                  name: "viewBox",
                  value:
                    StringLiteral(
                      [
                        viewBox.origin.x,
                        viewBox.origin.y,
                        viewBox.size.width,
                        viewBox.size.height,
                      ]
                      |> List.map(Format.floatToString)
                      |> Format.joinWith(" "),
                    ),
                }),
              ]
            | None => []
            },
          ]
          |> List.concat,
        content:
          children |> List.map(convertNode(jsOptions, vectorAssignments)),
      })
    | Path(elementPath, params) =>
      let variableName = Svg.elementName(elementPath);

      JSXElement({
        tag: "path",
        attributes:
          [
            [
              JSXAttribute({
                name: "d",
                value:
                  StringLiteral(
                    params.commands
                    |> List.map(stringPathCommand)
                    |> Format.joinWith(""),
                  ),
              }),
            ],
            styleAttributes(vectorAssignments, variableName, params.style),
          ]
          |> List.concat,
        content: [],
      });
    | Circle(_) => Empty
    }
  );

let generateVectorGraphic =
    (
      config: Config.t,
      jsOptions: JavaScriptOptions.options,
      vectorAssignments: list(Layer.vectorAssignment),
      assetUrl: string,
    ) => {
  let svg = Config.Find.svg(config, assetUrl);

  JavaScriptAst.(
    VariableDeclaration(
      AssignmentExpression({
        left: Identifier([Format.vectorClassName(assetUrl)]),
        right:
          ArrowFunctionExpression({
            id: None,
            params: ["props"],
            body: [Return(convertNode(jsOptions, vectorAssignments, svg))],
          }),
      }),
    )
  );
};