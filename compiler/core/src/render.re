let indentLine = (amount, line) => Js.String.repeat(amount, " ") ++ line;

let rec flatMap = (list) =>
  switch list {
  | [head, ...tail] =>
    switch head {
    | Some(a) => [a, ...flatMap(tail)]
    | None => []
    }
  | [] => []
  };

let join = (sep, items) => items |> Array.of_list |> Js.Array.joinWith(sep);

module JavaScript = {
  let renderBinaryOperator = (x) =>
    switch x {
    | Ast.JavaScript.Eq => "==="
    | Neq => "!=="
    | Gt => ">"
    | Gte => ">="
    | Lt => "<"
    | Lte => "<="
    | Plus => "+"
    | Noop => ""
    };
  /* Render AST */
  let rec render = (ast) =>
    switch ast {
    | Ast.JavaScript.Identifier(path) =>
      switch path {
      | [first, ...rest] => [List.fold_left((a, b) => a ++ "." ++ b, first, rest)]
      | [] => []
      }
    | Literal(Types.Value(_, json)) => [Js.Json.stringify(json)]
    | VariableDeclaration(value) =>
      let value = render(value) |> join("");
      [{j|let $value;|j}]
    | AssignmentExpression(name, value) =>
      let name = render(name) |> join("");
      let value = render(value) |> join("");
      [{j|$name = $value|j}]
    | BooleanExpression(lhs, cmp, rhs) =>
      let lhs = render(lhs) |> join("");
      let rhs = render(rhs) |> join("");
      let cmp = renderBinaryOperator(cmp);
      [{j|$lhs $cmp $rhs|j}]
    | ConditionalStatement(condition, body) =>
      let condition = render(condition) |> join("");
      let body = body |> renderBody;
      List.flatten([[{j|if ($condition) {|j}], body, ["}"]])
    | Class(name, extends, body) =>
      let decl =
        switch extends {
        | Some(a) => {j|class $name extends $a {|j}
        | None => {j|class $name {|j}
        };
      List.flatten([[decl], body |> renderBody, ["};"]])
    | Method(name, parameters, body) =>
      let parameterList = parameters |> join(", ");
      List.flatten([[{j|$name($parameterList) {|j}], body |> renderBody, ["};"]])
    | CallExpression(value, parameters) =>
      let value = render(value) |> join("");
      let parameterList = parameters |> List.map(render) |> List.flatten |> join(", ");
      [{j|$value($parameterList)|j}]
    | Return(value) =>
      let value = render(value) |> join("");
      [{j|return $value;|j}]
    | JSXAttribute(name, value) =>
      let value = render(value) |> join("");
      [{j|$name={$value}|j}]
    | JSXElement(tag, attributes, body) =>
      let opening =
        switch attributes {
        | [] => tag
        | _ =>
          let attributes = attributes |> List.map(render) |> List.flatten |> join(" ");
          join(" ", [tag, attributes])
        };
      List.flatten([[{j|<$opening>|j}], body |> renderBody, [{j|</$tag>|j}]])
    | ArrayLiteral(body) =>
      switch body {
      | [] => ["[]"]
      | _ =>
        let body = body |> List.map(render) |> List.flatten |> join(", ");
        [{j|[ $body ]|j}]
      }
    | ObjectLiteral(body) =>
      switch body {
      | [] => ["{}"]
      | _ =>
        let body = body |> List.map(render) |> List.flatten |> join(", ");
        [{j|{ $body }|j}]
      }
    | ObjectProperty(name, value) =>
      let name = render(name) |> join("");
      let value = render(value) |> join("");
      [{j|$name: $value|j}]
    | Program(body) => body |> List.map(render) |> List.flatten
    | Block(body) => body |> List.map(render) |> List.flatten
    | Unknown => []
    }
  and renderBody = (body) => body |> List.map(render) |> List.flatten |> List.map(indentLine(2));
  let toString = (ast) => ast |> render |> join("\n");
  let log = (ast) => ast |> toString |> Js.log;
};