module JavaScript = {
  let generate = (name, json) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
    let assignments = Layer.parameterAssignments(rootLayer, logic);
    let rootLayerAST = rootLayer |> Layer.toJavaScriptAST(assignments);
    let styleSheetAST = rootLayer |> Layer.toJavaScriptStyleSheetAST;
    let logicAST = logic |> Logic.toJavaScriptAST |> Ast.JavaScript.optimize;
    Ast.JavaScript.(
      Program([
        Class(
          name,
          Some("React.Component"),
          [Method("render", [], [logicAST, Return(rootLayerAST)])]
        ),
        styleSheetAST
      ])
    )
    /* Renames variables */
    |> Ast.JavaScript.prepareForRender
  };
};

module Swift = {
  let generate = (name, json) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    /* Remove the root element */
    let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
    let parameters = json |> Decode.Component.parameters;
    open Ast.Swift;
    let formatLayerName = (layerName) =>
      Js.String.replace(" ", "", String.lowercase(layerName)) ++ "View";
    let typeAnnotationDoc =
      fun
      | Types.Reference(typeName) =>
        switch typeName {
        | "Boolean" => TypeName("Bool")
        | _ => TypeName(typeName)
        }
      | Named(name, _) => TypeName(name);
    let parameterVariableDoc = (parameter: Decode.parameter) =>
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": parameter.name,
            "annotation": Some(parameter.ltype |> typeAnnotationDoc)
          }),
        "init": None,
        "block":
          Some(
            WillSetDidSetBlock({
              "willSet": None,
              "didSet":
                Some([
                  FunctionCallExpression({"name": SwiftIdentifier("update"), "arguments": []})
                ])
            })
          )
      });
    let viewTypeDoc =
      fun
      | Types.View => TypeName("UIView")
      | Text => TypeName("UILabel")
      | Image => TypeName("UIImageView")
      | _ => TypeName("TypeUnknown");
    let viewTypeInitDoc =
      fun
      | Types.View => SwiftIdentifier("UIView")
      | Text => SwiftIdentifier("UILabel")
      | Image => SwiftIdentifier("UIImageView")
      | _ => SwiftIdentifier("TypeUnknown");
    let viewVariableDoc = (layer: Types.layer) =>
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": layer.name |> formatLayerName,
            "annotation": Some(layer.typeName |> viewTypeDoc)
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name": layer.typeName |> viewTypeInitDoc,
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("frame")),
                  "value": SwiftIdentifier(".zero")
                })
              ]
            })
          ),
        "block": None
      });
    let initParameterDoc = (parameter: Decode.parameter) =>
      Parameter({
        "externalName": None,
        "localName": parameter.name,
        "annotation": parameter.ltype |> typeAnnotationDoc,
        "defaultValue": None
      });
    let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
      BinaryExpression({
        "left": MemberExpression([SwiftIdentifier("self"), SwiftIdentifier(parameter.name)]),
        "operator": "=",
        "right": SwiftIdentifier(parameter.name)
      });
    let initializerDoc = () =>
      InitializerDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier)],
        "parameters": parameters |> List.map(initParameterDoc),
        "failable": None,
        "body":
          List.concat([
            parameters |> List.map(initParameterAssignmentDoc),
            [
              Empty,
              MemberExpression([
                SwiftIdentifier("super"),
                FunctionCallExpression({
                  "name": SwiftIdentifier("init"),
                  "arguments": [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("frame")),
                      "value": SwiftIdentifier(".zero")
                    })
                  ]
                })
              ]),
              Empty,
              FunctionCallExpression({"name": SwiftIdentifier("setUpViews"), "arguments": []}),
              FunctionCallExpression({
                "name": SwiftIdentifier("setUpConstraints"),
                "arguments": []
              }),
              FunctionCallExpression({"name": SwiftIdentifier("setUpDefaults"), "arguments": []}),
              Empty,
              FunctionCallExpression({"name": SwiftIdentifier("update"), "arguments": []})
            ]
          ])
      });
    let parentNameOrSelf = (parent: Types.layer) =>
      parent === rootLayer ? "self" : parent.name |> formatLayerName;
    let memberOrSelfExpression = (firstIdentifier, statements) =>
      switch firstIdentifier {
      | "self" => MemberExpression(statements)
      | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
      };
    let setUpViewsDoc = (root: Types.layer) => {
      let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
        switch parent {
        | None => []
        | Some(parent) => [
            FunctionCallExpression({
              "name":
                memberOrSelfExpression(parentNameOrSelf(parent), [SwiftIdentifier("addSubview")]),
              "arguments": [SwiftIdentifier(layer.name |> formatLayerName)]
            })
          ]
        };
      FunctionDeclaration({
        "name": "setUpViews",
        "modifiers": [],
        "parameters": [],
        "body": Layer.flatmapParent(addSubviews, root) |> List.concat
      })
    };
    let setUpConstraintsDoc = (root: Types.layer) => {
      let translatesAutoresizingMask = (layer: Types.layer) =>
        BinaryExpression({
          "left":
            memberOrSelfExpression(
              parentNameOrSelf(layer),
              [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")]
            ),
          "operator": "=",
          "right": LiteralExpression(Boolean(false))
        });
      /* titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true */
      let setUpContraint = (layer: Types.layer, anchor1, parent: Types.layer, anchor2, constant) =>
        BinaryExpression({
          "left":
            MemberExpression([
              SwiftIdentifier(layer.name |> formatLayerName),
              SwiftIdentifier(anchor1),
              FunctionCallExpression({
                "name": SwiftIdentifier("constraint"),
                "arguments": [
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("equalTo")),
                    "value":
                      memberOrSelfExpression(parentNameOrSelf(parent), [SwiftIdentifier(anchor2)])
                  }),
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("constant")),
                    "value": LiteralExpression(FloatingPoint(constant))
                  })
                ]
              }),
              SwiftIdentifier("isActive")
            ]),
          "operator": "=",
          "right": LiteralExpression(Boolean(true))
        });
      let constrainAxes = (parent: Types.layer) => {
        let direction = Layer.flexDirection(parent);
        let primaryBeforeAnchor = direction == "column" ? "topAnchor" : "leadingAnchor";
        let primaryAfterAnchor = direction == "column" ? "bottomAnchor" : "trailingAnchor";
        let secondaryBeforeAnchor = direction == "column" ? "leadingAnchor" : "topAnchor";
        let secondaryAfterAnchor = direction == "column" ? "trailingAnchor" : "bottomAnchor";
        let parentPadding = Layer.getPadding(parent);
        let addConstraints = (index, layer: Types.layer) => {
          let layerMargin = Layer.getMargin(layer);
          let primaryAxisConstraints =
            switch index {
            | 0 =>
              let primaryBeforeConstant =
                direction == "column" ?
                  parentPadding.top +. layerMargin.top : parentPadding.left +. layerMargin.left;
              [
                setUpContraint(
                  layer,
                  primaryBeforeAnchor,
                  parent,
                  primaryBeforeAnchor,
                  primaryBeforeConstant
                )
              ]
            | x when x == List.length(parent.children) - 1 =>
              let primaryAfterConstant =
                direction == "column" ?
                  parentPadding.bottom +. layerMargin.bottom :
                  parentPadding.right +. layerMargin.right;
              [
                setUpContraint(
                  layer,
                  primaryAfterAnchor,
                  parent,
                  primaryAfterAnchor,
                  -. primaryAfterConstant
                )
              ]
            | _ =>
              let previousLayer = List.nth(parent.children, index);
              let previousMargin = Layer.getMargin(previousLayer);
              let betweenConstant =
                direction == "column" ?
                  previousMargin.bottom +. layerMargin.top :
                  previousMargin.right +. layerMargin.left;
              [
                setUpContraint(
                  layer,
                  primaryBeforeAnchor,
                  previousLayer,
                  primaryAfterAnchor,
                  betweenConstant
                )
              ]
            };
          let secondaryBeforeConstant =
            direction == "column" ?
              parentPadding.left +. layerMargin.left : parentPadding.top +. layerMargin.top;
          let secondaryAfterConstant =
            direction == "column" ?
              parentPadding.right +. layerMargin.right : parentPadding.bottom +. layerMargin.bottom;
          let secondaryAxisConstraints = [
            setUpContraint(
              layer,
              secondaryBeforeAnchor,
              parent,
              secondaryBeforeAnchor,
              secondaryBeforeConstant
            ),
            setUpContraint(
              layer,
              secondaryAfterAnchor,
              parent,
              secondaryAfterAnchor,
              -. secondaryAfterConstant
            )
          ];
          primaryAxisConstraints @ secondaryAxisConstraints @ [Empty]
        };
        parent.children |> List.mapi(addConstraints) |> List.concat
      };
      FunctionDeclaration({
        "name": "setUpConstraints",
        "modifiers": [],
        "parameters": [],
        "body":
          List.concat([
            root |> Layer.flatmap(translatesAutoresizingMask),
            [Empty],
            root |> Layer.flatmap(constrainAxes) |> List.concat,
            []
          ])
      })
    };
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        ImportDeclaration("Foundation"),
        Empty,
        ClassDeclaration({
          "name": name,
          "inherits": [TypeName("UIView")],
          "modifier": None,
          "isFinal": false,
          "body":
            List.concat([
              [LineComment("Parameters")],
              parameters |> List.map(parameterVariableDoc),
              [LineComment("Views")],
              nonRootLayers |> List.map(viewVariableDoc),
              [Empty],
              [initializerDoc()],
              [Empty],
              [setUpViewsDoc(rootLayer)],
              [Empty],
              [setUpConstraintsDoc(rootLayer)],
              [Empty],
              [
                FunctionDeclaration({
                  "name": "setUpDefaults",
                  "modifiers": [],
                  "parameters": [],
                  "body": []
                }),
                Empty,
                FunctionDeclaration({
                  "name": "update",
                  "modifiers": [],
                  "parameters": [],
                  "body": []
                })
              ]
            ])
        })
      ]
    })
  };
};