open SwiftAst;

/* lazy var trackingArea = NSTrackingArea(
   rect: self.frame,
   options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
   owner: self) */
let trackingAreaVar =
  VariableDeclaration({
    "modifiers": [AccessLevelModifier(PrivateModifier), LazyModifier],
    "pattern":
      IdentifierPattern({
        "identifier": SwiftIdentifier("trackingArea"),
        "annotation": None
      }),
    "init":
      Some(
        FunctionCallExpression({
          "name": SwiftIdentifier("NSTrackingArea"),
          "arguments": [
            FunctionCallArgument({
              "name": Some(SwiftIdentifier("rect")),
              "value":
                MemberExpression([
                  SwiftIdentifier("self"),
                  SwiftIdentifier("frame")
                ])
            }),
            FunctionCallArgument({
              "name": Some(SwiftIdentifier("options")),
              "value":
                LiteralExpression(
                  Array([
                    SwiftIdentifier(".mouseEnteredAndExited"),
                    SwiftIdentifier(".activeAlways"),
                    SwiftIdentifier(".mouseMoved"),
                    SwiftIdentifier(".inVisibleRect")
                  ])
                )
            }),
            FunctionCallArgument({
              "name": Some(SwiftIdentifier("owner")),
              "value": SwiftIdentifier("self")
            })
          ]
        })
      ),
    "block": None
  });

/* addTrackingArea(trackingArea) */
let addTrackingArea =
  FunctionCallExpression({
    "name": SwiftIdentifier("addTrackingArea"),
    "arguments": [
      FunctionCallArgument({
        "name": None,
        "value": SwiftIdentifier("trackingArea")
      })
    ]
  });

/* deinit {
       removeTrackingArea(trackingArea)
   } */
let deinitTrackingArea =
  DeinitializerDeclaration([
    FunctionCallExpression({
      "name": SwiftIdentifier("removeTrackingArea"),
      "arguments": [
        FunctionCallArgument({
          "name": None,
          "value": SwiftIdentifier("trackingArea")
        })
      ]
    })
  ]);

