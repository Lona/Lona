let lineToFunctionName = (config: Config.t) =>
  switch (config.options.swift.framework) {
  | SwiftOptions.UIKit => "addLine"
  | SwiftOptions.AppKit => "line"
  };

let curveToFunctionName = (config: Config.t) =>
  switch (config.options.swift.framework) {
  | SwiftOptions.UIKit => "addCurve"
  | SwiftOptions.AppKit => "curve"
  };

let lineCapValue = (config: Config.t, value) => {
  let value = Svg.ToString.strokeLineCap(value);
  switch (config.options.swift.framework) {
  | SwiftOptions.UIKit => value
  | SwiftOptions.AppKit => value ++ "LineCapStyle"
  };
};

let formatElementPath = (items: list(string)): string =>
  switch (items) {
  | [] => "root"
  | _ => Svg.elementName(items)
  };

let scaleValue = (float: float): SwiftAst.node =>
  SwiftAst.(
    BinaryExpression({
      "left": LiteralExpression(FloatingPoint(float)),
      "operator": "*",
      "right": SwiftIdentifier("scale"),
    })
  );

let setStyle =
    (
      vectorAssignments: list(Layer.vectorAssignment),
      variableName: string,
      style: Svg.style,
    )
    : list(SwiftAst.node) => {
  let hasDynamicFill =
    Layer.hasDynamicVectorParam(vectorAssignments, variableName, Fill);
  let hasDynamicStroke =
    Layer.hasDynamicVectorParam(vectorAssignments, variableName, Stroke);

  SwiftAst.(
    [
      switch (hasDynamicFill, style.fill) {
      | (true, _) => [
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(variableName ++ "Fill"),
                SwiftIdentifier("setFill"),
              ]),
            "arguments": [],
          }),
        ]
      | (false, Some(fill)) => [
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                LiteralExpression(Color(fill)),
                SwiftIdentifier("setFill"),
              ]),
            "arguments": [],
          }),
        ]
      | (false, None) => []
      },
      switch (hasDynamicStroke, style.stroke) {
      | (true, _) => [
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(variableName ++ "Stroke"),
                SwiftIdentifier("setStroke"),
              ]),
            "arguments": [],
          }),
        ]
      | (false, Some(stroke)) => [
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                LiteralExpression(Color(stroke)),
                SwiftIdentifier("setStroke"),
              ]),
            "arguments": [],
          }),
        ]
      | (false, None) => []
      },
    ]
    |> List.concat
  );
};

let paintStyle =
    (
      config: Config.t,
      _vectorAssignments: list(Layer.vectorAssignment),
      variableName: string,
      style: Svg.style,
    )
    : list(SwiftAst.node) =>
  SwiftAst.(
    [
      switch (style.fill) {
      | None => []
      | Some(_) => [
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(variableName),
                SwiftIdentifier("fill"),
              ]),
            "arguments": [],
          }),
        ]
      },
      switch (style.stroke) {
      | None => []
      | Some(_) => [
          SwiftAst.BinaryExpression({
            "left":
              MemberExpression([
                SwiftIdentifier(variableName),
                SwiftIdentifier("lineWidth"),
              ]),
            "operator": "=",
            "right": scaleValue(style.strokeWidth),
          }),
          SwiftAst.BinaryExpression({
            "left":
              MemberExpression([
                SwiftIdentifier(variableName),
                SwiftIdentifier("lineCapStyle"),
              ]),
            "operator": "=",
            "right":
              SwiftIdentifier(
                "." ++ (style.strokeLineCap |> lineCapValue(config)),
              ),
          }),
          SwiftAst.FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(variableName),
                SwiftIdentifier("stroke"),
              ]),
            "arguments": [],
          }),
        ]
      },
    ]
    |> List.concat
  );

let convertPoint = (point: Svg.point): SwiftAst.node =>
  SwiftAst.(
    FunctionCallExpression({
      "name": SwiftIdentifier("CGPoint"),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("x")),
          "value": LiteralExpression(FloatingPoint(point.x)),
        }),
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("y")),
          "value": LiteralExpression(FloatingPoint(point.y)),
        }),
      ],
    })
  );

