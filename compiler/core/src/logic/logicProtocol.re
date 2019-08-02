let uuid = (node: LogicAst.syntaxNode): string =>
  switch (node) {
  | Statement(Loop({id})) => id
  | Statement(Branch({id})) => id
  | Statement(Declaration({id})) => id
  | Statement(ExpressionStatement({id})) => id
  | Statement(Placeholder({id})) => id
  | Declaration(Variable({id})) => id
  | Declaration(Function({id})) => id
  | Declaration(Enumeration({id})) => id
  | Declaration(Namespace({id})) => id
  | Declaration(Placeholder({id})) => id
  | Declaration(Record({id})) => id
  | Declaration(ImportDeclaration({id})) => id
  | Identifier(Identifier({id})) => id
  | Expression(BinaryExpression({id})) => id
  | Expression(IdentifierExpression({id})) => id
  | Expression(FunctionCallExpression({id})) => id
  | Expression(LiteralExpression({id})) => id
  | Expression(MemberExpression({id})) => id
  | Expression(Placeholder({id})) => id
  | Pattern(Pattern({id})) => id
  | BinaryOperator(IsEqualTo({id})) => id
  | BinaryOperator(IsNotEqualTo({id})) => id
  | BinaryOperator(IsLessThan({id})) => id
  | BinaryOperator(IsGreaterThan({id})) => id
  | BinaryOperator(IsLessThanOrEqualTo({id})) => id
  | BinaryOperator(IsGreaterThanOrEqualTo({id})) => id
  | BinaryOperator(SetEqualTo({id})) => id
  | Program(Program({id})) => id
  | FunctionParameter(Parameter({id})) => id
  | FunctionParameter(Placeholder({id})) => id
  | FunctionParameterDefaultValue(None({id})) => id
  | FunctionParameterDefaultValue(Value({id})) => id
  | TypeAnnotation(TypeIdentifier({id})) => id
  | TypeAnnotation(FunctionType({id})) => id
  | TypeAnnotation(Placeholder({id})) => id
  | Literal(None({id})) => id
  | Literal(Boolean({id})) => id
  | Literal(Number({id})) => id
  | Literal(String({id})) => id
  | Literal(Color({id})) => id
  | Literal(Array({id})) => id
  | TopLevelParameters(TopLevelParameters({id})) => id
  | EnumerationCase(Placeholder({id})) => id
  | EnumerationCase(EnumerationCase({id})) => id
  | GenericParameter(Parameter({id})) => id
  | GenericParameter(Placeholder({id})) => id
  | TopLevelDeclarations(TopLevelDeclarations({id})) => id
  | FunctionCallArgument(Argument({id})) => id
  | FunctionCallArgument(Placeholder({id})) => id
  | Comment(Comment({id})) => id
  };

let unfoldStatements = block =>
  block |> LogicUtils.unfoldPairs |> List.map(x => LogicAst.Statement(x));

let unfoldDeclarations = block =>
  block |> LogicUtils.unfoldPairs |> List.map(x => LogicAst.Declaration(x));

let unfoldExpressions = block =>
  block |> LogicUtils.unfoldPairs |> List.map(x => LogicAst.Expression(x));

let unfoldGenericParameters = block =>
  block
  |> LogicUtils.unfoldPairs
  |> List.map(x => LogicAst.GenericParameter(x));

let unfoldTypeAnnotations = block =>
  block |> LogicUtils.unfoldPairs |> List.map(x => LogicAst.TypeAnnotation(x));

let unfoldFunctionParameters = block =>
  block
  |> LogicUtils.unfoldPairs
  |> List.map(x => LogicAst.FunctionParameter(x));

let unfoldEnumerationCases = block =>
  block
  |> LogicUtils.unfoldPairs
  |> List.map(x => LogicAst.EnumerationCase(x));

let unfoldFunctionCallArguments = block =>
  block
  |> LogicUtils.unfoldPairs
  |> List.map(x => LogicAst.FunctionCallArgument(x));

