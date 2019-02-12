module Ast = JavaScriptAst;

let rec lonaValueToJavaScriptAST =
        (config: Config.t, lonaValue: Types.lonaValue) =>
  if (LonaValue.isOptionalType(lonaValue.ltype)) {
    switch (LonaValue.decodeOptional(lonaValue)) {
    | Some(value) => lonaValueToJavaScriptAST(config, value)
    | None => Ast.Literal(LonaValue.null())
    };
  } else {
    switch (lonaValue.ltype) {
    | Reference("Color")
    | Named("Color", _) =>
      let colors = config.colorsFile.contents;
      let data = lonaValue.data |> Json.Decode.string;
      switch (Color.find(colors, data)) {
      | Some(color) => Ast.Identifier(["colors", color.id])
      | None => Literal(lonaValue)
      };
    | Reference("Shadow")
    | Named("Shadow", _) =>
      let shadowStyles = config.shadowsFile.contents;
      let data = Json.Decode.string(lonaValue.data);
      switch (Shadow.find(shadowStyles.styles, data)) {
      | Some(shadowStyle) => Ast.Identifier(["shadows", shadowStyle.id])
      | None => Literal(lonaValue)
      };
    | Reference("TextStyle")
    | Named("TextStyle", _) =>
      let textStyles = config.textStylesFile.contents;
      let data = lonaValue.data |> Json.Decode.string;
      switch (TextStyle.find(textStyles.styles, data)) {
      | Some(textStyle) => Ast.Identifier(["textStyles", textStyle.id])
      | None => Literal(lonaValue)
      };
    | _ => Literal(lonaValue)
    };
  };

let logicValueToJavaScriptAST = (config: Config.t, x: Logic.logicValue) =>
  switch (x) {
  | Logic.Identifier(_, path) => Ast.Identifier(path)
  | Literal(lonaValue) => lonaValueToJavaScriptAST(config, lonaValue)
  };

let fromCmp = x =>
  switch (x) {
  | Types.Eq => Ast.Eq
  | Neq => Neq
  | Gt => Gt
  | Gte => Gte
  | Lt => Lt
  | Lte => Lte
  | Unknown => Noop
  };

let rec toJavaScriptAST = (framework, config, node) => {
  let logicValueToJavaScriptASTWithConfig = logicValueToJavaScriptAST(config);

  switch (node) {
  | Logic.Assign(a, b) =>
    Ast.AssignmentExpression({
      left: logicValueToJavaScriptASTWithConfig(b),
      right: logicValueToJavaScriptASTWithConfig(a),
    })
  | IfExists(a, body) =>
    IfStatement({
      test: logicValueToJavaScriptASTWithConfig(a),
      consequent: [toJavaScriptAST(framework, config, body)],
      alternate: [],
    })
  | Block(body) =>
    Ast.Block(body |> List.map(toJavaScriptAST(framework, config)))
  | If(a, cmp, b, body) =>
    let aIsOptional = LonaValue.isOptionalType(Logic.getValueType(a));
    let bIsOptional = LonaValue.isOptionalType(Logic.getValueType(b));

    let operator =
      switch (fromCmp(cmp)) {
      | Eq => aIsOptional || bIsOptional ? Ast.LooseEq : Ast.Eq
      | operator => operator
      };

    let condition =
      Ast.BinaryExpression({
        left: logicValueToJavaScriptASTWithConfig(a),
        operator,
        right: logicValueToJavaScriptASTWithConfig(b),
      });
    IfStatement({
      test: condition,
      consequent: [toJavaScriptAST(framework, config, body)],
      alternate: [],
    });
  | IfLet(a, b, body) =>
    let condition =
      Ast.BinaryExpression({
        left: logicValueToJavaScriptASTWithConfig(b),
        operator: Ast.LooseNeq,
        right:
          logicValueToJavaScriptASTWithConfig(Literal(LonaValue.null())),
      });
    IfStatement({
      test: condition,
      consequent: [
        Ast.Block([
          toJavaScriptAST(framework, config, Logic.LetEqual(a, b)),
          toJavaScriptAST(framework, config, body),
        ]),
      ],
      alternate: [],
    });
  | Add(lhs, rhs, value) =>
    let addition =
      Ast.BinaryExpression({
        left: logicValueToJavaScriptASTWithConfig(lhs),
        operator: Ast.Plus,
        right: logicValueToJavaScriptASTWithConfig(rhs),
      });
    AssignmentExpression({
      left: logicValueToJavaScriptASTWithConfig(value),
      right: addition,
    });
  | Let(value) =>
    switch (value) {
    | Identifier(_, path) => Ast.VariableDeclaration(Ast.Identifier(path))
    | _ => Unknown
    }
  | LetEqual(value, content) =>
    Ast.AssignmentExpression({
      left:
        switch (value) {
        | Identifier(_, path) =>
          Ast.VariableDeclaration(Ast.Identifier(path))
        | _ => Unknown
        },
      right: logicValueToJavaScriptASTWithConfig(content),
    })
  | None => Unknown
  };
};

