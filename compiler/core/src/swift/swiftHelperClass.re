/* private class ImageWithBackgroundColor: LNAImageView {
     var fillColor: NSColor = NSColor.clear

     override func draw(_ dirtyRect: NSRect) {
         fillColor.set()
         bounds.fill()
         super.draw(dirtyRect)
     }
   } */
let generateImageWithBackgroundColor =
    (options: Options.options, swiftOptions: SwiftOptions.options) =>
  SwiftAst.[
    ClassDeclaration({
      "name": "ImageWithBackgroundColor",
      "inherits": [TypeName("LNAImageView")],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body": [
        VariableDeclaration({
          "modifiers": [],
          "pattern":
            IdentifierPattern({
              "identifier": SwiftIdentifier("fillColor"),
              "annotation": None,
            }),
          "init":
            Some(
              MemberExpression([
                SwiftIdentifier(
                  SwiftDocument.colorTypeName(swiftOptions.framework),
                ),
                SwiftIdentifier("clear"),
              ]),
            ),
          "block": None,
        }),
        Empty,
        FunctionDeclaration({
          "name": "draw",
          "attributes": [],
          "modifiers": [OverrideModifier],
          "parameters": [
            Parameter({
              "annotation": TypeName("NSRect"),
              "externalName": Some("_"),
              "localName": "dirtyRect",
              "defaultValue": None,
            }),
          ],
          "body": [
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("fillColor"),
                  SwiftIdentifier("set"),
                ]),
              "arguments": [],
            }),
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("bounds"),
                  SwiftIdentifier("fill"),
                ]),
              "arguments": [],
            }),
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier("super"),
                  SwiftIdentifier("draw"),
                ]),
              "arguments": [
                FunctionCallArgument({
                  "name": None,
                  "value": SwiftIdentifier("dirtyRect"),
                }),
              ],
            }),
          ],
          "result": None,
          "throws": false,
        }),
      ],
    }),
    Empty,
  ];

/* private class BackgroundImageView: UIImageView {
       override var intrinsicContentSize: CGSize {
           return .zero
       }
   } */
