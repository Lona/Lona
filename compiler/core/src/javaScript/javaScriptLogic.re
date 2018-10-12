module Ast = JavaScriptAst;

let rec logicValueToJavaScriptAST = (config: Config.t, x: Logic.logicValue) =>
  switch (x) {
  | Logic.Identifier(_, path) => Ast.Identifier(path)
  | Literal(lonaValue) when LonaValue.isOptionalType(lonaValue.ltype) =>
    switch (LonaValue.decodeOptional(lonaValue)) {
    | Some(value) => logicValueToJavaScriptAST(config, Literal(value))
    | None => Literal(LonaValue.null())
    }
  | Literal(lonaValue) =>
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
    }
  };

let rec toJavaScriptAST = (framework, config, node) => {
  let logicValueToJavaScriptASTWithConfig = logicValueToJavaScriptAST(config);
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
        toJavaScriptAST(framework, config, Logic.LetEqual(a, b)),
        toJavaScriptAST(framework, config, body),
      ],
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