module Ast = JavaScriptAst;

let logicValueToJavaScriptAST = x =>
  switch x {
  | Logic.Identifier(_, path) => Ast.Identifier(path)
  | Literal(x) => Literal(x)
  };

let rec toJavaScriptAST = node => {
  let fromCmp = x =>
    switch x {
    | Types.Eq => Ast.Eq
    | Neq => Neq
    | Gt => Gt
    | Gte => Gte
    | Lt => Lt
    | Lte => Lte
    | Unknown => Noop
    };
  switch node {
  | Logic.Assign(a, b) =>
    Ast.AssignmentExpression(
      logicValueToJavaScriptAST(b),
      logicValueToJavaScriptAST(a)
    )
  | IfExists(a, body) =>
    ConditionalStatement(logicValueToJavaScriptAST(a), [toJavaScriptAST(body)])
  | Block(body) => Ast.Block(body |> List.map(toJavaScriptAST))
  | If(a, cmp, b, body) =>
    let condition =
      Ast.BooleanExpression(
        logicValueToJavaScriptAST(a),
        fromCmp(cmp),
        logicValueToJavaScriptAST(b)
      );
    ConditionalStatement(condition, [toJavaScriptAST(body)]);
  | Add(lhs, rhs, value) =>
    let addition =
      Ast.BooleanExpression(
        logicValueToJavaScriptAST(lhs),
        Plus,
        logicValueToJavaScriptAST(rhs)
      );
    AssignmentExpression(logicValueToJavaScriptAST(value), addition);
  | Let(value) =>
    switch value {
    | Identifier(_, path) => Ast.VariableDeclaration(Ast.Identifier(path))
    | _ => Unknown
    }
  | None => Unknown
  };
};
