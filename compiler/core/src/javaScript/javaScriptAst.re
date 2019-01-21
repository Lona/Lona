[@bs.deriving accessors]
type binaryOperator =
  | Eq
  | LooseEq
  | Neq
  | LooseNeq
  | Gt
  | Gte
  | Lt
  | Lte
  | Plus
  | Minus
  | And
  | Or
  | Noop;

type importDeclaration = {
  source: string,
  specifiers: list(node),
}
and importSpecifier = {
  imported: string,
  local: option(string),
}
and classDeclaration = {
  id: string,
  superClass: option(string),
  body: list(node),
}
and methodDefinition = {
  key: string,
  value: node,
}
and functionExpression = {
  id: option(string),
  params: list(node),
  body: list(node),
}
and callExpression = {
  callee: node,
  arguments: list(node),
}
and jSXAttribute = {
  name: string,
  value: node,
}
and jSXElement = {
  tag: string,
  attributes: list(node),
  content: list(node),
}
and assignmentExpression = {
  left: node,
  right: node,
}
and binaryExpression = {
  left: node,
  operator: binaryOperator,
  right: node,
}
and unaryExpression = {
  prefix: bool,
  operator: string,
  argument: node,
}
and ifStatement = {
  test: node,
  consequent: list(node),
  alternate: list(node),
}
and property = {
  key: node,
  value: option(node),
}
and lineEndComment = {
  comment: string,
  line: node,
}
[@bs.deriving accessors]
and node =
  | Return(node)
  | Literal(Types.lonaValue)
  | StringLiteral(string)
  | Identifier(list(string))
  | ImportDeclaration(importDeclaration)
  | ImportSpecifier(importSpecifier)
  | ImportDefaultSpecifier(string)
  | ClassDeclaration(classDeclaration)
  | MethodDefinition(methodDefinition)
  | FunctionExpression(functionExpression)
  | ArrowFunctionExpression(functionExpression)
  | CallExpression(callExpression)
  | JSXAttribute(jSXAttribute)
  | JSXElement(jSXElement)
  | JSXExpressionContainer(node)
  | JSXSpreadAttribute(node)
  | SpreadElement(node)
  | VariableDeclaration(node)
  | AssignmentExpression(assignmentExpression)
  | BinaryExpression(binaryExpression)
  | UnaryExpression(unaryExpression)
  | IfStatement(ifStatement)
  | ArrayLiteral(list(node))
  | ObjectLiteral(list(node))
  | Property(property)
  | ExportDefaultDeclaration(node)
  | ExportNamedDeclaration(node)
  | Block(list(node))
  | Program(list(node))
  | LineEndComment(lineEndComment)
  | Empty
  | Unknown;

/* Children are mapped first */
let rec map = (f: node => node, node) =>
  switch (node) {
  | Return(value) => f(Return(value |> map(f)))
  | Literal(_)
  | StringLiteral(_)
  | Identifier(_)
  | ImportDeclaration(_)
  | ImportSpecifier(_)
  | ImportDefaultSpecifier(_) => f(node)
  | JSXExpressionContainer(value) =>
    f(JSXExpressionContainer(value |> map(f)))
  | JSXSpreadAttribute(value) => JSXSpreadAttribute(f(value))
  | SpreadElement(value) => SpreadElement(f(value))
  | ClassDeclaration(o) =>
    f(
      ClassDeclaration({
        id: o.id,
        superClass: o.superClass,
        body: o.body |> List.map(map(f)),
      }),
    )
  | MethodDefinition(o) =>
    f(MethodDefinition({key: o.key, value: o.value |> map(f)}))
  | FunctionExpression(o) =>
    f(
      FunctionExpression({
        id: o.id,
        params: o.params |> List.map(map(f)),
        body: o.body |> List.map(map(f)),
      }),
    )
  | ArrowFunctionExpression(o) =>
    f(
      ArrowFunctionExpression({
        id: o.id,
        params: o.params |> List.map(map(f)),
        body: o.body |> List.map(map(f)),
      }),
    )
  | CallExpression(o) =>
    f(
      CallExpression({
        callee: o.callee |> map(f),
        arguments: o.arguments |> List.map(map(f)),
      }),
    )
  | JSXAttribute(o) =>
    f(JSXAttribute({name: o.name, value: o.value |> map(f)}))
  | JSXElement(o) =>
    f(
      JSXElement({
        tag: o.tag,
        attributes: o.attributes |> List.map(map(f)),
        content: o.content |> List.map(map(f)),
      }),
    )
  | VariableDeclaration(value) => f(VariableDeclaration(value |> map(f)))
  | AssignmentExpression(o) =>
    f(
      AssignmentExpression({
        left: o.left |> map(f),
        right: o.right |> map(f),
      }),
    )
  | BinaryExpression(o) =>
    f(
      BinaryExpression({
        left: o.left |> map(f),
        operator: o.operator,
        right: o.right |> map(f),
      }),
    )
  | UnaryExpression(o) =>
    f(
      UnaryExpression({
        prefix: o.prefix,
        operator: o.operator,
        argument: o.argument |> map(f),
      }),
    )
  | IfStatement(o) =>
    f(
      IfStatement({
        test: o.test |> map(f),
        consequent: o.consequent |> List.map(map(f)),
        alternate: o.alternate |> List.map(map(f)),
      }),
    )
  | ArrayLiteral(body) => f(ArrayLiteral(body |> List.map(map(f))))
  | ObjectLiteral(body) => f(ObjectLiteral(body |> List.map(map(f))))
  | Property(o) =>
    f(
      Property({
        key: o.key |> map(f),
        value:
          switch (o.value) {
          | Some(value) => Some(value |> map(f))
          | None => None
          },
      }),
    )
  | ExportDefaultDeclaration(value) =>
    f(ExportDefaultDeclaration(value |> map(f)))
  | ExportNamedDeclaration(value) =>
    f(ExportNamedDeclaration(value |> map(f)))
  | Block(body) => f(Block(body |> List.map(map(f))))
  | Program(body) => f(Program(body |> List.map(map(f))))
  | LineEndComment(o) =>
    f(LineEndComment({comment: o.comment, line: o.line |> map(f)}))
  | Empty
  | Unknown => f(node)
  };

/* Takes an expression like `a === true` and converts it to `a` */
let optimizeTruthyBinaryExpression = node => {
  let booleanValue = sub =>
    switch (sub) {
    | Literal(value) => value.data |> Json.Decode.optional(Json.Decode.bool)
    | _ => (None: option(bool))
    };
  switch (node) {
  | BinaryExpression(o) =>
    switch (booleanValue(o.left), o.operator, booleanValue(o.right)) {
    | (_, Eq, Some(true)) => o.left
    | (Some(true), Eq, _) => o.right
    | _ => node
    }
  | _ => node
  };
};

/* Renamed "layer.View.backgroundColor" to something JS-safe and nice looking */
let renameIdentifiers = node =>
  switch (node) {
  | Identifier([head, ...tail]) =>
    switch (head) {
    | "parameters" => Identifier(["this", "props", ...tail])
    | "layers" =>
      switch (tail) {
      | [second, ...tail] =>
        Identifier([
          tail |> List.fold_left((a, b) => a ++ "$" ++ b, second),
        ])
      | _ => node
      }
    | _ => node
    }
  | _ => node
  };

let optimize = node => node |> map(optimizeTruthyBinaryExpression);

let prepareForRender = node => node |> map(renameIdentifiers);