let subnodes = (node: LogicAst.syntaxNode): list(LogicAst.syntaxNode) =>
  switch (node) {
  | Statement(Loop({block, expression})) =>
    [LogicAst.Expression(expression)] @ unfoldStatements(block)
  | Statement(Branch({block, condition})) =>
    [LogicAst.Expression(condition)] @ unfoldStatements(block)
  | Statement(Declaration({content})) => [LogicAst.Declaration(content)]
  | Statement(ExpressionStatement({expression})) => [
      LogicAst.Expression(expression),
    ]
  | Statement(Placeholder(_)) => []
  | Declaration(Variable({name, annotation, initializer_})) =>
    [LogicAst.Pattern(name)]
    @ (
      [
        switch (annotation) {
        | None => None
        | Some(value) => Some(LogicAst.TypeAnnotation(value))
        },
        switch (initializer_) {
        | None => None
        | Some(value) => Some(LogicAst.Expression(value))
        },
      ]
      |> Sequence.compact
    )
  | Declaration(
      Function({name, returnType, genericParameters, parameters, block}),
    ) =>
    [LogicAst.Pattern(name), LogicAst.TypeAnnotation(returnType)]
    @ unfoldGenericParameters(genericParameters)
    @ unfoldFunctionParameters(parameters)
    @ unfoldStatements(block)
  | Declaration(Enumeration({name, genericParameters, cases})) =>
    [LogicAst.Pattern(name)]
    @ unfoldGenericParameters(genericParameters)
    @ unfoldEnumerationCases(cases)
  | Declaration(Namespace({name, declarations})) =>
    [LogicAst.Pattern(name)] @ unfoldDeclarations(declarations)
  | Declaration(Placeholder(_)) => []
  | Declaration(Record({name, declarations, genericParameters})) =>
    [LogicAst.Pattern(name)]
    @ unfoldDeclarations(declarations)
    @ unfoldGenericParameters(genericParameters)
  | Declaration(ImportDeclaration({name})) => [LogicAst.Pattern(name)]
  | Identifier(Identifier(_)) => []
  | Expression(BinaryExpression({left, right, op})) => [
      LogicAst.Expression(left),
      LogicAst.Expression(right),
      LogicAst.BinaryOperator(op),
    ]
  | Expression(IdentifierExpression({identifier})) => [
      LogicAst.Identifier(identifier),
    ]
  | Expression(FunctionCallExpression({expression, arguments})) =>
    [LogicAst.Expression(expression)]
    @ unfoldFunctionCallArguments(arguments)
  | Expression(LiteralExpression({literal})) => [LogicAst.Literal(literal)]
  | Expression(MemberExpression({expression, memberName})) => [
      LogicAst.Expression(expression),
      LogicAst.Identifier(memberName),
    ]
  | Expression(Placeholder(_)) => []
  | Pattern(Pattern(_)) => []
  | BinaryOperator(IsEqualTo(_)) => []
  | BinaryOperator(IsNotEqualTo(_)) => []
  | BinaryOperator(IsLessThan(_)) => []
  | BinaryOperator(IsGreaterThan(_)) => []
  | BinaryOperator(IsLessThanOrEqualTo(_)) => []
  | BinaryOperator(IsGreaterThanOrEqualTo(_)) => []
  | BinaryOperator(SetEqualTo(_)) => []
  | Program(Program({block})) => unfoldStatements(block)
  | FunctionParameter(Parameter({localName, annotation, defaultValue})) => [
      LogicAst.Pattern(localName),
      LogicAst.TypeAnnotation(annotation),
      LogicAst.FunctionParameterDefaultValue(defaultValue),
    ]
  | FunctionParameter(Placeholder(_)) => []
  | FunctionParameterDefaultValue(None(_)) => []
  | FunctionParameterDefaultValue(Value({expression})) => [
      LogicAst.Expression(expression),
    ]
  | TypeAnnotation(TypeIdentifier({identifier, genericArguments})) =>
    [LogicAst.Identifier(identifier)]
    @ unfoldTypeAnnotations(genericArguments)
  | TypeAnnotation(FunctionType({returnType, argumentTypes})) =>
    [LogicAst.TypeAnnotation(returnType)]
    @ unfoldTypeAnnotations(argumentTypes)
  | TypeAnnotation(Placeholder(_)) => []
  | Literal(None(_)) => []
  | Literal(Boolean(_)) => []
  | Literal(Number(_)) => []
  | Literal(String(_)) => []
  | Literal(Color(_)) => []
  | Literal(Array({value})) => unfoldExpressions(value)
  | TopLevelParameters(TopLevelParameters({parameters})) =>
    unfoldFunctionParameters(parameters)
  | EnumerationCase(Placeholder(_)) => []
  | EnumerationCase(EnumerationCase({name, associatedValueTypes})) =>
    [LogicAst.Pattern(name)] @ unfoldTypeAnnotations(associatedValueTypes)
  | GenericParameter(Parameter({name})) => [LogicAst.Pattern(name)]
  | GenericParameter(Placeholder(_)) => []
  | TopLevelDeclarations(TopLevelDeclarations({declarations})) =>
    unfoldDeclarations(declarations)
  | FunctionCallArgument(Argument({expression})) => [
      LogicAst.Expression(expression),
    ]
  | FunctionCallArgument(Placeholder(_)) => []
  | Comment(_) => []
  };

