type context = {
  config: Config.t,
  isStatic: bool,
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

let reject = (f: 'a => bool, items: list('a)) =>
  items |> List.filter(item => !f(item));

let convertNativeType = (context: context, typeName: string): string =>
  switch (typeName) {
  | "Boolean" => "Bool"
  | "Number" => "CGFloat"
  | "WholeNumber" => "Int"
  | "String" => "String"
  | "Optional" => "Optional"
  | "URL" => SwiftDocument.imageTypeName(context.config)
  | "Color" => SwiftDocument.colorTypeName(context.config)
  | _ => typeName
  };

let rec unfoldPairs = (items: LogicAst.list('t)) =>
  switch (items) {
  | Empty => []
  | Next(head, rest) => [head, ...unfoldPairs(rest)]
  };

let rec convert = (config: Config.t, node: LogicAst.syntaxNode): SwiftAst.node => {
  let context = {config, isStatic: false};
  switch (node) {
  | LogicAst.Program(Program(contents)) => program(context, contents)
  | LogicAst.TopLevelDeclarations(TopLevelDeclarations(contents)) =>
    topLevelDeclarations(context, contents)
  | _ =>
    Js.log("Unhandled syntaxNode type");
    Empty;
  };
}
and program = (context: context, node: LogicAst.programProgram): SwiftAst.node =>
  SwiftAst.topLevelDeclaration({
    "statements":
      node.block
      |> unfoldPairs
      |> reject(isPlaceholderStatement)
      |> List.map(statement(context)),
  })
and topLevelDeclarations =
    (
      context: context,
      node: LogicAst.topLevelDeclarationsTopLevelDeclarations,
    )
    : SwiftAst.node =>
  SwiftAst.topLevelDeclaration({
    "statements":
      node.declarations
      |> unfoldPairs
      |> reject(isPlaceholderDeclaration)
      |> List.map(declaration(context)),
  })
and statement = (context: context, node: LogicAst.statement): SwiftAst.node =>
  switch (node) {
  | Declaration({content}) => declaration(context, content)
  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled statement type");
    Empty;
  }
and declaration =
    (context: context, node: LogicAst.declaration): SwiftAst.node =>
  switch (node) {
  | ImportDeclaration(_) => Empty
  | Namespace({name: LogicAst.Pattern({name}), declarations}) =>
    let context = {...context, isStatic: true};
    SwiftAst.EnumDeclaration({
      "name": name,
      "isIndirect": true,
      "inherits": [],
      "modifier": Some(SwiftAst.PublicModifier),
      "body":
        declarations
        |> unfoldPairs
        |> reject(isPlaceholderDeclaration)
        |> List.map(declaration(context)),
    });
  | Variable({name: LogicAst.Pattern({name}), annotation, initializer_}) =>
    SwiftAst.ConstantDeclaration({
      "modifiers":
        (context.isStatic ? [SwiftAst.StaticModifier] : [])
        @ [AccessLevelModifier(PublicModifier)],
      "pattern":
        SwiftAst.IdentifierPattern({
          "identifier": SwiftAst.SwiftIdentifier(name),
          "annotation": annotation |> Monad.map(typeAnnotation(context)),
        }),
      "init": initializer_ |> Monad.map(expression(context)),
    })
  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled declaration type");
    Empty;
  }
and expression = (context: context, node: LogicAst.expression): SwiftAst.node =>
  switch (node) {
  | IdentifierExpression({
      identifier: Identifier({string: name, isPlaceholder: _}),
    }) =>
    SwiftIdentifier(name)
  | LiteralExpression({literal: value}) => literal(context, value)
  | Placeholder(_) =>
    Js.log("Placeholder expression remaining");
    Empty;
  | _ =>
    Js.log("Unhandled expression type");
    Empty;
  }
and literal = (context: context, node: LogicAst.literal): SwiftAst.node =>
  switch (node) {
  | None(_) => SwiftAst.LiteralExpression(Nil)
  | Boolean({value}) => SwiftAst.LiteralExpression(Boolean(value))
  | Number({value}) => SwiftAst.LiteralExpression(FloatingPoint(value))
  | String({value}) => SwiftAst.LiteralExpression(String(value))
  | Color({value}) => SwiftAst.LiteralExpression(Color(value))
  | Array({value}) =>
    SwiftAst.LiteralExpression(
      Array(value |> unfoldPairs |> List.map(expression(context))),
    )
  }
and typeAnnotation =
    (context: context, node: LogicAst.typeAnnotation): SwiftAst.typeAnnotation =>
  switch (node) {
  | TypeIdentifier({
      identifier: Identifier({string: name, isPlaceholder: _}),
      genericArguments: Empty,
    }) =>
    TypeName(convertNativeType(context, name))
  | Placeholder(_) =>
    Js.log("Type placeholder remaining in file");
    TypeName("_");
  | _ =>
    Js.log("Unhandled type annotation");
    TypeName("_");
  };