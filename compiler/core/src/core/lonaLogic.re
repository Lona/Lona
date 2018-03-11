type expr =
  | AssignmentExpression(
      {
        .
        "assignee": expr,
        "content": expr
      }
    )
  | IfExpression(
      {
        .
        "condition": expr,
        "body": list(expr)
      }
    )
  | VariableDeclarationExpression(
      {
        .
        "identifier": expr,
        "content": expr
      }
    )
  | BinaryExpression(
      {
        .
        "left": expr,
        "op": expr,
        "right": expr
      }
    )
  | MemberExpression(list(expr))
  | IdentifierExpression(string)
  | LiteralExpression(Types.lonaValue)
  | PlaceholderExpression;