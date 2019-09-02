type context = {
  config: Config.t,
  isStatic: bool,
  isTopLevel: bool,
  rootNode: LogicAst.syntaxNode,
  resolvedRootNode: LogicAst.syntaxNode,
};

let isPlaceholderDeclaration = (declaration: LogicAst.declaration) =>
  switch (declaration) {
  | Placeholder(_) => true
  | _ => false
  };

let isPlaceholderStatement = (statement: LogicAst.statement) =>
  switch (statement) {
  | Placeholder(_) => true
  | _ => false
  };

let isPlaceholderExpression = (expression: LogicAst.expression) =>
  switch (expression) {
  | Placeholder(_) => true
  | _ => false
  };

let isPlaceholderTypeAnnotation = (value: LogicAst.typeAnnotation) =>
  switch (value) {
  | Placeholder(_) => true
  | _ => false
  };

let isPlaceholderEnumCase = (value: LogicAst.enumerationCase) =>
  switch (value) {
  | Placeholder(_) => true
  | _ => false
  };

let isPlaceholderArgument = (value: LogicAst.functionCallArgument) =>
  switch (value) {
  | Placeholder(_) => true
  | _ => false
  };

let rec unfoldPairs = (items: LogicAst.list('t)) =>
  switch (items) {
  | Empty => []
  | Next(head, rest) => [head, ...unfoldPairs(rest)]
  };

let rec foldPairs = (items: list('t)): LogicAst.list('t) =>
  switch (items) {
  | [] => Empty
  | [first, ...rest] => Next(first, foldPairs(rest))
  };

let variableBuilder =
    (
      id: string,
      name: LogicAst.pattern,
      annotation: option(LogicAst.typeAnnotation),
      initializer_: option(LogicAst.expression),
    )
    : LogicAst.variableDeclaration => {
  LogicAst.id,
  name,
  annotation,
  initializer_,
  comment: None,
};
let rec makeProgram =
        (node: LogicAst.syntaxNode): option(LogicAst.programProgram) =>
  switch (node) {
  | Program(Program(program)) => Some(program)
  | Statement(statement) =>
    Some({id: Uuid.next(), block: Next(statement, Empty)})
  | Declaration(declaration) =>
    makeProgram(
      Statement(
        Declaration({
          LogicAst.id: Uuid.next(),
          LogicAst.content: declaration,
        }),
      ),
    )
  | TopLevelDeclarations(TopLevelDeclarations({declarations})) =>
    let convert = (declaration: LogicAst.declaration): LogicAst.statement =>
      LogicAst.Declaration({
        LogicAst.id: Uuid.next(),
        LogicAst.content: declaration,
      });

    Some({
      id: Uuid.next(),
      block: declarations |> unfoldPairs |> List.map(convert) |> foldPairs,
    });
  | _ => None
  };

let lastIdentifier = (expression: LogicAst.expression) =>
  switch (expression) {
  | IdentifierExpression({identifier}) => Some(identifier)
  | MemberExpression({memberName}) => Some(memberName)
  | _ => None
  };