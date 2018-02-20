[@bs.deriving accessors]
type binaryOperator =
  | Eq
  | Neq
  | Gt
  | Gte
  | Lt
  | Lte
  | Plus
  | Noop;

[@bs.deriving accessors]
type node =
  | Return(node)
  | Literal(Types.lonaValue)
  | Identifier(list(string))
  | ClassDeclaration(
      {
        .
        "id": string,
        "superClass": option(string),
        "body": list(node)
      }
    )
  | MethodDefinition(
      {
        .
        "key": string,
        "value": node
      }
    )
  | FunctionExpression(
      {
        .
        "id": option(string),
        "params": list(string),
        "body": list(node)
      }
    )
  | CallExpression(
      {
        .
        "callee": node,
        "arguments": list(node)
      }
    )
  | JSXAttribute(
      {
        .
        "name": string,
        "value": node
      }
    )
  | JSXElement(
      {
        .
        "tag": string,
        "attributes": list(node),
        "content": list(node)
      }
    )
  | VariableDeclaration(node)
  | AssignmentExpression(
      {
        .
        "left": node,
        "right": node
      }
    )
  | BinaryExpression(
      {
        .
        "left": node,
        "operator": binaryOperator,
        "right": node
      }
    )
  | IfStatement(
      {
        .
        "test": node,
        "consequent": list(node)
      }
    )
  | ArrayLiteral(list(node))
  | ObjectLiteral(list(node))
  | Property(
      {
        .
        "key": node,
        "value": node
      }
    )
  | ExportDefaultDeclaration(node)
  | Block(list(node))
  | Program(list(node))
  | LineEndComment(
      {
        .
        "comment": string,
        "line": node
      }
    )
  | Empty
  | Unknown;

/* Children are mapped first */
let rec map = (f, node) =>
  switch node {
  | Return(value) => f(Return(value |> map(f)))
  | Literal(_) => f(node)
  | Identifier(_) => f(node)
  | ClassDeclaration(o) =>
    f(
      ClassDeclaration({
        "id": o##id,
        "superClass": o##superClass,
        "body": o##body |> List.map(map(f))
      })
    )
  | MethodDefinition(o) =>
    f(MethodDefinition({"key": o##key, "value": o##value |> map(f)}))
  | FunctionExpression(o) =>
    f(
      FunctionExpression({
        "id": o##id,
        "params": o##params,
        "body": o##body |> List.map(map(f))
      })
    )
  | CallExpression(o) =>
    f(
      CallExpression({
        "callee": o##callee |> map(f),
        "arguments": o##arguments |> List.map(map(f))
      })
    )
  | JSXAttribute(o) =>
    f(JSXAttribute({"name": o##name, "value": o##value |> map(f)}))
  | JSXElement(o) =>
    f(
      JSXElement({
        "tag": o##tag,
        "attributes": o##attributes |> List.map(map(f)),
        "content": o##content |> List.map(map(f))
      })
    )
  | VariableDeclaration(value) => f(VariableDeclaration(value |> map(f)))
  | AssignmentExpression(o) =>
    f(
      AssignmentExpression({
        "left": o##left |> map(f),
        "right": o##right |> map(f)
      })
    )
  | BinaryExpression(o) =>
    f(
      BinaryExpression({
        "left": o##left |> map(f),
        "operator": o##operator,
        "right": o##right |> map(f)
      })
    )
  | IfStatement(o) =>
    f(
      IfStatement({
        "test": o##test |> map(f),
        "consequent": o##consequent |> List.map(map(f))
      })
    )
  | ArrayLiteral(body) => f(ArrayLiteral(body |> List.map(map(f))))
  | ObjectLiteral(body) => f(ObjectLiteral(body |> List.map(map(f))))
  | Property(o) =>
    f(Property({"key": o##key |> map(f), "value": o##value |> map(f)}))
  | ExportDefaultDeclaration(value) =>
    f(ExportDefaultDeclaration(value |> map(f)))
  | Block(body) => f(Block(body |> List.map(map(f))))
  | Program(body) => f(Program(body |> List.map(map(f))))
  | LineEndComment(o) =>
    f(LineEndComment({"comment": o##comment, "line": o##line |> map(f)}))
  | Empty
  | Unknown => f(node)
  };

/* Takes an expression like `a === true` and converts it to `a` */
let optimizeTruthyBinaryExpression = node => {
  let booleanValue = sub =>
    switch sub {
    | Literal(value) => value.data |> Json.Decode.optional(Json.Decode.bool)
    | _ => (None: option(bool))
    };
  switch node {
  | BinaryExpression(o) =>
    switch (booleanValue(o##left), o##operator, booleanValue(o##right)) {
    | (_, Eq, Some(true)) => o##left
    | (Some(true), Eq, _) => o##right
    | _ => node
    }
  | _ => node
  };
};

/* Renamed "layer.View.backgroundColor" to something JS-safe and nice looking */
let renameIdentifiers = node =>
  switch node {
  | Identifier([head, ...tail]) =>
    switch head {
    | "parameters" => Identifier(["this", "props", ...tail])
    | "layers" =>
      switch tail {
      | [second, ...tail] =>
        Identifier([tail |> List.fold_left((a, b) => a ++ "$" ++ b, second)])
      | _ => node
      }
    | _ => node
    }
  | _ => node
  };

let optimize = node => node |> map(optimizeTruthyBinaryExpression);

let prepareForRender = node => node |> map(renameIdentifiers);