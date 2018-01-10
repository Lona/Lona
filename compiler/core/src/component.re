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
  type constraintDefinition = {
    variableName: string,
    initialValue: Ast.Swift.node
  };
  let generate = (name, json, colors) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    /* Remove the root element */
    let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
    let logic = json |> Decode.Component.logic;
    let assignments = Layer.parameterAssignments(rootLayer, logic);
    let parameters = json |> Decode.Component.parameters;
    open Ast.Swift;
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
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "pattern":
          IdentifierPattern({
            "identifier": layer.name |> Swift.Format.layerName,
            "annotation": None /*Some(layer.typeName |> viewTypeDoc)*/
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name": layer.typeName |> viewTypeInitDoc,
              "arguments":
                layer.typeName == Types.Text ?
                  [] :
                  [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("frame")),
                      "value": SwiftIdentifier(".zero")
                    })
                  ]
            })
          ),
        "block": None
      });
    let constraintVariableDoc = (variableName) =>
      VariableDeclaration({
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "pattern":
          IdentifierPattern({
            "identifier": variableName,
            "annotation": Some(OptionalType(TypeName("NSLayoutConstraint")))
          }),
        "init": None,
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
    let initializerCoderDoc = () =>
      /* required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
         } */
      InitializerDeclaration({
        "modifiers": [RequiredModifier],
        "parameters": [
          Parameter({
            "externalName": Some("coder"),
            "localName": "aDecoder",
            "annotation": TypeName("NSCoder"),
            "defaultValue": None
          })
        ],
        "failable": Some("?"),
        "body": [
          FunctionCallExpression({
            "name": SwiftIdentifier("fatalError"),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value": SwiftIdentifier("\"init(coder:) has not been implemented\"")
              })
            ]
          })
        ]
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
    let memberOrSelfExpression = (firstIdentifier, statements) =>
      switch firstIdentifier {
      | "self" => MemberExpression(statements)
      | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
      };
    let parentNameOrSelf = (parent: Types.layer) =>
      parent === rootLayer ? "self" : parent.name |> Swift.Format.layerName;
    let layerMemberExpression = (layer: Types.layer, statements) =>
      memberOrSelfExpression(parentNameOrSelf(layer), statements);
    let setUpViewsDoc = (root: Types.layer) => {
      let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
        switch parent {
        | None => []
        | Some(parent) => [
            FunctionCallExpression({
              "name": layerMemberExpression(parent, [SwiftIdentifier("addSubview")]),
              "arguments": [SwiftIdentifier(layer.name |> Swift.Format.layerName)]
            })
          ]
        };
      FunctionDeclaration({
        "name": "setUpViews",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body": Layer.flatmapParent(addSubviews, root) |> List.concat
      })
    };
    let getConstraints = (root: Types.layer) => {
      /* titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true */
      let setUpContraint = (layer: Types.layer, anchor1, parent: Types.layer, anchor2, constant) => {
        let variableName =
          Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(anchor1) ++ "Constraint";
        let initialValue =
          MemberExpression([
            SwiftIdentifier(layer.name |> Swift.Format.layerName),
            SwiftIdentifier(anchor1),
            FunctionCallExpression({
              "name": SwiftIdentifier("constraint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("equalTo")),
                  "value": layerMemberExpression(parent, [SwiftIdentifier(anchor2)])
                }),
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("constant")),
                  "value": LiteralExpression(FloatingPoint(constant))
                })
              ]
            })
          ]);
        {variableName, initialValue}
      };
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
              let previousLayer = List.nth(parent.children, index - 1);
              let previousMargin = Layer.getMargin(previousLayer);
              let betweenConstant =
                direction == "column" ?
                  previousMargin.bottom +. layerMargin.top :
                  previousMargin.right +. layerMargin.left;
              let primaryAfterConstant =
                direction == "column" ?
                  parentPadding.bottom +. layerMargin.bottom :
                  parentPadding.right +. layerMargin.right;
              [
                setUpContraint(
                  layer,
                  primaryBeforeAnchor,
                  previousLayer,
                  primaryAfterAnchor,
                  betweenConstant
                ),
                setUpContraint(
                  layer,
                  primaryAfterAnchor,
                  parent,
                  primaryAfterAnchor,
                  primaryAfterConstant
                )
              ]
            | _ =>
              let previousLayer = List.nth(parent.children, index - 1);
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
          primaryAxisConstraints @ secondaryAxisConstraints
        };
        parent.children |> List.mapi(addConstraints) |> List.concat
      };
      root |> Layer.flatmap(constrainAxes) |> List.concat
    };
    let constraints = getConstraints(rootLayer);
    let setUpConstraintsDoc = (root: Types.layer) => {
      let translatesAutoresizingMask = (layer: Types.layer) =>
        BinaryExpression({
          "left":
            layerMemberExpression(
              layer,
              [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")]
            ),
          "operator": "=",
          "right": LiteralExpression(Boolean(false))
        });
      let defineConstraint = (def) =>
        ConstantDeclaration({
          "modifiers": [],
          "init": Some(def.initialValue),
          "pattern": IdentifierPattern({"identifier": def.variableName, "annotation": None})
        });
      let activateConstraints = () =>
        FunctionCallExpression({
          "name":
            MemberExpression([SwiftIdentifier("NSLayoutConstraint"), SwiftIdentifier("activate")]),
          "arguments": [
            FunctionCallArgument({
              "name": None,
              "value":
                LiteralExpression(
                  Array(constraints |> List.map((def) => SwiftIdentifier(def.variableName)))
                )
            })
          ]
        });
      let assignConstraint = (def) =>
        BinaryExpression({
          "left": MemberExpression([SwiftIdentifier("self"), SwiftIdentifier(def.variableName)]),
          "operator": "=",
          "right": SwiftIdentifier(def.variableName)
        });
      FunctionDeclaration({
        "name": "setUpConstraints",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          List.concat([
            root |> Layer.flatmap(translatesAutoresizingMask),
            [Empty],
            constraints |> List.map(defineConstraint),
            [Empty],
            [activateConstraints()],
            [Empty],
            constraints |> List.map(assignConstraint)
          ])
      })
    };
    let updateDoc = () => {
      /* let printStringBinding = ((key, value)) => Js.log2(key, value);
         let printLayerBinding = ((key: Types.layer, value)) => {
           Js.log(key.name);
           StringMap.bindings(value) |> List.iter(printStringBinding)
         };
         Layer.LayerMap.bindings(assignments) |> List.iter(printLayerBinding); */
      let initialValue = (layer: Types.layer, name) =>
        switch (StringMap.find_opt(name, layer.parameters)) {
        | Some(value) => Swift.Document.lonaValue(colors, value)
        | None => LiteralExpression(Integer(0))
        };
      let defineInitialValue = (layer: Types.layer, (name, value)) => {
        let (left, right) =
          switch (name, initialValue(layer, name)) {
          | ("visible", LiteralExpression(Boolean(value))) => (
              "isHidden",
              Ast.Swift.LiteralExpression(Boolean(! value))
            )
          | nodes => nodes
          };
        BinaryExpression({
          "left": layerMemberExpression(layer, [SwiftIdentifier(left)]),
          "operator": "=",
          "right": right
        })
      };
      /* TODO: Figure out how to handle images */
      let filterProperties = ((name, _)) => name != "image" && name != "textStyle";
      let defineInitialValues = ((layer, propertyMap)) =>
        propertyMap
        |> StringMap.bindings
        |> List.filter(filterProperties)
        |> List.map(defineInitialValue(layer));
      FunctionDeclaration({
        "name": "update",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          (assignments |> Layer.LayerMap.bindings |> List.map(defineInitialValues) |> List.concat)
          @ [Empty]
          @ [Logic.toSwiftAST(colors, rootLayer, logic)]
      })
    };
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        ImportDeclaration("Foundation"),
        LineComment("MARK: - " ++ name),
        Empty,
        ClassDeclaration({
          "name": name,
          "inherits": [TypeName("UIView")],
          "modifier": None,
          "isFinal": false,
          "body":
            List.concat([
              [LineComment("MARK: Lifecycle")],
              [Empty],
              [initializerDoc()],
              [Empty],
              [initializerCoderDoc()],
              [LineComment("MARK: Public")],
              [Empty],
              parameters |> List.map(parameterVariableDoc),
              [LineComment("MARK: Private")],
              [Empty],
              nonRootLayers |> List.map(viewVariableDoc),
              [Empty],
              constraints |> List.map((def) => constraintVariableDoc(def.variableName)),
              [Empty],
              [setUpViewsDoc(rootLayer)],
              [Empty],
              [setUpConstraintsDoc(rootLayer)],
              [Empty],
              [
                FunctionDeclaration({
                  "name": "setUpDefaults",
                  "modifiers": [AccessLevelModifier(PrivateModifier)],
                  "parameters": [],
                  "body": []
                }),
                Empty,
                updateDoc()
              ]
            ])
        })
      ]
    })
  };
};