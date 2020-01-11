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

let joinPrograms =
    (programs: list(LogicAst.programProgram)): LogicAst.programProgram => {
  let statements =
    programs
    |> List.map((program: LogicAst.programProgram) =>
         program.block |> unfoldPairs
       )
    |> List.concat;
  {LogicAst.id: Uuid.next(), block: statements |> foldPairs};
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

let standardImportsProgram: LogicAst.programProgram = {
  let libraryImports: list(LogicAst.statement) =
    ["Prelude", "Color", "Shadow", "TextStyle"]
    |> List.map((libraryName) =>
         (
           Declaration({
             id: Uuid.next(),
             content:
               LogicAst.ImportDeclaration({
                 id: Uuid.next(),
                 name: Pattern({id: Uuid.next(), name: libraryName}),
               }),
           }): LogicAst.statement
         )
       );
  {id: Uuid.next(), block: libraryImports |> foldPairs};
};

let rec resolveImports =
        (
          libraries: list(Config.file(LogicAst.syntaxNode)),
          program: LogicAst.programProgram,
          ~existingImports: ref(list(string))=ref([]),
          (),
        )
        : LogicAst.programProgram => {
  let out =
    program.block
    |> unfoldPairs
    |> Sequence.rejectWhere(isPlaceholderStatement)
    |> List.map(statement =>
         switch (statement) {
         | LogicAst.Loop(_) => [statement]
         | Declaration({
             content:
               ImportDeclaration({name: Pattern({name: libraryName})}),
           }) =>
           let alreadyFound = List.mem(libraryName, existingImports^);
           let library =
             libraries
             |> Sequence.firstWhere((file: Config.file(LogicAst.syntaxNode)) =>
                  Node.Path.basename_ext(file.path, ".logic") == libraryName
                );
           switch (alreadyFound, library) {
           | (false, Some(file)) =>
             existingImports := [libraryName, ...existingImports^];
             let libraryProgram = makeProgram(file.contents);
             switch (libraryProgram) {
             | Some(program) =>
               let resolvedProgram =
                 resolveImports(libraries, program, ~existingImports, ());
               let statements = resolvedProgram.block |> unfoldPairs;
               [statement, ...statements];
             | None => [statement]
             };
           | (true, Some(_)) => [statement]
           | (_, None) =>
             Log.warn2("Failed to find and import library", libraryName);
             [statement];
           };
         | _ => [statement]
         }
       )
    |> List.concat;

  {id: Uuid.next(), block: out |> foldPairs};
};

let lastIdentifier = (expression: LogicAst.expression) =>
  switch (expression) {
  | IdentifierExpression({identifier}) => Some(identifier)
  | MemberExpression({memberName}) => Some(memberName)
  | _ => None
  };