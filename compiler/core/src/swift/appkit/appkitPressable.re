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