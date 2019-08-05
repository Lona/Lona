open LogicUtils;
open Operators;

type recordParameter = {
  name: string,
  defaultValue: LogicAst.expression,
};

let createVariableOrProperty =
    (
      isStaticContext: bool,
      isDynamic,
      name: string,
      value: JavaScriptAst.node,
    )
    : JavaScriptAst.node =>
  if (isStaticContext) {
    if (isDynamic) {
      MethodDefinition({
        key: "get " ++ name,
        value:
          FunctionExpression({id: None, params: [], body: [Return(value)]}),
      });
    } else {
      Property({key: Identifier([name]), value: Some(value)});
    };
  } else {
    VariableDeclaration(
      AssignmentExpression({left: Identifier([name]), right: value}),
    );
  };

let sharedPrefix =
    (~rootNode: LogicAst.syntaxNode, ~a: string, ~b: string): list(string) => {
  let rec inner = (aPath, bPath) =>
    switch (aPath, bPath) {
    | ([a, ...aRest], [b, ...bRest]) when a == b => [
        a,
        ...inner(aRest, bRest),
      ]
    | _ => []
    };
  let aPath = LogicProtocol.declarationPathTo(rootNode, a);
  let bPath = LogicProtocol.declarationPathTo(rootNode, b);
  inner(aPath, bPath);
};

let rec resolveImports =
        (
          config: Config.t,
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
             config.logicLibraries
             |> Sequence.firstWhere((file: Config.file(LogicAst.syntaxNode)) =>
                  Node.Path.basename_ext(file.path, ".logic") == libraryName
                );
           switch (alreadyFound, library) {
           | (false, Some(file)) =>
             existingImports := [libraryName, ...existingImports^];
             let libraryProgram = LogicUtils.makeProgram(file.contents);
             switch (libraryProgram) {
             | Some(program) =>
               let resolvedProgram =
                 resolveImports(config, program, ~existingImports, ());
               let statements = resolvedProgram.block |> unfoldPairs;
               [statement, ...statements];
             | None => [statement]
             };
           | (true, Some(_)) => [statement]
           | (_, None) =>
             Js.log2("Failed to find and import library", libraryName);
             [statement];
           };
         | _ => [statement]
         }
       )
    |> List.concat;

  {id: Uuid.next(), block: out |> foldPairs};
};

let rec convert =
        (config: Config.t, node: LogicAst.syntaxNode): JavaScriptAst.node =>
  switch (LogicUtils.makeProgram(node)) {
  | Some(programNode) =>
    let resolvedProgramNode =
      LogicAst.Program(Program(resolveImports(config, programNode, ())));
    let context = {
      config,
      isStatic: false,
      isTopLevel: true,
      rootNode: node,
      resolvedRootNode: resolvedProgramNode,
    };
    /* Js.log(LogicProtocol.nodeHierarchyDescription(node, ())); */
    switch (node) {
    | LogicAst.Program(Program(contents)) => program(context, contents)
    | LogicAst.TopLevelDeclarations(TopLevelDeclarations(contents)) =>
      topLevelDeclarations(context, contents)
    | _ =>
      Js.log("Unhandled syntaxNode type");
      Empty;
    };
  | None =>
    Js.log("Failed to make program node from logic file");
    Empty;
  }
and program =
    (context: context, node: LogicAst.programProgram): JavaScriptAst.node =>
  JavaScriptAst.Program(
    node.block
    |> unfoldPairs
    |> Sequence.rejectWhere(isPlaceholderStatement)
    |> List.map(statement(context)),
  )
and topLevelDeclarations =
    (
      context: context,
      node: LogicAst.topLevelDeclarationsTopLevelDeclarations,
    )
    : JavaScriptAst.node =>
  JavaScriptAst.Program(
    node.declarations
    |> unfoldPairs
    |> Sequence.rejectWhere(isPlaceholderDeclaration)
    |> List.map(declaration(context)),
  )
and statement =
    (context: context, node: LogicAst.statement): JavaScriptAst.node =>
  switch (node) {
  | Declaration({content}) => declaration(context, content)
  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled statement type");
    Empty;
  }
and declaration =
    (context: context, node: LogicAst.declaration): JavaScriptAst.node =>
  switch (node) {
  | ImportDeclaration(_) => Empty
  | Namespace({name: LogicAst.Pattern({name}), declarations}) =>
    let newContext = {...context, isTopLevel: false, isStatic: true};

    let variable =
      createVariableOrProperty(
        context.isStatic,
        false,
        String.lowercase(name),
        ObjectLiteral(
          declarations
          |> unfoldPairs
          |> Sequence.rejectWhere(isPlaceholderDeclaration)
          |> List.map(declaration(newContext)),
        ),
      );

    if (context.isTopLevel) {
      ExportNamedDeclaration(variable);
    } else {
      variable;
    };
  | Variable({id, name: LogicAst.Pattern({name}), initializer_}) =>
    let newContext = {...context, isTopLevel: false};

    let initialValue =
      (initializer_ |> Monad.map(expression(newContext)))
      %? Identifier(["undefined"]);

    let isDynamic =
      LogicAst.Declaration(node)
      |> LogicTraversal.reduce(
           LogicTraversal.emptyConfig(), false, (result, child, _) =>
           switch (child) {
           | Expression(IdentifierExpression({id: identifierId})) =>
             let prefix =
               sharedPrefix(
                 ~rootNode=context.rootNode,
                 ~a=id,
                 ~b=identifierId,
               );
             if (prefix == []) {
               result;
             } else {
               true;
             };
           | _ => result
           }
         );

    let variable =
      createVariableOrProperty(
        context.isStatic,
        isDynamic,
        String.lowercase(name),
        initialValue,
      );

    if (context.isTopLevel) {
      ExportNamedDeclaration(variable);
    } else {
      variable;
    };
  | Record({
      name: LogicAst.Pattern({name}),
      genericParameters: _,
      /* declarations, */
    }) =>
    Empty
  | Enumeration({name: LogicAst.Pattern({name}), cases}) =>
    VariableDeclaration(
      AssignmentExpression({
        left: Identifier([JavaScriptFormat.enumName(name)]),
        right:
          ObjectLiteral(
            cases
            |> unfoldPairs
            |> List.map((enumCase: LogicAst.enumerationCase) =>
                 switch (enumCase) {
                 | Placeholder(_) => None
                 | EnumerationCase(value) => Some(value)
                 }
               )
            |> Sequence.compact
            |> List.map((enumCase: LogicAst.enumerationCaseEnumerationCase) => {
                 /* TODO: Handle enums with associated data */
                 let {LogicAst.name: Pattern({name}), associatedValueTypes} = enumCase;

                 JavaScriptAst.Property({
                   key: Identifier([JavaScriptFormat.enumCaseName(name)]),
                   value: Some(StringLiteral(name)),
                 });
               }),
          ),
      }),
    )

  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled declaration type");
    Empty;
  }