let flattenExpr = (nodes: list(LonaLogic.expr)): list(LonaLogic.expr) =>
  nodes
  |> List.map(node =>
       switch (node) {
       | LonaLogic.BlockExpression(list) => list
       | _ => [node]
       }
     )
  |> List.concat;

let rec exprToJavaScriptAST =
        (config: Config.t, node: LonaLogic.expr): JavaScriptAst.node => {
  /* Js.log(LonaLogic.toString(node)); */
  switch (node) {
  | LonaLogic.BinaryExpression(o) =>
    let a = o##left;
    let b = o##right;

    let aIsOptional = LonaValue.isOptionalType(LonaLogic.exprType(a));
    let bIsOptional = LonaValue.isOptionalType(LonaLogic.exprType(b));

    let opString =
      switch (o##op |> LonaLogic.identifier) {
      | Some(op) => op
      | None => "<?>"
      };

    let operator =
      switch (fromCmp(Decode.cmp(opString))) {
      | Eq => aIsOptional || bIsOptional ? Ast.LooseEq : Ast.Eq
      | operator => operator
      };

    Ast.BinaryExpression({
      left: exprToJavaScriptAST(config, a),
      operator,
      right: exprToJavaScriptAST(config, b),
    });
  | LonaLogic.MemberExpression(o) =>
    Ast.Block(o |> flattenExpr |> List.map(exprToJavaScriptAST(config)))
  | LonaLogic.PlaceholderExpression => Ast.Identifier(["/* Placeholder */"])
  | LonaLogic.LiteralExpression(o) => lonaValueToJavaScriptAST(config, o)
  | LonaLogic.IdentifierExpression(o) => Ast.Identifier([o])
  | LonaLogic.AssignmentExpression(o) =>
    Ast.AssignmentExpression({
      left: exprToJavaScriptAST(config, o##assignee),
      right: exprToJavaScriptAST(config, o##content),
    })
  | LonaLogic.IfExpression(o) =>
    IfStatement({
      test: exprToJavaScriptAST(config, o##condition),
      consequent:
        o##body |> flattenExpr |> List.map(exprToJavaScriptAST(config)),
      alternate: [],
    })
  | LonaLogic.BlockExpression(body) =>
    Ast.Block(body |> flattenExpr |> List.map(exprToJavaScriptAST(config)))
  /* | IfLet(a, b, body) =>
     let condition =
       Ast.BinaryExpression({
         left: logicValueToJavaScriptASTWithConfig(b),
         operator: Ast.LooseNeq,
         right:
           logicValueToJavaScriptASTWithConfig(Literal(LonaValue.null())),
       });
     IfStatement({
       test: condition,
       consequent: [
         Ast.Block([
           toJavaScriptAST(framework, config, Logic.LetEqual(a, b)),
           toJavaScriptAST(framework, config, body),
         ]),
       ],
       alternate: [],
     }); */
  /* | Add(lhs, rhs, value) =>
     let addition =
       Ast.BinaryExpression({
         left: logicValueToJavaScriptASTWithConfig(lhs),
         operator: Ast.Plus,
         right: logicValueToJavaScriptASTWithConfig(rhs),
       });
     AssignmentExpression({
       left: logicValueToJavaScriptASTWithConfig(value),
       right: addition,
     }); */
  | LonaLogic.VariableDeclarationExpression(o) =>
    let path = LonaLogic.identifierPath(o##identifier);

    switch (path, o##content) {
    | (Some(path), Some(content)) =>
      Ast.VariableDeclaration(
        AssignmentExpression({
          left: Ast.Identifier(path),
          right: exprToJavaScriptAST(config, content),
        }),
      )
    | (Some(path), None) => Ast.VariableDeclaration(Ast.Identifier(path))
    | (None, _) => Ast.Unknown
    };
  /* | LetEqual(value, content) =>
     Ast.AssignmentExpression({
       left:
         switch (value) {
         | Identifier(_, path) =>
           Ast.VariableDeclaration(Ast.Identifier(path))
         | _ => Unknown
         },
       right: logicValueToJavaScriptASTWithConfig(content),
     }) */
  /* | None => Unknown */
  };
};