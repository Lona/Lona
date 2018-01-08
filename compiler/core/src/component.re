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
      let rec addConstraints = (layer: Types.layer) =>
        BinaryExpression({
          "left":
            memberOrSelfExpression(
              parentNameOrSelf(layer),
              [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")]
            ),
          "operator": "=",
          "right": LiteralExpression(Boolean(false))
        });
      FunctionDeclaration({
        "name": "setUpConstraints",
        "modifiers": [],
        "parameters": [],
        "body": root |> Layer.flatmap(addConstraints)
      })
    };
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        ImportDeclaration("Foundation"),
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
              [setUpConstraintsDoc(rootLayer)]
            ])
        })
      ]
    })
  };
};