and expression =
    (context: context, node: LogicAst.expression): JavaScriptAst.node =>
  switch (node) {
  | IdentifierExpression({
      identifier: Identifier({id, string: name, isPlaceholder: _}),
    }) =>
    let standard: JavaScriptAst.node = Identifier([Format.lowerFirst(name)]);
    let scope = LogicScope.build(context.resolvedRootNode, ());
    let patternId = (scope.identifierToPattern)#get(id);
    switch (patternId) {
    | Some(patternId) =>
      let pattern = LogicProtocol.find(context.rootNode, patternId);
      switch (pattern) {
      | Some(Pattern(Pattern({id: patternId}))) =>
        let identifierPath =
          LogicProtocol.declarationPathTo(context.rootNode, patternId)
          |> List.map(Format.lowerFirst);
        Identifier(identifierPath);
      | _ => standard
      };
    | None => standard
    };

  | LiteralExpression({literal: value}) => literal(context, value)
  | MemberExpression({
      memberName: Identifier({string}),
      expression: innerExpression,
    }) =>
    MemberExpression({
      memberName: Format.lowerFirst(string),
      expression: expression(context, innerExpression),
    })
  | FunctionCallExpression({arguments, expression: innerExpression}) =>
    let recordDefinition: option(list(recordParameter)) =
      switch (innerExpression) {
      | IdentifierExpression({identifier: Identifier({id})}) =>
        let scope = LogicScope.build(context.resolvedRootNode, ());
        let patternId = (scope.identifierToPattern)#get(id);

        switch (patternId) {
        | Some(patternId) =>
          let pattern =
            LogicProtocol.parentOf(context.resolvedRootNode, patternId);
          switch (pattern) {
          | Some(Declaration(Record({declarations}))) =>
            let parameters =
              declarations
              |> unfoldPairs
              |> List.map((declaration: LogicAst.declaration) =>
                   switch (declaration) {
                   | Variable({
                       name: Pattern({name}),
                       initializer_: Some(defaultValue),
                     }) =>
                     Some({name, defaultValue})
                   | _ => None
                   }
                 )
              |> Sequence.compact;
            Some(parameters);
          | _ => None
          };
        | None => None
        };
      | _ => None
      };

    let validArguments =
      arguments |> unfoldPairs |> Sequence.rejectWhere(isPlaceholderArgument);

    switch (recordDefinition) {
    | Some(parameters) =>
      ObjectLiteral(
        parameters
        |> List.map((parameter: recordParameter) => {
             let found =
               validArguments
               |> Sequence.firstWhere((arg: LogicAst.functionCallArgument) =>
                    switch (arg) {
                    | Argument({label: Some(label)})
                        when label == parameter.name =>
                      true
                    | Argument(_) => false
                    | Placeholder(_) => false
                    }
                  );
             switch (found) {
             | Some(Argument({expression: value})) =>
               JavaScriptAst.Property({
                 key: Identifier([parameter.name]),
                 value: Some(expression(context, value)),
               })
             | Some(Placeholder(_))
             | None =>
               JavaScriptAst.Property({
                 key: Identifier([parameter.name]),
                 value: Some(expression(context, parameter.defaultValue)),
               })
             };
           }),
      )
    | None =>
      CallExpression({
        callee: expression(context, innerExpression),
        arguments:
          validArguments
          |> List.map((arg: LogicAst.functionCallArgument) => {
               let LogicAst.Argument({expression: innerExpression}) = arg;
               expression(context, innerExpression);
             }),
      })
    };
  | Placeholder(_) =>
    Js.log("Placeholder expression remaining");
    Empty;
  | _ =>
    Js.log("Unhandled expression type");
    Empty;
  }
and literal = (context: context, node: LogicAst.literal): JavaScriptAst.node =>
  switch (node) {
  | None(_) => Identifier(["null"])
  | Boolean({value}) => Literal(LonaValue.boolean(value))
  | Number({value}) => Literal(LonaValue.number(value))
  | String({value}) => StringLiteral(value)
  | Color({value}) => StringLiteral(value)
  | Array({value}) =>
    ArrayLiteral(value |> unfoldPairs |> List.map(expression(context)))
  };