let rec pathTo =
        (node: LogicAst.syntaxNode, id: string)
        : option(list(LogicAst.syntaxNode)) =>
  if (id == uuid(node)) {
    Some([node]);
  } else {
    List.fold_left(
      (result: option(list(LogicAst.syntaxNode)), item: LogicAst.syntaxNode) =>
        switch (result, pathTo(item, id)) {
        | (Some(_), _) => result
        | (None, Some(path)) => Some([node, ...path])
        | (None, None) => None
        },
      None,
      subnodes(node),
    );
  };

let find =
    (node: LogicAst.syntaxNode, id: string): option(LogicAst.syntaxNode) =>
  switch (pathTo(node, id)) {
  | Some(path) =>
    switch (List.rev(path)) {
    | [hd, ..._] => Some(hd)
    | [] => None
    }
  | None => None
  };

let declarationPathTo = (node: LogicAst.syntaxNode, id: string) =>
  switch (pathTo(node, id)) {
  | None => []
  | Some(path) =>
    path
    |> List.map(node =>
         switch (node) {
         | LogicAst.Declaration(declaration) => Some(declaration)
         | _ => None
         }
       )
    |> Sequence.compact
    |> List.map(declaration =>
         switch (declaration) {
         | LogicAst.Variable({name: Pattern({name})}) => name
         | LogicAst.Function({name: Pattern({name})}) => name
         | LogicAst.Enumeration({name: Pattern({name})}) => name
         | LogicAst.Namespace({name: Pattern({name})}) => name
         | LogicAst.Placeholder(_) => ""
         | LogicAst.Record({name: Pattern({name})}) => name
         | LogicAst.ImportDeclaration({name: Pattern({name})}) => name
         }
       )
  };

let rec flattenedMemberExpression =
        (memberExpression: LogicAst.expression)
        : option(list(LogicAst.identifier)) =>
  switch (memberExpression) {
  | MemberExpression({expression, memberName}) =>
    switch (expression) {
    | IdentifierExpression({identifier}) => Some([identifier, memberName])
    | _ =>
      switch (flattenedMemberExpression(expression)) {
      | Some(path) => Some(path @ [memberName])
      | None => None
      }
    }
  | _ => None
  };