let convertAndTransformPoint = (point: Svg.point): SwiftAst.node =>
  SwiftAst.(
    FunctionCallExpression({
      "name": SwiftIdentifier("transform"),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("point")),
          "value":
            FunctionCallExpression({
              "name": SwiftIdentifier("CGPoint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("x")),
                  "value": LiteralExpression(FloatingPoint(point.x)),
                }),
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("y")),
                  "value": LiteralExpression(FloatingPoint(point.y)),
                }),
              ],
            }),
        }),
      ],
    })
  );

let convertSize = (size: Svg.size): SwiftAst.node =>
  SwiftAst.(
    FunctionCallExpression({
      "name": SwiftIdentifier("CGSize"),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("width")),
          "value": LiteralExpression(FloatingPoint(size.width)),
        }),
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("height")),
          "value": LiteralExpression(FloatingPoint(size.height)),
        }),
      ],
    })
  );

let convertRect = (rect: Svg.rect): SwiftAst.node =>
  SwiftAst.(
    FunctionCallExpression({
      "name": SwiftIdentifier("CGRect"),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("origin")),
          "value": convertPoint(rect.origin),
        }),
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("size")),
          "value": convertSize(rect.size),
        }),
      ],
    })
  );

let convertPathCommand =
    (config: Config.t, variableName: string, command: Svg.pathCommand)
    : SwiftAst.node =>
  SwiftAst.(
    switch (command) {
    | Move(point) =>
      FunctionCallExpression({
        "name": Builders.memberExpression([variableName, "move"]),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("to")),
            "value": convertAndTransformPoint(point),
          }),
        ],
      })
    | Line(point) =>
      FunctionCallExpression({
        "name":
          Builders.memberExpression([
            variableName,
            lineToFunctionName(config),
          ]),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("to")),
            "value": convertAndTransformPoint(point),
          }),
        ],
      })
    | QuadCurve(point, controlPoint) =>
      FunctionCallExpression({
        "name": Builders.memberExpression([variableName, "addQuadCurve"]),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("to")),
            "value": convertAndTransformPoint(point),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("controlPoint")),
            "value": convertAndTransformPoint(controlPoint),
          }),
        ],
      })
    | CubicCurve(point, controlPoint1, controlPoint2) =>
      FunctionCallExpression({
        "name":
          Builders.memberExpression([
            variableName,
            curveToFunctionName(config),
          ]),
        "arguments": [
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("to")),
            "value": convertAndTransformPoint(point),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("controlPoint1")),
            "value": convertAndTransformPoint(controlPoint1),
          }),
          FunctionCallArgument({
            "name": Some(SwiftIdentifier("controlPoint2")),
            "value": convertAndTransformPoint(controlPoint2),
          }),
        ],
      })
    | Close =>
      FunctionCallExpression({
        "name": Builders.memberExpression([variableName, "close"]),
        "arguments": [],
      })
    }
  );