let mouseTrackingFunctions = (rootLayer, pressableLayers: list(Types.layer)) => {
  let containsPoint = (layer: Types.layer) =>
    SwiftDocument.layerMemberExpression(
      rootLayer,
      layer,
      [
        SwiftIdentifier("bounds"),
        FunctionCallExpression({
          "name": SwiftIdentifier("contains"),
          "arguments": [
            FunctionCallExpression({
              "name":
                SwiftDocument.layerMemberExpression(
                  rootLayer,
                  layer,
                  [SwiftIdentifier("convert")]
                ),
              "arguments": [
                FunctionCallArgument({
                  "name": None,
                  "value":
                    MemberExpression([
                      SwiftIdentifier("event"),
                      SwiftIdentifier("locationInWindow")
                    ])
                }),
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("from")),
                  "value": LiteralExpression(Nil)
                })
              ]
            })
          ]
        })
      ]
    );
  let containsPointVariable = (variableName, layer: Types.layer) =>
    ConstantDeclaration({
      "modifiers": [],
      "init": Some(containsPoint(layer)),
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, variableName)
            ),
          "annotation": None
        })
    });
  let wasClicked = (layer: Types.layer) =>
    ConstantDeclaration({
      "modifiers": [],
      "pattern":
        IdentifierPattern({
          "identifier":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, "clicked")
            ),
          "annotation": None
        }),
      "init":
        Some(
          SwiftDocument.binaryExpressionList(
            "&&",
            [
              SwiftIdentifier(
                SwiftFormat.layerVariableName(rootLayer, layer, "pressed")
              ),
              containsPoint(layer)
            ]
          )
        )
    });
  let ifChanged = variableName => {
    let layerVariableName = layer =>
      SwiftFormat.layerVariableName(rootLayer, layer, variableName);
    let condition =
      SwiftDocument.binaryExpressionList(
        "||",
        List.map(layer =>
          BinaryExpression({
            "left": SwiftIdentifier(layerVariableName(layer)),
            "operator": "!=",
            "right":
              MemberExpression([
                SwiftIdentifier("self"),
                SwiftIdentifier(layerVariableName(layer))
              ])
          })
        ) @@
        pressableLayers
      );
    let assignments =
      List.map(layer =>
        BinaryExpression({
          "left":
            MemberExpression([
              SwiftIdentifier("self"),
              SwiftIdentifier(layerVariableName(layer))
            ]),
          "operator": "=",
          "right": SwiftIdentifier(layerVariableName(layer))
        })
      ) @@
      pressableLayers;
    IfStatement({
      "condition": condition,
      "block":
        SwiftDocument.joinGroups(
          Empty,
          [
            assignments,
            [
              FunctionCallExpression({
                "name": SwiftIdentifier("update"),
                "arguments": []
              })
            ]
          ]
        )
    });
  };
  let ifTrueSetFalse = variableName => {
    let condition =
      SwiftDocument.binaryExpressionList(
        "||",
        List.map(layer =>
          SwiftIdentifier(
            SwiftFormat.layerVariableName(rootLayer, layer, variableName)
          )
        ) @@
        pressableLayers
      );
    let assignments =
      List.map(layer =>
        BinaryExpression({
          "left":
            MemberExpression([
              SwiftIdentifier(
                SwiftFormat.layerVariableName(rootLayer, layer, variableName)
              )
            ]),
          "operator": "=",
          "right": LiteralExpression(Boolean(false))
        })
      ) @@
      pressableLayers;
    IfStatement({
      "condition": condition,
      "block":
        SwiftDocument.joinGroups(
          Empty,
          [
            assignments,
            [
              FunctionCallExpression({
                "name": SwiftIdentifier("update"),
                "arguments": []
              })
            ]
          ]
        )
    });
  };
  let invokePressHandler = (layer: Types.layer) =>
    IfStatement({
      "condition":
        SwiftIdentifier(
          SwiftFormat.layerVariableName(rootLayer, layer, "clicked")
        ),
      "block": [
        FunctionCallExpression({
          "name":
            SwiftIdentifier(
              SwiftFormat.layerVariableName(rootLayer, layer, "onPress?")
            ),
          "arguments": []
        })
      ]
    });
  let eventHandler = (name, body) =>
    FunctionDeclaration({
      "name": name,
      "modifiers": [AccessLevelModifier(PublicModifier), OverrideModifier],
      "parameters": [
        Parameter({
          "externalName": Some("with"),
          "localName": "event",
          "defaultValue": None,
          "annotation": TypeName("NSEvent")
        })
      ],
      "throws": false,
      "result": None,
      "body": body
    });
  let updateHoverState =
    FunctionDeclaration({
      "name": "updateHoverState",
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "parameters": [
        Parameter({
          "externalName": Some("with"),
          "localName": "event",
          "defaultValue": None,
          "annotation": TypeName("NSEvent")
        })
      ],
      "throws": false,
      "result": None,
      "body":
        (pressableLayers |> List.map(containsPointVariable("hovered")))
        @ [ifChanged("hovered")]
    });
  let invokeUpdateHoverState =
    FunctionCallExpression({
      "name": SwiftIdentifier("updateHoverState"),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("with")),
          "value": SwiftIdentifier("event")
        })
      ]
    });
  let mouseEntered = eventHandler("mouseEntered", [invokeUpdateHoverState]);
  let mouseMoved = eventHandler("mouseMoved", [invokeUpdateHoverState]);
  let mouseDragged = eventHandler("mouseDragged", [invokeUpdateHoverState]);
  let mouseExited = eventHandler("mouseExited", [invokeUpdateHoverState]);
  let mouseDown =
    eventHandler(
      "mouseDown",
      (pressableLayers |> List.map(containsPointVariable("pressed")))
      @ [ifChanged("pressed")]
    );
  let mouseUp =
    eventHandler(
      "mouseUp",
      (pressableLayers |> List.map(wasClicked))
      @ [Empty]
      @ [ifTrueSetFalse("pressed")]
      @ [Empty]
      @ (pressableLayers |> List.map(invokePressHandler))
    );
  [
    updateHoverState,
    Empty,
    mouseEntered,
    Empty,
    mouseMoved,
    Empty,
    mouseDragged,
    Empty,
    mouseExited,
    Empty,
    mouseDown,
    Empty,
    mouseUp
  ];
};