let generateBackgroundImage =
    (options: Options.options, swiftOptions: SwiftOptions.options) =>
  SwiftAst.[
    ClassDeclaration({
      "name": "BackgroundImageView",
      "inherits": [TypeName("UIImageView")],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body": [
        VariableDeclaration({
          "modifiers": [OverrideModifier],
          "pattern":
            IdentifierPattern({
              "identifier": SwiftIdentifier("intrinsicContentSize"),
              "annotation": Some(TypeName("CGSize")),
            }),
          "init": None,
          "block":
            Some(
              GetterBlock([
                ReturnStatement(
                  Some(
                    SwiftAst.Builders.functionCall(
                      ["CGSize"],
                      [
                        (Some("width"), ["UIViewNoIntrinsicMetric"]),
                        (Some("height"), ["UIViewNoIntrinsicMetric"]),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
        }),
      ],
    }),
  ];

/* private class EventIgnoringView: UIView {
     override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
       for view in subviews {
         if view.point(inside: convert(point, to: view), with: event) {
           return true
         }
       }
       return false
     }
   } */
let eventIgnoringView =
    (options: Options.options, swiftOptions: SwiftOptions.options) =>
  SwiftAst.[
    ClassDeclaration({
      "name": "EventIgnoringView",
      "inherits": [TypeName("UIView")],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body": [
        FunctionDeclaration({
          "name": "point",
          "attributes": [],
          "modifiers": [OverrideModifier],
          "parameters": [
            Parameter({
              "annotation": TypeName("CGPoint"),
              "externalName": Some("inside"),
              "localName": "point",
              "defaultValue": None,
            }),
            Parameter({
              "annotation": TypeName("UIEvent?"),
              "externalName": Some("with"),
              "localName": "event",
              "defaultValue": None,
            }),
          ],
          "body": [
            ForInStatement({
              "item":
                IdentifierPattern({
                  "identifier": SwiftIdentifier("view"),
                  "annotation": None,
                }),
              "collection": SwiftIdentifier("subviews"),
              "block": [
                IfStatement({
                  "condition":
                    BinaryExpression({
                      "left":
                        Builders.memberExpression([
                          "view",
                          "isUserInteractionEnabled",
                        ]),
                      "operator": "&&",
                      "right":
                        FunctionCallExpression({
                          "name":
                            MemberExpression([
                              SwiftIdentifier("view"),
                              SwiftIdentifier("point"),
                            ]),
                          "arguments": [
                            FunctionCallArgument({
                              "name": Some(SwiftIdentifier("inside")),
                              "value":
                                Builders.functionCall(
                                  ["convert"],
                                  [
                                    (None, ["point"]),
                                    (Some("to"), ["view"]),
                                  ],
                                ),
                            }),
                            FunctionCallArgument({
                              "name": Some(SwiftIdentifier("with")),
                              "value": SwiftIdentifier("event"),
                            }),
                          ],
                        }),
                    }),
                  "block": [
                    ReturnStatement(
                      Some(LiteralExpression(Boolean(true))),
                    ),
                  ],
                }),
              ],
            }),
            ReturnStatement(Some(LiteralExpression(Boolean(false)))),
          ],
          "result": Some(TypeName("Bool")),
          "throws": false,
        }),
      ],
    }),
  ];

let generateVectorGraphic =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      vectorAssignments: list(Layer.vectorAssignment),
      assetUrl: string,
    ) => {
  let svg = Config.Find.svg(config, assetUrl);

  SwiftAst.[
    ClassDeclaration({
      "name": Format.vectorClassName(assetUrl, None),
      "inherits": [
        TypeName(swiftOptions.framework == UIKit ? "UIView" : "NSBox"),
      ],
      "modifier": Some(PrivateModifier),
      "isFinal": false,
      "body":
        [
          vectorAssignments
          |> List.map((vectorAssignment: Layer.vectorAssignment) => {
               let initialValue =
                 switch (
                   Svg.find(svg, vectorAssignment.elementName),
                   vectorAssignment.paramKey,
                 ) {
                 | (Some(Path(_, params)), Fill) =>
                   switch (params.style.fill) {
                   | Some(fill) => Some(LiteralExpression(Color(fill)))
                   | None => Some(LiteralExpression(Color("transparent")))
                   }
                 | (Some(Path(_, params)), Stroke) =>
                   switch (params.style.stroke) {
                   | Some(stroke) => Some(LiteralExpression(Color(stroke)))
                   | None => Some(LiteralExpression(Color("transparent")))
                   }
                 | (Some(_), _) => None
                 | (None, _) => None
                 };

               VariableDeclaration({
                 "modifiers": [AccessLevelModifier(PublicModifier)],
                 "pattern":
                   IdentifierPattern({
                     "identifier":
                       SwiftIdentifier(
                         SwiftFormat.vectorVariableName(vectorAssignment),
                       ),
                     "annotation": None,
                   }),
                 "init": initialValue,
                 "block": None,
               });
             }),
          swiftOptions.framework == SwiftOptions.AppKit ?
            [
              VariableDeclaration({
                "modifiers": [OverrideModifier],
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("isFlipped"),
                    "annotation": Some(TypeName("Bool")),
                  }),
                "init": None,
                "block":
                  Some(
                    GetterBlock([
                      ReturnStatement(
                        Some(LiteralExpression(Boolean(true))),
                      ),
                    ]),
                  ),
              }),
            ] :
            [],
          [
            VariableDeclaration({
              "modifiers": [],
              "pattern":
                IdentifierPattern({
                  "identifier": SwiftIdentifier("resizingMode"),
                  "annotation": None,
                }),
              "init":
                Some(
                  SwiftAst.Builders.memberExpression([
                    "CGSize",
                    "ResizingMode",
                    "scaleAspectFill",
                  ]),
                ),
              "block":
                Some(
                  WillSetDidSetBlock({
                    "willSet": None,
                    "didSet":
                      Some([
                        IfStatement({
                          "condition":
                            BinaryExpression({
                              "left": SwiftIdentifier("resizingMode"),
                              "operator": "!=",
                              "right": SwiftIdentifier("oldValue"),
                            }),
                          "block": [
                            switch (swiftOptions.framework) {
                            | UIKit =>
                              SwiftAst.Builders.functionCall(
                                ["setNeedsDisplay"],
                                [],
                              )
                            | AppKit =>
                              BinaryExpression({
                                "left":
                                  SwiftAst.Builders.memberExpression([
                                    "needsDisplay",
                                  ]),
                                "operator": "=",
                                "right": LiteralExpression(Boolean(true)),
                              })
                            },
                          ],
                        }),
                      ]),
                  }),
                ),
            }),
          ],
          [
            FunctionDeclaration({
              "name": "draw",
              "attributes": [],
              "modifiers": [OverrideModifier],
              "parameters": [
                Parameter({
                  "annotation": TypeName("CGRect"),
                  "externalName": Some("_"),
                  "localName": "dirtyRect",
                  "defaultValue": None,
                }),
              ],
              "body":
                [
                  swiftOptions.framework == SwiftOptions.AppKit ?
                    [
                      SwiftAst.Builders.functionCall(
                        ["super", "draw"],
                        [(None, ["dirtyRect"])],
                      ),
                      Empty,
                    ] :
                    [],
                  SwiftSvg.convertNode(swiftOptions, vectorAssignments, svg),
                ]
                |> List.concat,
              "result": None,
              "throws": false,
            }),
          ],
        ]
        |> SwiftDocument.joinGroups(Empty),
    }),
    Empty,
  ];
};