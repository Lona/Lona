type expr =
  | AssignmentExpression(
      {
        .
        "assignee": expr,
        "content": expr,
      },
    )
  | BinaryExpression(
      {
        .
        "left": expr,
        "op": expr,
        "right": expr,
      },
    )
  | BlockExpression(list(expr))
  | IfExpression(
      {
        .
        "condition": expr,
        "body": list(expr),
      },
    )
  | VariableDeclarationExpression(
      {
        .
        "identifier": expr,
        "content": expr,
      },
    )
  | MemberExpression(list(expr))
  | IdentifierExpression(string)
  | LiteralExpression(Types.lonaValue)
  | PlaceholderExpression;

let identifier = (node: expr): option(string) =>
  switch (node) {
  | IdentifierExpression(value) => Some(value)
  | _ => None
  };

let identifierPath = (node: expr): option(list(string)) =>
  switch (node) {
  | MemberExpression(exprs)
      when exprs |> List.for_all(e => identifier(e) != None) =>
    Some(exprs |> List.map(identifier) |> Sequence.compact)
  | IdentifierExpression(value) => Some([value])
  | _ => None
  };

let allIdentifierPaths = node => {
  let addPath =
      (expr: expr, identifiers: list(list(string))): list(list(string)) =>
    switch (identifierPath(expr)) {
    | Some(path) =>
      List.mem(path, identifiers) ? identifiers : [path, ...identifiers]
    | None => identifiers
    };
  let rec extractPath =
          (node: expr, identifiers: list(list(string)))
          : list(list(string)) =>
    switch (node) {
    | AssignmentExpression(o) =>
      identifiers |> extractPath(o##assignee) |> extractPath(o##content)
    | BinaryExpression(o) =>
      identifiers |> extractPath(o##left) |> extractPath(o##right)
    | BlockExpression(o) => identifiers |> foldList(o)
    | IfExpression(o) =>
      identifiers |> extractPath(o##condition) |> foldList(o##body)
    | VariableDeclarationExpression(o) =>
      identifiers |> extractPath(o##identifier) |> extractPath(o##content)
    | MemberExpression(_) => addPath(node, identifiers)
    | IdentifierExpression(_) => addPath(node, identifiers)
    | LiteralExpression(_)
    | PlaceholderExpression => identifiers
    }
  and foldList = (list, identifiers) =>
    list |> List.fold_left((acc, n) => extractPath(n, acc), identifiers);
  extractPath(node, []);
};

let buildVariableDeclarations = node => {
  let identifiers = allIdentifierPaths(node);
  let nodes =
    identifiers
    /* Filter identifiers beginning with "parameters", since these are
     * already declared within the React props or component class */
    |> List.filter(path =>
         switch (path) {
         | [hd, _] => hd != "parameters"
         | _ => true
         }
       )
    |> List.map(path =>
         Logic.Let(Logic.Identifier(Types.undefinedType, path))
       );
  Logic.Block(nodes);
};