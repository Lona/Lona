module Ast = SwiftAst;

module Format = SwiftFormat;

module Document = SwiftDocument;

let toSwiftAST =
    (
      options: SwiftOptions.options,
      colors,
      textStyles,
      rootLayer: Types.layer,
      logicRootNode
    ) => {
  let identifierName = node =>
    switch node {
    | Logic.Identifier(ltype, [head, ...tail]) =>
      switch head {
      | "parameters" => Ast.SwiftIdentifier(List.hd(tail))
      | "layers" =>
        switch tail {
        | [second, ...tail] when second == rootLayer.name =>
          Ast.SwiftIdentifier(
            List.tl(tail)
            |> List.fold_left(
                 (a, b) => a ++ "." ++ Format.camelCase(b),
                 List.hd(tail)
               )
          )
        | [second, ...tail] =>
          Ast.SwiftIdentifier(
            tail
            |> List.fold_left(
                 (a, b) => a ++ "." ++ Format.camelCase(b),
                 Format.layerName(second)
               )
          )
        | _ => SwiftIdentifier("BadIdentifier")
        }
      | _ => SwiftIdentifier(head)
      }
    | _ => SwiftIdentifier("BadIdentifier")
    };
  let logicValueToSwiftAST = x => {
    let initialValue =
      switch x {
      | Logic.Identifier(_) => identifierName(x)
      | Literal(value) => Document.lonaValue(colors, textStyles, value)
      };
    /* Here is the only place we should handle Logic -> Swift identifier conversion */
    switch (options.framework, initialValue) {
    | (_, Ast.SwiftIdentifier(name))
        when
          name
          |> Js.String.includes("margin")
          || name
          |> Js.String.includes("padding") =>
      Ast.LineComment("TODO: Margin & padding")
    | (_, Ast.SwiftIdentifier(name))
        when name |> Js.String.toLowerCase |> Js.String.endsWith("image") =>
      Ast.LineComment("TODO: Images")
    | (_, Ast.SwiftIdentifier(name)) when name |> Js.String.endsWith("height") =>
      Ast.SwiftIdentifier(
        name
        |> Js.String.replace(".height", "HeightAnchorConstraint?.constant")
      )
    | (_, Ast.SwiftIdentifier(name)) when name |> Js.String.endsWith("width") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace(".width", "WidthAnchorConstraint?.constant")
      )
    /* -- UIKit -- */
    | (UIKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".borderRadius") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace(".borderRadius", ".layer.cornerRadius")
      )
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".borderRadius") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace(".borderRadius", ".cornerRadius")
      )
    /* -- AppKit -- */
    | (AppKit, Ast.SwiftIdentifier(name))
        when name |> Js.String.endsWith(".backgroundColor") =>
      Ast.SwiftIdentifier(
        name |> Js.String.replace(".backgroundColor", ".fillColor")
      )
    | _ => initialValue
    };
  };
  let typeAnnotationDoc =
    fun
    | Types.Reference(typeName) =>
      switch typeName {
      | "Boolean" => Ast.TypeName("Bool")
      | _ => TypeName(typeName)
      }
    | Named(name, _) => TypeName(name);
  let fromCmp = x =>
    switch x {
    | Types.Eq => "=="
    | Neq => "!="
    | Gt => ">"
    | Gte => ">="
    | Lt => "<"
    | Lte => "<="
    | Unknown => "???"
    };
  let unwrapBlock =
    fun
    | Logic.Block(body) => body
    | node => [node];
  let rec inner = logicRootNode =>
    switch logicRootNode {
    | Logic.Assign(a, b) =>
      switch (logicValueToSwiftAST(b), logicValueToSwiftAST(a)) {
      | (Ast.SwiftIdentifier(name), other)
          when name |> Js.String.endsWith("visible") =>
        Ast.BinaryExpression({
          "left":
            Ast.SwiftIdentifier(
              name |> Js.String.replace("visible", "isHidden")
            ),
          "operator": "=",
          "right": Ast.PrefixExpression({operator: "!", expression: other})
        })
      | (other, Ast.SwiftIdentifier(name))
          when name |> Js.String.endsWith("visible") =>
        Ast.BinaryExpression({
          "left": Ast.PrefixExpression({operator: "!", expression: other}),
          "operator": "=",
          "right":
            Ast.SwiftIdentifier(
              name |> Js.String.replace("visible", "isHidden")
            )
        })
      | (Ast.SwiftIdentifier(name), right)
          when
            name
            |> Js.String.endsWith("textStyle")
            || name
            |> Js.String.endsWith("font") =>
        let name = name |> Js.String.replace(".font", ".textStyle");
        /* TODO: We need to make sure we assign to attributed text at the end of the update
           function if we assign to textStyle */
        Ast.StatementListHelper([
          Ast.BinaryExpression({
            "left":
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".textStyle", "TextStyle")
              ),
            "operator": "=",
            "right": right
          })
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
                   ++ SwiftDocument.labelAttributedTextName(options.framework)
                 )
            ),
          "operator": "=",
          "right":
            Ast.MemberExpression([
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".text", "TextStyle")
              ),
              Ast.FunctionCallExpression({
                "name": Ast.SwiftIdentifier("apply"),
                "arguments": [
                  Ast.FunctionCallArgument({
                    "name": Some(Ast.SwiftIdentifier("to")),
                    "value": right
                  })
                ]
              })
            ])
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
          "block": unwrapBlock(body) |> List.map(inner)
        })
      ])
    | Block(body) => Ast.StatementListHelper(body |> List.map(inner))
    | If(a, cmp, b, body) =>
      let left = logicValueToSwiftAST(a);
      let right = logicValueToSwiftAST(b);
      let operator = fromCmp(cmp);
      let body = unwrapBlock(body) |> List.map(inner);
      switch (left, operator, right) {
      | (Ast.LiteralExpression(Boolean(true)), "==", condition)
      | (condition, "==", Ast.LiteralExpression(Boolean(true))) =>
        Ast.IfStatement({"condition": condition, "block": body})
      | _ =>
        Ast.IfStatement({
          "condition":
            Ast.BinaryExpression({
              "left": left,
              "operator": operator,
              "right": right
            }),
          "block": body
        })
      };
    | Add(lhs, rhs, value) =>
      BinaryExpression({
        "left": logicValueToSwiftAST(value),
        "operator": "=",
        "right":
          Ast.BinaryExpression({
            "left": logicValueToSwiftAST(lhs),
            "operator": "+",
            "right": logicValueToSwiftAST(rhs)
          })
      })
    | Let(value) =>
      switch value {
      | Identifier(ltype, path) =>
        Ast.VariableDeclaration({
          "modifiers": [],
          "pattern":
            Ast.IdentifierPattern({
              "identifier":
                List.fold_left(
                  (a, b) => a ++ "." ++ b,
                  List.hd(path),
                  List.tl(path)
                ),
              "annotation": Some(ltype |> typeAnnotationDoc)
            }),
          "init": (None: option(Ast.node)),
          "block": (None: option(Ast.initializerBlock))
        })
      | _ => Empty
      }
    | LetEqual(left, right) =>
      /* TODO: This shouldn't just call into other nodes */
      let value = Logic.Assign(left, right);
      let variableName = Logic.Let(left);
      switch (left, variableName |> inner, value |> inner) {
      | (
          Identifier(_, path),
          Ast.VariableDeclaration(a),
          Ast.BinaryExpression(b)
        ) =>
        Ast.VariableDeclaration({
          "modifiers": a##modifiers,
          "pattern":
            Ast.IdentifierPattern({
              "identifier":
                List.fold_left(
                  (a, b) => a ++ "." ++ b,
                  List.hd(path),
                  List.tl(path)
                ),
              "annotation": None
            }),
          "init": Some(b##left),
          "block": a##block
        })
      | _ => Empty
      };
    | None => Empty
    };
  logicRootNode |> unwrapBlock |> List.map(inner);
};