module Ast = SwiftAst;

module Document = SwiftDocument;

let toSwiftAST =
    (
      options: SwiftOptions.options,
      config: Config.t,
      componentParameters: list(Types.parameter),
      rootLayer: Types.layer,
      logicRootNode,
    ) => {
  let identifierName = node =>
    switch (node) {
    | Logic.Identifier(_, [head, ...tail]) =>
      switch (head) {
      | "parameters" =>
        let parameterName = List.hd(tail);
        let parameter =
          componentParameters
          |> List.find((parameter: Types.parameter) =>
               parameter.name == ParameterKey.fromString(parameterName)
             );
        if (SwiftComponentParameter.isFunction(config, parameter)) {
          Ast.SwiftIdentifier("handle" ++ Format.upperFirst(parameterName));
        } else {
          Ast.SwiftIdentifier(List.hd(tail));
        };
      | "layers" =>
        switch (tail) {
        | [layerName, "vector", elementName, paramName] =>
          Ast.SwiftIdentifier(
            SwiftFormat.layerName(layerName)
            ++ "."
            ++ elementName
            ++ Format.upperFirst(paramName),
          )
        | [second, ...tail] when second == rootLayer.name =>
          Ast.SwiftIdentifier(
            List.tl(tail)
            |> List.fold_left(
                 (a, b) => a ++ "." ++ Format.camelCase(b),
                 List.hd(tail),
               ),
          )
        | [second, ...tail] =>
          Ast.SwiftIdentifier(
            tail
            |> List.fold_left(
                 (a, b) => a ++ "." ++ Format.camelCase(b),
                 SwiftFormat.layerName(second),
               ),
          )
        | _ => SwiftIdentifier("BadIdentifier")
        }
      | _ => SwiftIdentifier(head)
      }
    | _ => SwiftIdentifier("BadIdentifier")
    };
  let logicValueToSwiftAST = x => {
    let layer =
      switch (x) {
      | Logic.Identifier(_, ["layers", layerName, ..._]) =>
        Layer.findByName(layerName, rootLayer)
      | Logic.Identifier(_) => None
      | Literal(_) => None
      };
    let initialValue =
      switch (x) {
      | Logic.Identifier(_) => identifierName(x)
      | Literal(value) => Document.lonaValue(config, value)
      };
    /* Here is the only place we should handle Logic -> Swift identifier conversion */
    switch (options.framework, initialValue) {
    | (_, Ast.SwiftIdentifier(name))
        when
          name
          |> Js.String.includes("margin")
          || name
          |> Js.String.includes("padding") =>
      Ast.LineComment("TODO: Margin & padding: " ++ name)
    | (_, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".height") =>
      Ast.SwiftIdentifier(
        name
        |> Js.String.replace(".height", "HeightAnchorConstraint?.constant"),
      )
    | (_, Ast.SwiftIdentifier(name)) when name == "height" =>
      Ast.SwiftIdentifier(
        name
        |> Js.String.replace("height", "heightAnchorConstraint?.constant"),
      )
    | (_, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".width") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace(".width", "WidthAnchorConstraint?.constant"),
      )
    | (_, Ast.SwiftIdentifier(name)) when name == "width" =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("width", "widthAnchorConstraint?.constant"),
      )
    /* -- UIKit -- */
    /* TODO: Make sure "borderRadius" without the "." doesn't match intermediate variables */
    | (UIKit, Ast.SwiftIdentifier(name))
        when
          name
          |> Js.String.endsWith(".borderRadius")
          || name == "borderRadius" =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("borderRadius", "layer.cornerRadius"),
      )
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".opacity") || name == "opacity" =>
      Ast.SwiftIdentifier(name |> Js.String.replace("opacity", "alpha"))
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".resizeMode") || name == "resizeMode" =>
      switch (layer) {
      | Some((layer: Types.layer)) when layer.typeName == Types.VectorGraphic =>
        Ast.SwiftIdentifier(
          name |> Js.String.replace("resizeMode", "resizingMode"),
        )
      | _ =>
        Ast.SwiftIdentifier(
          name |> Js.String.replace("resizeMode", "contentMode"),
        )
      }
    | (UIKit, Ast.SwiftIdentifier(name))
        when
          name |> Js.String.endsWith(".borderWidth") || name == "borderWidth" =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("borderWidth", "layer.borderWidth"),
      )
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("hovered") =>
      Ast.LiteralExpression(Boolean(false))
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("pressed") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("pressed", "showsHighlight"),
      )
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("onPress") =>
      switch (layer) {
      | Some(layer) =>
        Ast.SwiftIdentifier(SwiftFormat.tapHandler(layer.name))
      | None => Ast.SwiftIdentifier("Unknown interactive layer")
      }
    /* -- AppKit -- */
    /* TODO: Make sure "borderRadius" without the "." doesn't match intermediate variables */
    | (AppKit, Ast.SwiftIdentifier(name))
        when
          name
          |> Js.String.endsWith(".borderRadius")
          || name == "borderRadius" =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("borderRadius", "cornerRadius"),
      )
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".opacity") || name == "opacity" =>
      Ast.SwiftIdentifier(name |> Js.String.replace("opacity", "alphaValue"))
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".resizeMode") || name == "resizeMode" =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("resizeMode", "resizingMode"),
      )
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("backgroundColor") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("backgroundColor", "fillColor"),
      )
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("numberOfLines") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace("numberOfLines", "maximumNumberOfLines"),
      )
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("hovered") =>
      Ast.SwiftIdentifier(name |> Js.String.replace(".hovered", "Hovered"))
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("pressed") =>
      Ast.SwiftIdentifier(name |> Js.String.replace(".pressed", "Pressed"))
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith("onPress") =>
      Ast.SwiftIdentifier(name |> Js.String.replace(".onPress", "OnPress"))
    | _ => initialValue
    };
  };
  let fromCmp = x =>
    switch (x) {
    | Types.Eq => "=="
    | Neq => "!="
    | Gt => ">"
    | Gte => ">="
    | Lt => "<"
    | Lte => "<="
    | Unknown => "UnknownCmp"
    };
  let unwrapBlock =
    fun
    | Logic.Block(body) => body
    | node => [node];
  let rec inner = logicRootNode =>
    switch (logicRootNode) {
    | Logic.Assign(a, b) =>
      switch (logicValueToSwiftAST(b), logicValueToSwiftAST(a)) {
      | (Ast.SwiftIdentifier(key), Ast.LiteralExpression(String(value)))
          when
            (
              key == "accessibilityType"
              || key
              |> Js.String.endsWith(".accessibilityType")
            )
            && options.framework == UIKit =>
        let createIsAccessibilityElementAssignment = enabled => {
          let newKey =
            key
            |> Js.String.replace(
                 "accessibilityType",
                 "isAccessibilityElement",
               );
          Ast.BinaryExpression({
            "left": Ast.SwiftIdentifier(newKey),
            "operator": "=",
            "right": Ast.LiteralExpression(Boolean(enabled)),
          });
        };
        switch (value) {
        | "none" => createIsAccessibilityElementAssignment(false)
        | "element" => createIsAccessibilityElementAssignment(true)
        | "container" => createIsAccessibilityElementAssignment(false)
        | _ => Empty
        };

      | (
          Ast.SwiftIdentifier(key) as left,
          Ast.LiteralExpression(Array(elements)),
        )
          when
            (
              key == "accessibilityElements"
              || key
              |> Js.String.endsWith(".accessibilityElements")
            )
            && options.framework == UIKit =>
        Ast.BinaryExpression({
          "left": left,
          "operator": "=",
          "right":
            Ast.LiteralExpression(
              Array(
                elements
                |> List.map((element: Ast.node) =>
                     switch (element) {
                     | LiteralExpression(String(layerName)) =>
                       Ast.SwiftIdentifier(SwiftFormat.layerName(layerName))
                     | _ => Empty
                     }
                   ),
              ),
            ),
        });
      | (Ast.SwiftIdentifier(name), Ast.LiteralExpression(_) as right)
      | (Ast.SwiftIdentifier(name), Ast.MemberExpression(_) as right)
          when
            (
              name == "borderColor"
              || name
              |> Js.String.endsWith(".borderColor")
            )
            && options.framework == UIKit =>
        let newName =
          name |> Js.String.replace("borderColor", "layer.borderColor");
        Ast.BinaryExpression({
          "left": Ast.SwiftIdentifier(newName),
          "operator": "=",
          "right":
            Ast.MemberExpression([right, Ast.SwiftIdentifier("cgColor")]),
        });
      | (
          Ast.SwiftIdentifier(name) as left,
          Ast.LiteralExpression(String(value)),
        )
          when
            name
            |> Js.String.endsWith("contentMode")
            && options.framework == UIKit
            || name
            |> Js.String.endsWith("resizingMode") =>
        Ast.BinaryExpression({
          "left": left,
          "operator": "=",
          "right":
            Ast.SwiftIdentifier("." ++ SwiftDocument.resizeModeValue(value)),
        })
      | (Ast.SwiftIdentifier(name), Ast.MemberExpression(right))
          when
            name |> Js.String.endsWith("shadow") && options.framework == UIKit =>
        Ast.MemberExpression(
          right
          @ [
            Ast.FunctionCallExpression({
              "name": Ast.SwiftIdentifier("apply"),
              "arguments": [
                Ast.FunctionCallArgument({
                  "name": Some(Ast.SwiftIdentifier("to")),
                  "value":
                    Ast.SwiftIdentifier(
                      name |> Js.String.replace(".shadow", ".layer"),
                    ),
                }),
              ],
            }),
          ],
        )
      | (Ast.SwiftIdentifier(name), other)
          when name |> Js.String.endsWith("visible") =>
        Ast.BinaryExpression({
          "left":
            Ast.SwiftIdentifier(
              name |> Js.String.replace("visible", "isHidden"),
            ),
          "operator": "=",
          "right": Ast.PrefixExpression({operator: "!", expression: other}),
        })
      | (other, Ast.SwiftIdentifier(name))
          when name |> Js.String.endsWith("visible") =>
        Ast.BinaryExpression({
          "left": Ast.PrefixExpression({operator: "!", expression: other}),
          "operator": "=",
          "right":
            Ast.SwiftIdentifier(
              name |> Js.String.replace("visible", "isHidden"),
            ),
        })
      | (Ast.SwiftIdentifier(name), right)
          when name |> Js.String.endsWith("textStyle") =>
        let right =
          switch (b) {
          | Identifier(_, path)
              when List.hd(path) == "layers" && List.length(path) > 2 =>
            let layerName = List.nth(path, 1);
            let layer = Layer.findByName(layerName, rootLayer);
            switch (layer) {
            | Some(layer) =>
              let param =
                Layer.getStringParameterOpt(TextAlign, layer.parameters);
              switch (param) {
              | None => right
              | Some(_) =>
                Ast.(
                  MemberExpression([
                    right,
                    FunctionCallExpression({
                      "name": SwiftIdentifier("with"),
                      "arguments": [
                        FunctionCallArgument({
                          "name": Some(SwiftIdentifier("alignment")),
                          "value":
                            SwiftIdentifier(
                              "."
                              ++ Layer.getStringParameter(
                                   TextAlign,
                                   layer.parameters,
                                 ),
                            ),
                        }),
                      ],
                    }),
                  ])
                )
              };
            | _ => right
            };
          | _ => right
          };
        /* TODO: We need to make sure we assign to attributed text at the end of the update
           function if we assign to textStyle */
        Ast.StatementListHelper([
          Ast.BinaryExpression({
            "left":
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".textStyle", "TextStyle"),
              ),
            "operator": "=",
            "right": right,
          }),
          Ast.BinaryExpression({
            "left":
              Ast.SwiftIdentifier(
                name
                |> Js.String.replace(
                     ".textStyle",
                     "."
                     ++ SwiftDocument.labelAttributedTextName(
                          options.framework,
                        ),
                   ),
              ),
            "operator": "=",
            "right":
              Ast.MemberExpression([
                Ast.SwiftIdentifier(
                  name |> Js.String.replace(".textStyle", "TextStyle"),
                ),
                Ast.FunctionCallExpression({
                  "name": Ast.SwiftIdentifier("apply"),
                  "arguments": [
                    Ast.FunctionCallArgument({
                      "name": Some(Ast.SwiftIdentifier("to")),
                      "value":
                        Ast.SwiftIdentifier(
                          name
                          |> Js.String.replace(
                               ".textStyle",
                               "."
                               ++ SwiftDocument.labelAttributedTextValue(
                                    options.framework,
                                  ),
                             ),
                        ),
                    }),
                  ],
                }),
              ]),
          }),
        ]);
      | (Ast.SwiftIdentifier(name), right)
          when name |> Js.String.endsWith("text") =>
        Ast.BinaryExpression({
          "left":
            Ast.SwiftIdentifier(
              name
              |> Js.String.replace(
                   ".text",
                   "."
                   ++ SwiftDocument.labelAttributedTextName(options.framework),
                 ),
            ),
          "operator": "=",
          "right":
            Ast.MemberExpression([
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".text", "TextStyle"),
              ),
              Ast.FunctionCallExpression({
                "name": Ast.SwiftIdentifier("apply"),
                "arguments": [
                  Ast.FunctionCallArgument({
                    "name": Some(Ast.SwiftIdentifier("to")),
                    "value": right,
                  }),
                ],
              }),
            ]),
        })
      | (left, right) =>
        Ast.BinaryExpression({"left": left, "operator": "=", "right": right})
      }
    | IfExists(a, body) =>
      /* TODO: Once we support optional params, compare to nil or extract via pattern */
      /* Ast.IfStatement({
           "condition": logicValueToSwiftAST(a),
           "block": unwrapBlock(body) |> List.map(inner)
         }) */
      Ast.StatementListHelper([
        Ast.LineComment("TODO: IfExists"),
        Ast.IfStatement({
          "condition": Ast.LiteralExpression(Ast.Boolean(true)),
          "block": unwrapBlock(body) |> List.map(inner),
        }),
      ])
    | Block(body) => Ast.StatementListHelper(body |> List.map(inner))
    | If(a, cmp, b, body) =>
      let left = logicValueToSwiftAST(a);
      let right = logicValueToSwiftAST(b);
      let operator = fromCmp(cmp);
      let body = unwrapBlock(body) |> List.map(inner);

      let aIsOptional = LonaValue.isOptionalType(Logic.getValueType(a));
      let bIsOptional = LonaValue.isOptionalType(Logic.getValueType(b));

      switch (left, operator, right) {
      | (
          Ast.LiteralExpression(Boolean(boolA)),
          "==",
          Ast.LiteralExpression(Boolean(boolB)),
        ) =>
        if (boolA == boolB) {
          Ast.StatementListHelper(body);
        } else {
          Empty;
        }
      | (
          Ast.LiteralExpression(Boolean(boolA)),
          "!=",
          Ast.LiteralExpression(Boolean(boolB)),
        ) =>
        if (boolA != boolB) {
          Ast.StatementListHelper(body);
        } else {
          Empty;
        }
      | (Ast.LiteralExpression(Boolean(true)), "==", condition)
      | (condition, "==", Ast.LiteralExpression(Boolean(true)))
          when !aIsOptional && !bIsOptional =>
        Ast.IfStatement({"condition": condition, "block": body})
      | _ =>
        Ast.IfStatement({
          "condition":
            Ast.BinaryExpression({
              "left": left,
              "operator": operator,
              "right": right,
            }),
          "block": body,
        })
      };
    | IfLet(a, b, body) =>
      let left = logicValueToSwiftAST(a);
      let right = logicValueToSwiftAST(b);
      let body = unwrapBlock(body) |> List.map(inner);

      Ast.(
        IfStatement({
          "condition":
            OptionalBindingCondition({
              "const": true,
              "pattern":
                IdentifierPattern({"identifier": left, "annotation": None}),
              "init": right,
            }),
          "block": body,
        })
      );
    | Add(lhs, rhs, value) =>
      BinaryExpression({
        "left": logicValueToSwiftAST(value),
        "operator": "=",
        "right":
          Ast.BinaryExpression({
            "left": logicValueToSwiftAST(lhs),
            "operator": "+",
            "right": logicValueToSwiftAST(rhs),
          }),
      })
    | Let(value) =>
      switch (value) {
      | Identifier(ltype, _) as identifier =>
        Ast.VariableDeclaration({
          "modifiers": [],
          "pattern":
            Ast.IdentifierPattern({
              "identifier": identifier |> logicValueToSwiftAST,
              "annotation":
                Some(ltype |> SwiftDocument.typeAnnotationDoc(config)),
            }),
          "init": (None: option(Ast.node)),
          "block": (None: option(Ast.initializerBlock)),
        })
      | _ => Empty
      }
    | LetEqual(left, right) =>
      /* TODO: This shouldn't just call into other nodes */
      let value = Logic.Assign(left, right);
      let variableName = Logic.Let(left);
      switch (left, variableName |> inner, value |> inner) {
      | (
          Identifier(_) as identifier,
          Ast.VariableDeclaration(a),
          Ast.BinaryExpression(b),
        ) =>
        Ast.VariableDeclaration({
          "modifiers": a##modifiers,
          "pattern":
            Ast.IdentifierPattern({
              "identifier": identifier |> logicValueToSwiftAST,
              "annotation": None,
            }),
          "init": Some(b##left),
          "block": a##block,
        })
      | _ => Empty
      };
    | None => Empty
    };
  logicRootNode |> unwrapBlock |> List.map(inner);
};