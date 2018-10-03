module Ast = JavaScriptAst;

let logicValueToJavaScriptAST = (config: Config.t, x: Logic.logicValue) =>
  switch (x) {
  | Logic.Identifier(_, path) => Ast.Identifier(path)
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
  let logicValueToJavaScriptASTWithColors = logicValueToJavaScriptAST(config);
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
      left: logicValueToJavaScriptASTWithColors(b),
      right: logicValueToJavaScriptASTWithColors(a),
    })
  | IfExists(a, body) =>
    IfStatement({
      test: logicValueToJavaScriptASTWithColors(a),
      consequent: [toJavaScriptAST(framework, config, body)],
    })
  | Block(body) =>
    Ast.Block(body |> List.map(toJavaScriptAST(framework, config)))
  | If(a, cmp, b, body) =>
    let condition =
      Ast.BinaryExpression({
        left: logicValueToJavaScriptASTWithColors(a),
        operator: fromCmp(cmp),
        right: logicValueToJavaScriptASTWithColors(b),
      });
    IfStatement({
      test: condition,
      consequent: [toJavaScriptAST(framework, config, body)],
    });
  | Add(lhs, rhs, value) =>
    let addition =
      Ast.BinaryExpression({
        left: logicValueToJavaScriptASTWithColors(lhs),
        operator: Ast.Plus,
        right: logicValueToJavaScriptASTWithColors(rhs),
      });
    AssignmentExpression({
      left: logicValueToJavaScriptASTWithColors(value),
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
      right: logicValueToJavaScriptASTWithColors(content),
    })
  | None => Unknown
  };
};