let rec convertNode =
        (
          config: Config.t,
          vectorAssignments: list(Layer.vectorAssignment),
          node: Svg.node,
        )
        : list(SwiftAst.node) =>
  SwiftAst.(
    switch (node) {
    | Circle(elementPath, params) =>
      let variableName = formatElementPath(elementPath);
      [
        [
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("circle"),
                "annotation": None,
              }),
            "init":
              Some(
                FunctionCallExpression({
                  "name":
                    SwiftIdentifier(
                      config |> SwiftDocument.bezierPathTypeName,
                    ),
                  "arguments": [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("arcCenter")),
                      "value": convertAndTransformPoint(params.center),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("radius")),
                      "value": scaleValue(params.radius),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("startAngle")),
                      "value": LiteralExpression(FloatingPoint(0.)),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("endAngle")),
                      "value": LiteralExpression(FloatingPoint(360.)),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("clockwise")),
                      "value": LiteralExpression(Boolean(true)),
                    }),
                  ],
                }),
              ),
          }),
        ],
        params.style |> setStyle(vectorAssignments, variableName),
        params.style |> paintStyle(config, vectorAssignments, variableName),
      ]
      |> List.concat;
    | Path(elementPath, params) =>
      let variableName = formatElementPath(elementPath);
      [
        [
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier(variableName),
                "annotation": None,
              }),
            "init":
              Some(
                FunctionCallExpression({
                  "name":
                    SwiftIdentifier(
                      config |> SwiftDocument.bezierPathTypeName,
                    ),
                  "arguments": [],
                }),
              ),
          }),
        ],
        params.commands |> List.map(convertPathCommand(config, variableName)),
        params.style |> setStyle(vectorAssignments, variableName),
        params.style |> paintStyle(config, vectorAssignments, variableName),
      ]
      |> List.concat;
    | Svg(_, params, children) =>
      [
        [
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("viewBox"),
                "annotation": None,
              }),
            "init":
              Some(
                switch (params.viewBox) {
                | None => SwiftIdentifier("bounds")
                | Some(viewBox) => convertRect(viewBox)
                },
              ),
          }),
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("croppedRect"),
                "annotation": None,
              }),
            "init":
              Some(
                FunctionCallExpression({
                  "name":
                    MemberExpression([
                      SwiftIdentifier("viewBox"),
                      SwiftIdentifier("size"),
                      SwiftIdentifier("resized"),
                    ]),
                  "arguments": [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("within")),
                      "value":
                        MemberExpression([
                          SwiftIdentifier("bounds"),
                          SwiftIdentifier("size"),
                        ]),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("usingResizingMode")),
                      "value":
                        MemberExpression([SwiftIdentifier("resizingMode")]),
                    }),
                  ],
                }),
              ),
          }),
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("scale"),
                "annotation": None,
              }),
            "init":
              Some(
                BinaryExpression({
                  "left":
                    MemberExpression([
                      SwiftIdentifier("croppedRect"),
                      SwiftIdentifier("width"),
                    ]),
                  "operator": "/",
                  "right":
                    MemberExpression([
                      SwiftIdentifier("viewBox"),
                      SwiftIdentifier("width"),
                    ]),
                }),
              ),
          }),
          FunctionDeclaration({
            "name": "transform",
            "attributes": [],
            "modifiers": [],
            "parameters": [
              Parameter({
                "externalName": None,
                "localName": "point",
                "defaultValue": None,
                "annotation": TypeName("CGPoint"),
              }),
            ],
            "throws": false,
            "result": Some(TypeName("CGPoint")),
            "body": [
              ReturnStatement(
                Some(
                  FunctionCallExpression({
                    "name": SwiftIdentifier("CGPoint"),
                    "arguments": [
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("x")),
                        "value":
                          BinaryExpression({
                            "left":
                              MemberExpression([
                                SwiftIdentifier("point"),
                                SwiftIdentifier("x"),
                              ]),
                            "operator": "*",
                            "right":
                              BinaryExpression({
                                "left": SwiftIdentifier("scale"),
                                "operator": "+",
                                "right":
                                  MemberExpression([
                                    SwiftIdentifier("croppedRect"),
                                    SwiftIdentifier("minX"),
                                  ]),
                              }),
                          }),
                      }),
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("y")),
                        "value":
                          BinaryExpression({
                            "left":
                              MemberExpression([
                                SwiftIdentifier("point"),
                                SwiftIdentifier("y"),
                              ]),
                            "operator": "*",
                            "right":
                              BinaryExpression({
                                "left": SwiftIdentifier("scale"),
                                "operator": "+",
                                "right":
                                  MemberExpression([
                                    SwiftIdentifier("croppedRect"),
                                    SwiftIdentifier("minY"),
                                  ]),
                              }),
                          }),
                      }),
                    ],
                  }),
                ),
              ),
            ],
          }),
        ],
        children
        |> List.map(convertNode(config, vectorAssignments))
        |> List.concat,
      ]
      |> List.concat
    }
  );