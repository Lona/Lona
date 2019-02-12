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
        "content": option(expr),
      },
    )
  | MemberExpression(list(expr))
  | IdentifierExpression(string)
  | LiteralExpression(Types.lonaValue)
  | PlaceholderExpression;

let exprType = (expr: expr): Types.lonaType =>
  switch (expr) {
  | LiteralExpression(lonaValue) => lonaValue.ltype
  | _ => Types.undefinedType
  };

let memberExpressionFromPath = (path: list(string)): expr =>
  MemberExpression(path |> List.map(str => IdentifierExpression(str)));

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

let rec toString = (node: expr): string =>
  switch (node) {
  | AssignmentExpression(o) =>
    "Assign(" ++ toString(o##assignee) ++ "," ++ toString(o##content) ++ ")"
  | BinaryExpression(o) =>
    "BinaryExpression("
    ++ toString(o##left)
    ++ ","
    ++ toString(o##op)
    ++ ","
    ++ toString(o##right)
    ++ ")"
  | BlockExpression(o) => o |> listToString
  | IfExpression(o) =>
    "IfExpression("
    ++ toString(o##condition)
    ++ ") {\n"
    ++ listToString(o##body)
    ++ "\n}"
  | VariableDeclarationExpression(o) =>
    "VariableDeclarationExpression("
    ++ toString(o##identifier)
    ++ ", "
    ++ (
      switch (o##content) {
      | Some(content) => toString(content)
      | None => "undefined"
      }
    )
    ++ ")"
  | MemberExpression(_)
  | IdentifierExpression(_) =>
    switch (identifierPath(node)) {
    | Some(path) => path |> Format.joinWith(".")
    | None => "(?)"
    }
  | LiteralExpression(literal) => Js.Json.stringify(literal.data)
  | PlaceholderExpression => "@placeholder"
  }
and listToString = (nodes: list(expr)): string =>
  nodes |> List.map(toString) |> Format.joinWith("\n");

module Extract = {
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
        let identifiers = identifiers |> extractPath(o##identifier);
        switch (o##content) {
        | Some(content) => identifiers |> extractPath(content)
        | None => identifiers
        };
      | MemberExpression(_) => addPath(node, identifiers)
      | IdentifierExpression(_) => addPath(node, identifiers)
      | LiteralExpression(_)
      | PlaceholderExpression => identifiers
      }
    and foldList = (list, identifiers) =>
      list |> List.fold_left((acc, n) => extractPath(n, acc), identifiers);
    extractPath(node, []);
  };
};

module Build = {
  let variableDeclarations = node => {
    let identifiers = Extract.allIdentifierPaths(node);
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
           VariableDeclarationExpression({
             "identifier": memberExpressionFromPath(path),
             "content": None,
           })
         );
    BlockExpression(nodes);
  };
};