let nodeTypeDescription = (node: LogicAst.syntaxNode): string =>
  switch (node) {
  | Statement(Loop({id})) => "Statement(Loop({id: " ++ id ++ "}))"
  | Statement(Branch({id})) => "Statement(Branch({id: " ++ id ++ "}))"
  | Statement(Declaration({id})) =>
    "Statement(Declaration({id: " ++ id ++ "}))"
  | Statement(ExpressionStatement({id})) =>
    "Statement(ExpressionStatement({id: " ++ id ++ "}))"
  | Statement(Placeholder({id})) =>
    "Statement(Placeholder({id: " ++ id ++ "}))"
  | Declaration(Variable({id})) =>
    "Declaration(Variable({id: " ++ id ++ "}))"
  | Declaration(Function({id})) =>
    "Declaration(Function({id: " ++ id ++ "}))"
  | Declaration(Enumeration({id})) =>
    "Declaration(Enumeration({id: " ++ id ++ "}))"
  | Declaration(Namespace({id})) =>
    "Declaration(Namespace({id: " ++ id ++ "}))"
  | Declaration(Placeholder({id})) =>
    "Declaration(Placeholder({id: " ++ id ++ "}))"
  | Declaration(Record({id})) => "Declaration(Record({id: " ++ id ++ "}))"
  | Declaration(ImportDeclaration({id})) =>
    "Declaration(ImportDeclaration({id: " ++ id ++ "}))"
  | Identifier(Identifier({id, string})) =>
    "Identifier(Identifier({string: " ++ string ++ ", id: " ++ id ++ "}))"
  | Expression(BinaryExpression({id})) =>
    "Expression(BinaryExpression({id: " ++ id ++ "}))"
  | Expression(IdentifierExpression({id})) =>
    "Expression(IdentifierExpression({id: " ++ id ++ "}))"
  | Expression(FunctionCallExpression({id})) =>
    "Expression(FunctionCallExpression({id: " ++ id ++ "}))"
  | Expression(LiteralExpression({id})) =>
    "Expression(LiteralExpression({id: " ++ id ++ "}))"
  | Expression(MemberExpression({id})) =>
    "Expression(MemberExpression({id: " ++ id ++ "}))"
  | Expression(Placeholder({id})) =>
    "Expression(Placeholder({id: " ++ id ++ "}))"
  | Pattern(Pattern({id, name})) =>
    "Pattern(Pattern({name: " ++ name ++ ", id: " ++ id ++ "}))"
  | BinaryOperator(IsEqualTo({id})) =>
    "BinaryOperator(IsEqualTo({id: " ++ id ++ "}))"
  | BinaryOperator(IsNotEqualTo({id})) =>
    "BinaryOperator(IsNotEqualTo({id: " ++ id ++ "}))"
  | BinaryOperator(IsLessThan({id})) =>
    "BinaryOperator(IsLessThan({id: " ++ id ++ "}))"
  | BinaryOperator(IsGreaterThan({id})) =>
    "BinaryOperator(IsGreaterThan({id: " ++ id ++ "}))"
  | BinaryOperator(IsLessThanOrEqualTo({id})) =>
    "BinaryOperator(IsLessThanOrEqualTo({id: " ++ id ++ "}))"
  | BinaryOperator(IsGreaterThanOrEqualTo({id})) =>
    "BinaryOperator(IsGreaterThanOrEqualTo({id: " ++ id ++ "}))"
  | BinaryOperator(SetEqualTo({id})) =>
    "BinaryOperator(SetEqualTo({id: " ++ id ++ "}))"
  | Program(Program({id})) => "Program(Program({id: " ++ id ++ "}))"
  | FunctionParameter(Parameter({id})) =>
    "FunctionParameter(Parameter({id: " ++ id ++ "}))"
  | FunctionParameter(Placeholder({id})) =>
    "FunctionParameter(Placeholder({id: " ++ id ++ "}))"
  | FunctionParameterDefaultValue(None({id})) =>
    "FunctionParameterDefaultValue(None({id: " ++ id ++ "}))"
  | FunctionParameterDefaultValue(Value({id})) =>
    "FunctionParameterDefaultValue(Value({id: " ++ id ++ "}))"
  | TypeAnnotation(TypeIdentifier({id})) =>
    "TypeAnnotation(TypeIdentifier({id: " ++ id ++ "}))"
  | TypeAnnotation(FunctionType({id})) =>
    "TypeAnnotation(FunctionType({id: " ++ id ++ "}))"
  | TypeAnnotation(Placeholder({id})) =>
    "TypeAnnotation(Placeholder({id: " ++ id ++ "}))"
  | Literal(None({id})) => "Literal(None({id: " ++ id ++ "}))"
  | Literal(Boolean({id})) => "Literal(Boolean({id: " ++ id ++ "}))"
  | Literal(Number({id})) => "Literal(Number({id: " ++ id ++ "}))"
  | Literal(String({id})) => "Literal(String({id: " ++ id ++ "}))"
  | Literal(Color({id})) => "Literal(Color({id: " ++ id ++ "}))"
  | Literal(Array({id})) => "Literal(Array({id: " ++ id ++ "}))"
  | TopLevelParameters(TopLevelParameters({id})) =>
    "TopLevelParameters(TopLevelParameters({id: " ++ id ++ "}))"
  | EnumerationCase(Placeholder({id})) =>
    "EnumerationCase(Placeholder({id: " ++ id ++ "}))"
  | EnumerationCase(EnumerationCase({id})) =>
    "EnumerationCase(EnumerationCase({id: " ++ id ++ "}))"
  | GenericParameter(Parameter({id})) =>
    "GenericParameter(Parameter({id: " ++ id ++ "}))"
  | GenericParameter(Placeholder({id})) =>
    "GenericParameter(Placeholder({id: " ++ id ++ "}))"
  | TopLevelDeclarations(TopLevelDeclarations({id})) =>
    "TopLevelDeclarations(TopLevelDeclarations({id: " ++ id ++ "}))"
  | Comment(Comment({id})) => "Comment(Comment({id: " ++ id ++ "}))"
  | FunctionCallArgument(Argument({id})) =>
    "FunctionCallArgument(Argument({id: " ++ id ++ "}))"
  | FunctionCallArgument(Placeholder({id})) =>
    "FunctionCallArgument(Placeholder({id: " ++ id ++ "}))"
  };

let rec nodeHierarchyDescription =
        (
          node: LogicAst.syntaxNode,
          ~indent: int=2,
          ~initialIndent: int=indent,
          (),
        )
        : string => {
  let description = nodeTypeDescription(node);
  let children =
    subnodes(node)
    |> List.map(child =>
         nodeHierarchyDescription(
           child,
           ~indent,
           ~initialIndent=initialIndent + indent,
           (),
         )
       )
    |> List.map(desc => Js.String.repeat(initialIndent, " ") ++ desc);
  [description, ...children] |> Format.joinWith("\n");
};