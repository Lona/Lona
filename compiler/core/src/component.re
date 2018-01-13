module JavaScript = {
  let generate = (name, json) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
    let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
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
  type directionParameter = {
    lonaName: string,
    swiftName: string
  };
  let generate = (name, json, colors) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    /* Remove the root element */
    let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
    let logic = json |> Decode.Component.logic;
    let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
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
        "modifiers": [AccessLevelModifier(PublicModifier)],
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
    let paddingParameters = [
      {swiftName: "topPadding", lonaName: "paddingTop"},
      {swiftName: "trailingPadding", lonaName: "paddingRight"},
      {swiftName: "bottomPadding", lonaName: "paddingBottom"},
      {swiftName: "leadingPadding", lonaName: "paddingLeft"}
    ];
    let marginParameters = [
      {swiftName: "topMargin", lonaName: "marginTop"},
      {swiftName: "trailingMargin", lonaName: "marginRight"},
      {swiftName: "bottomMargin", lonaName: "marginBottom"},
      {swiftName: "leadingMargin", lonaName: "marginLeft"}
    ];
    let spacingVariableDoc = (layer: Types.layer) => {
      let variableName = (variable) =>
        layer === rootLayer ?
          variable : Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(variable);
      let marginVariables =
        layer === rootLayer ?
          [] :
          {
            let createVariable = (marginParameter: directionParameter) =>
              VariableDeclaration({
                "modifiers": [AccessLevelModifier(PrivateModifier)],
                "pattern":
                  IdentifierPattern({
                    "identifier": variableName(marginParameter.swiftName),
                    "annotation": Some(TypeName("CGFloat"))
                  }),
                "init":
                  Some(
                    LiteralExpression(
                      FloatingPoint(Layer.getNumberParameter(marginParameter.lonaName, layer))
                    )
                  ),
                "block": None
              });
            marginParameters |> List.map(createVariable)
          };
      let paddingVariables =
        switch layer.children {
        | [] => []
        | _ =>
          let createVariable = (paddingParameter: directionParameter) =>
            VariableDeclaration({
              "modifiers": [AccessLevelModifier(PrivateModifier)],
              "pattern":
                IdentifierPattern({
                  "identifier": variableName(paddingParameter.swiftName),
                  "annotation": Some(TypeName("CGFloat"))
                }),
              "init":
                Some(
                  LiteralExpression(
                    FloatingPoint(Layer.getNumberParameter(paddingParameter.lonaName, layer))
                  )
                ),
              "block": None
            });
          paddingParameters |> List.map(createVariable)
        };
      marginVariables @ paddingVariables
    };
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
        "modifiers": [AccessLevelModifier(PublicModifier), RequiredModifier],
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
    let defaultValueForParameter =
      fun
      | "backgroundColor" =>
        MemberExpression([SwiftIdentifier("UIColor"), SwiftIdentifier("clear")])
      | _ => LiteralExpression(Integer(0));
    let initialLayerValue = (layer: Types.layer, name) =>
      switch (StringMap.find_opt(name, layer.parameters)) {
      | Some(value) => Swift.Document.lonaValue(colors, value)
      | None => defaultValueForParameter(name)
      };
    let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
      let (left, right) =
        switch (name, initialLayerValue(layer, name)) {
        | ("visible", LiteralExpression(Boolean(value))) => (
            layerMemberExpression(layer, [SwiftIdentifier("isHidden")]),
            LiteralExpression(Boolean(! value))
          )
        | ("borderRadius", LiteralExpression(FloatingPoint(_)) as right) => (
            layerMemberExpression(
              layer,
              [SwiftIdentifier("layer"), SwiftIdentifier("cornerRadius")]
            ),
            right
          )
        | ("height", LiteralExpression(FloatingPoint(_)) as right) => (
            SwiftIdentifier(parentNameOrSelf(layer) ++ "HeightAnchorConstraint?.constant"),
            right
          )
        | ("width", LiteralExpression(FloatingPoint(_)) as right) => (
            SwiftIdentifier(parentNameOrSelf(layer) ++ "WidthAnchorConstraint?.constant"),
            right
          )
        | (_, right) => (layerMemberExpression(layer, [SwiftIdentifier(name)]), right)
        };
      BinaryExpression({"left": left, "operator": "=", "right": right})
    };
    let setUpViewsDoc = (root: Types.layer) => {
      let setUpDefaultsDoc = () => {
        let filterParameters = ((name, _)) =>
          name != "image"
          && name != "textStyle"
          && name != "flexDirection"
          && name != "justifyContent"
          && name != "alignSelf"
          && name != "alignItems"
          && name != "flex"
          && name != "font"
          && ! Js.String.startsWith("padding", name)
          && ! Js.String.startsWith("margin", name)
          /* Handled by initial constraint setup */
          && name != "height"
          && name != "width";
        let filterNotAssignedByLogic = (layer: Types.layer, (parameterName, _)) =>
          switch (Layer.LayerMap.find_opt(layer, assignments)) {
          | None => true
          | Some(parameters) =>
            switch (StringMap.find_opt(parameterName, parameters)) {
            | None => true
            | Some(_) => false
            }
          };
        let defineInitialLayerValues = (layer: Types.layer) =>
          layer.parameters
          |> StringMap.bindings
          |> List.filter(filterParameters)
          |> List.filter(filterNotAssignedByLogic(layer))
          |> List.map(((k, v)) => defineInitialLayerValue(layer, (k, v)));
        rootLayer |> Layer.flatten |> List.map(defineInitialLayerValues) |> List.concat
      };
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
        "body":
          Swift.Document.joinGroups(
            Empty,
            [Layer.flatmapParent(addSubviews, root) |> List.concat, setUpDefaultsDoc()]
          )
      })
    };
    let getConstraints = (root: Types.layer) => {
      let setUpContraint =
          (layer: Types.layer, anchor1, parent: Types.layer, anchor2, relation, value) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor1 : Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(anchor1)
          )
          ++ "Constraint";
        let initialValue =
          MemberExpression([
            SwiftIdentifier(layer.name |> Swift.Format.layerName),
            SwiftIdentifier(anchor1),
            FunctionCallExpression({
              "name": SwiftIdentifier("constraint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier(relation)),
                  "value": layerMemberExpression(parent, [SwiftIdentifier(anchor2)])
                }),
                FunctionCallArgument({"name": Some(SwiftIdentifier("constant")), "value": value})
              ]
            })
          ]);
        {variableName, initialValue}
      };
      let setUpLessThanOrEqualToContraint =
          (layer: Types.layer, anchor1, parent: Types.layer, anchor2, value, suffix) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor1 : Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(anchor1)
          )
          ++ suffix;
        let initialValue =
          MemberExpression([
            SwiftIdentifier(layer.name |> Swift.Format.layerName),
            SwiftIdentifier(anchor1),
            FunctionCallExpression({
              "name": SwiftIdentifier("constraint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("lessThanOrEqualTo")),
                  "value": layerMemberExpression(parent, [SwiftIdentifier(anchor2)])
                }),
                FunctionCallArgument({"name": Some(SwiftIdentifier("constant")), "value": value})
              ]
            })
          ]);
        {variableName, initialValue}
      };
      let setUpDimensionContraint = (layer: Types.layer, anchor, constant) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor : Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(anchor)
          )
          ++ "Constraint";
        let initialValue =
          layerMemberExpression(
            layer,
            [
              SwiftIdentifier(anchor),
              FunctionCallExpression({
                "name": SwiftIdentifier("constraint"),
                "arguments": [
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("equalToConstant")),
                    "value": LiteralExpression(FloatingPoint(constant))
                  })
                ]
              })
            ]
          );
        {variableName, initialValue}
      };
      let negateNumber = (expression) =>
        PrefixExpression({"operator": "-", "expression": expression});
      let constraintConstantExpression =
          (layer: Types.layer, variable1, parent: Types.layer, variable2) => {
        let variableName = (layer: Types.layer, variable) =>
          layer === rootLayer ?
            variable : Swift.Format.layerName(layer.name) ++ Swift.Format.upperFirst(variable);
        BinaryExpression({
          "left": SwiftIdentifier(variableName(layer, variable1)),
          "operator": "+",
          "right": SwiftIdentifier(variableName(parent, variable2))
        })
      };
      let constrainAxes = (parent: Types.layer) => {
        let direction = Layer.getFlexDirection(parent);
        let primaryBeforeAnchor = direction == "column" ? "topAnchor" : "leadingAnchor";
        let primaryAfterAnchor = direction == "column" ? "bottomAnchor" : "trailingAnchor";
        let secondaryBeforeAnchor = direction == "column" ? "leadingAnchor" : "topAnchor";
        let secondaryAfterAnchor = direction == "column" ? "trailingAnchor" : "bottomAnchor";
        let height = Layer.getNumberParameterOpt("height", parent);
        let width = Layer.getNumberParameterOpt("width", parent);
        let primaryDimension = direction == "column" ? "height" : "width";
        let secondaryDimension = direction == "column" ? "width" : "height";
        let secondaryDimensionAnchor = secondaryDimension ++ "Anchor";
        let primaryDimensionValue = direction == "column" ? height : width;
        let secondaryDimensionValue = direction == "column" ? width : height;
        let addConstraints = (index, layer: Types.layer) => {
          let firstViewConstraints =
            switch index {
            | 0 =>
              let primaryBeforeConstant =
                direction == "column" ?
                  constraintConstantExpression(parent, "topPadding", layer, "topMargin") :
                  constraintConstantExpression(parent, "leadingPadding", layer, "leadingMargin");
              [
                setUpContraint(
                  layer,
                  primaryBeforeAnchor,
                  parent,
                  primaryBeforeAnchor,
                  "equalTo",
                  primaryBeforeConstant
                )
              ]
            | _ => []
            };
          let lastViewConstraints =
            switch index {
            | x when x == List.length(parent.children) - 1 =>
              let needsPrimaryAfterConstraint =
                Layer.getNumberParameterOpt(primaryDimension, layer) == None
                && Layer.getNumberParameterOpt("flex", layer) == None;
              let primaryAfterConstant =
                direction == "column" ?
                  constraintConstantExpression(parent, "bottomPadding", layer, "bottomMargin") :
                  constraintConstantExpression(parent, "trailingPadding", layer, "trailingMargin");
              needsPrimaryAfterConstraint ?
                [
                  setUpContraint(
                    layer,
                    primaryAfterAnchor,
                    parent,
                    primaryAfterAnchor,
                    "equalTo",
                    negateNumber(primaryAfterConstant)
                  )
                ] :
                []
            | _ => []
            };
          let middleViewConstraints =
            switch index {
            | 0 => []
            | _ =>
              let previousLayer = List.nth(parent.children, index - 1);
              let previousMargin = Layer.getMargin(previousLayer);
              let betweenConstant =
                direction == "column" ?
                  constraintConstantExpression(previousLayer, "bottomMargin", layer, "topMargin") :
                  constraintConstantExpression(
                    previousLayer,
                    "trailingMargin",
                    layer,
                    "leadingMargin"
                  );
              [
                setUpContraint(
                  layer,
                  primaryBeforeAnchor,
                  previousLayer,
                  primaryAfterAnchor,
                  "equalTo",
                  betweenConstant
                )
              ]
            };
          let secondaryBeforeConstant =
            direction == "column" ?
              constraintConstantExpression(parent, "leadingPadding", layer, "leadingMargin") :
              constraintConstantExpression(parent, "topPadding", layer, "topMargin");
          let secondaryAfterConstant =
            direction == "column" ?
              constraintConstantExpression(parent, "trailingPadding", layer, "trailingMargin") :
              constraintConstantExpression(parent, "bottomPadding", layer, "bottomMargin");
          let secondaryBeforeConstraint =
            setUpContraint(
              layer,
              secondaryBeforeAnchor,
              parent,
              secondaryBeforeAnchor,
              "equalTo",
              secondaryBeforeConstant
            );
          let secondaryAfterConstraint =
            setUpContraint(
              layer,
              secondaryAfterAnchor,
              parent,
              secondaryAfterAnchor,
              "equalTo",
              negateNumber(secondaryAfterConstant)
            );
          /* let needsSecondaryAfterConstraint =
             Layer.getNumberParameterOpt(secondaryDimension, layer) == None
             && Layer.getNumberParameterOpt("flex", layer) == None; */
          /* Js.log2("Needs secondary " ++ layer.name, needsSecondaryAfterConstraint); */
          /* If the parent's secondary axis is set to "fit content", this ensures
             the secondary axis dimension is greater than every child's. */
          let fitContentSecondaryConstraint =
            Layer.getStringParameterOpt("alignSelf", parent) != Some("stretch")
            && Layer.getNumberParameterOpt(secondaryDimension, parent) == None ?
              [
                setUpLessThanOrEqualToContraint(
                  layer,
                  secondaryDimensionAnchor,
                  parent,
                  secondaryDimensionAnchor,
                  negateNumber(
                    BinaryExpression({
                      "left": secondaryBeforeConstant,
                      "operator": "+",
                      "right": secondaryAfterConstant
                    })
                  ),
                  "ParentConstraint"
                )
              ] :
              [];
          /* Js.log2(
               "fit parent: " ++ parent.name ++ "child: " ++ layer.name,
               fitContentSecondaryConstraint
             ); */
          firstViewConstraints
          @ lastViewConstraints
          @ middleViewConstraints
          @ [secondaryBeforeConstraint]
          @ [secondaryAfterConstraint]
          @ fitContentSecondaryConstraint
        };
        let flexChildren =
          parent.children
          |> List.filter((child: Types.layer) => Layer.getNumberParameter("flex", child) === 1.0);
        let flexChildrenConstraints =
          switch flexChildren {
          | [first, ...rest] when List.length(rest) > 0 =>
            let sameAnchor = primaryDimension ++ "Anchor";
            let sameAnchorConstraint = (anchor, layer) =>
              setUpContraint(
                first,
                anchor,
                layer,
                anchor,
                "equalTo",
                LiteralExpression(FloatingPoint(0.0))
              );
            rest |> List.map(sameAnchorConstraint(sameAnchor))
          | _ => []
          };
        let heightConstraint =
          switch height {
          | Some(height) => [setUpDimensionContraint(parent, "heightAnchor", height)]
          | None => []
          };
        let widthConstraint =
          switch width {
          | Some(width) => [setUpDimensionContraint(parent, "widthAnchor", width)]
          | None => []
          };
        let constraints =
          [heightConstraint, widthConstraint, flexChildrenConstraints]
          @ (parent.children |> List.mapi(addConstraints));
        constraints |> List.concat
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
      let assignConstraintIdentifier = (def) =>
        BinaryExpression({
          "left":
            MemberExpression([SwiftIdentifier(def.variableName), SwiftIdentifier("identifier")]),
          "operator": "=",
          "right": LiteralExpression(String(def.variableName))
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
            constraints |> List.map(assignConstraint),
            [LineComment("For debugging")],
            constraints |> List.map(assignConstraintIdentifier)
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
      /* let cond = Logic.conditionallyAssignedIdentifiers(logic);
         cond |> Logic.IdentifierSet.elements |> List.iter(((ltype, path)) => Js.log(path)); */
      /* TODO: Figure out how to handle images */
      let filterParameters = ((name, _)) => name != "image" && name != "textStyle";
      let conditionallyAssigned = Logic.conditionallyAssignedIdentifiers(logic);
      let filterConditionallyAssigned = (layer: Types.layer, (name, _)) => {
        let isAssigned = ((_, value)) => value == ["layers", layer.name, name];
        conditionallyAssigned |> Logic.IdentifierSet.exists(isAssigned)
      };
      let defineInitialLayerValues = ((layer, propertyMap)) =>
        propertyMap
        |> StringMap.bindings
        |> List.filter(filterParameters)
        |> List.filter(filterConditionallyAssigned(layer))
        |> List.map(defineInitialLayerValue(layer));
      FunctionDeclaration({
        "name": "update",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          Swift.Document.joinGroups(
            Empty,
            [
              assignments
              |> Layer.LayerMap.bindings
              |> List.map(defineInitialLayerValues)
              |> List.concat,
              Logic.toSwiftAST(colors, rootLayer, logic)
            ]
          )
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
          "modifier": Some(PublicModifier),
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
              rootLayer |> Layer.flatmap(spacingVariableDoc) |> List.concat,
              [Empty],
              constraints |> List.map((def) => constraintVariableDoc(def.variableName)),
              [Empty],
              [setUpViewsDoc(rootLayer)],
              [Empty],
              [setUpConstraintsDoc(rootLayer)],
              [Empty],
              [updateDoc()]
            ])
        })
      ]
    })
  };
};