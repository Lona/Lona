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
    Ast.AssignmentExpression({
      "left": logicValueToJavaScriptAST(b),
      "right": logicValueToJavaScriptAST(a)
    })
  | IfExists(a, body) =>
    IfStatement({
      "test": logicValueToJavaScriptAST(a),
      "consequent": [toJavaScriptAST(body)]
    })
  | Block(body) => Ast.Block(body |> List.map(toJavaScriptAST))
  | If(a, cmp, b, body) =>
    let condition =
      Ast.BinaryExpression({
        "left": logicValueToJavaScriptAST(a),
        "operator": fromCmp(cmp),
        "right": logicValueToJavaScriptAST(b)
      });
    IfStatement({"test": condition, "consequent": [toJavaScriptAST(body)]});
  | Add(lhs, rhs, value) =>
    let addition =
      Ast.BinaryExpression({
        "left": logicValueToJavaScriptAST(lhs),
        "operator": Ast.Plus,
        "right": logicValueToJavaScriptAST(rhs)
      });
    AssignmentExpression({
      "left": logicValueToJavaScriptAST(value),
      "right": addition
    });
  | Let(value) =>
    switch value {
    | Identifier(_, path) => Ast.VariableDeclaration(Ast.Identifier(path))
    | _ => Unknown
    }
  | None => Unknown
  };
};
