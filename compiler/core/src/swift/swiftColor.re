open SwiftAst;

let render =
    (options: Options.options, swiftOptions: SwiftOptions.options, colors) => {
  let doc = () => {
    let colorConstantDoc = (color: Color.t) =>
      LineEndComment({
        "comment":
          (color.value |> String.uppercase)
          ++ (
            switch color.comment {
            | Some(comment) => " - " ++ comment
            | _ => ""
            }
          ),
        "line":
          ConstantDeclaration({
            "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier(color.id),
                "annotation": None
              }),
            "init": Some(LiteralExpression(Color(color.value)))
          })
      });
    TopLevelDeclaration({
      "statements": [
        SwiftDocument.importFramework(swiftOptions.framework),
        Empty,
        EnumDeclaration({
          "name": "Colors",
          "inherits": [],
          "modifier": Some(PublicModifier),
          "body": colors |> List.map(colorConstantDoc)
        })
      ]
    });
  };
  let airbnbDoc = () => {
    let colorConstantDoc = (color: Color.t) =>
      ConstantDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier(color.id),
            "annotation": None
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name": SwiftIdentifier("color"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("hex")),
                  "value": LiteralExpression(String(color.value))
                }),
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("preview")),
                  "value": LiteralExpression(Color(color.value))
                })
              ]
            })
          )
      });
    let colorFuncDoc = () =>
      FunctionDeclaration({
        "name": "color",
        "modifiers": [],
        "parameters": [
          Parameter({
            "annotation": TypeName("String"),
            "externalName": None,
            "localName": "hex",
            "defaultValue": None
          }),
          Parameter({
            "annotation":
              TypeName(SwiftDocument.colorTypeName(swiftOptions.framework)),
            "externalName": None,
            "localName": "preview",
            "defaultValue": None
          })
        ],
        "body": [
          ReturnStatement(
            Some(
              FunctionCallExpression({
                "name":
                  SwiftIdentifier(
                    SwiftDocument.colorTypeName(swiftOptions.framework)
                  ),
                "arguments": [
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("hex")),
                    "value": SwiftIdentifier("hex")
                  })
                ]
              })
            )
          )
        ],
        "result":
          Some(TypeName(SwiftDocument.colorTypeName(swiftOptions.framework))),
        "throws": false
      });
    TopLevelDeclaration({
      "statements": [
        SwiftDocument.importFramework(swiftOptions.framework),
        Empty,
        DocComment("DLS-defined color values"),
        EnumDeclaration({
          "name": "Colors",
          "inherits": [],
          "modifier": Some(PublicModifier),
          "body": colors |> List.map(colorConstantDoc)
        }),
        Empty,
        DocComment(
          "Returns a color represented by `hex` string. We send #colorLiteral in `preview` to make it easy for developers to see which color the hex string is referring to. Please keep these in sync."
        ),
        colorFuncDoc()
      ]
    });
  };
  SwiftRender.toString(options.preset == Airbnb ? airbnbDoc() : doc());
};