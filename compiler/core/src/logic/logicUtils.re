type context = {
  config: Config.t,
  isStatic: bool,
  rootNode: LogicAst.syntaxNode,
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

let rec unfoldPairs = (items: LogicAst.list('t)) =>
  switch (items) {
  | Empty => []
  | Next(head, rest) => [head, ...unfoldPairs(rest)]
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
};