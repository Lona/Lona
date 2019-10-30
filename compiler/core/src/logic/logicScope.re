open Jet;

type uuid = string;

type scopeContext = {
  namespace: Dictionary.t(list(string), uuid),
  currentNamespacePath: ref(list(string)),
  /* Values in these are never removed, even if a variable is out of scope */
  patternToName: Dictionary.t(uuid, string),
  identifierToPattern: Dictionary.t(uuid, uuid),
  patternToTypeName: Dictionary.t(uuid, string),
  /* This keeps track of the current scope */
  patternNames: scopeStack(string, uuid),
};

let namespaceDescription = (namespace: Dictionary.t(list(string), uuid)) =>
  namespace#keys()
  |> List.map(qualifiedName => Format.joinWith(".", qualifiedName))
  |> Format.joinWith("\n");

let pushNamespace = (name, context: scopeContext) =>
  context.currentNamespacePath := context.currentNamespacePath^ @ [name];

let popNamespace = (context: scopeContext) => {
  let [_, ...rest] = List.rev(context.currentNamespacePath^);
  context.currentNamespacePath := List.rev(rest);
};

let setInCurrentNamespace = (name, value, context: scopeContext) =>
  (context.namespace)#set(context.currentNamespacePath^ @ [name], value);

let setGenericParameters = (genericParameters, context: scopeContext) =>
  genericParameters
  |> LogicUtils.unfoldPairs
  |> List.iter((genericParameter: LogicAst.genericParameter) =>
       switch (genericParameter) {
       | Placeholder(_) => ()
       | Parameter({
           name:
             Pattern({id: genericParameterId, name: genericParameterName}),
         }) =>
         (context.patternToTypeName)#set(
           genericParameterId,
           genericParameterName,
         )
       }
     );

let empty = (): scopeContext => {
  namespace: new Dictionary.t,
  currentNamespacePath: ref([]),
  patternToName: new Dictionary.t,
  identifierToPattern: new Dictionary.t,
  patternToTypeName: new Dictionary.t,
  patternNames: new scopeStack,
};

let builtInTypeConstructorNames = [
  "Boolean",
  "Number",
  "String",
  "Array",
  "Color",
];

let build =
    (
      rootNode: LogicAst.syntaxNode,
      ~targetId: option(string)=None,
      ~initialContext: scopeContext=empty(),
      (),
    )
    : scopeContext => {
  let config = LogicTraversal.emptyConfig();

  let namespaceDeclarations =
      (context, node, config: LogicTraversal.traversalConfig) => {
    config.needsRevisitAfterTraversingChildren := true;

    switch (config._isRevisit^, node) {
    | (
        true,
        LogicAst.Declaration(
          Variable({name: Pattern({id: patternId, name: patternName})}),
        ),
      ) =>
      setInCurrentNamespace(patternName, patternId, context)

    | (
        true,
        Declaration(
          Function({name: Pattern({id: patternId, name: patternName})}),
        ),
      ) =>
      setInCurrentNamespace(patternName, patternId, context)

    | (false, Declaration(Record(_))) =>
      /* Avoid introducing member variables into the namespace */
      config.ignoreChildren := true
    | (
        true,
        Declaration(
          Record({name: Pattern({id: patternId, name: patternName})}),
        ),
      ) =>
      /* Built-ins should be constructed using literals */
      if (!List.mem(patternName, builtInTypeConstructorNames)) {
        /* Create constructor function */
        setInCurrentNamespace(
          patternName,
          patternId,
          context,
        );
      }
    | (
        true,
        Declaration(
          Enumeration({name: Pattern({name: patternName}), cases}),
        ),
      ) =>
      pushNamespace(patternName, context);

      /* Add initializers for each case into the namespace */
      cases
      |> LogicUtils.unfoldPairs
      |> List.iter((enumCase: LogicAst.enumerationCase) =>
           switch (enumCase) {
           | EnumerationCase({name: Pattern({id: caseId, name: caseName})}) =>
             setInCurrentNamespace(caseName, caseId, context)
           | Placeholder(_) => ()
           }
         );

      popNamespace(context);
    | (false, Declaration(Namespace({name: Pattern({name: patternName})}))) =>
      pushNamespace(patternName, context)
    | (true, Declaration(Namespace(_))) => popNamespace(context)
    | _ => ()
    };

    context;
  };

  let rec walk = (context, node, config: LogicTraversal.traversalConfig) => {
    0 |> ignore; /* To keep line, for debugging */
    if (Some(LogicProtocol.uuid(node)) == targetId) {
      config.stopTraversal := true;
      context;
    } else {
      config.needsRevisitAfterTraversingChildren := true;

      switch (config._isRevisit^, node) {
      | (false, TypeAnnotation(_)) =>
        config.ignoreChildren := true;
        config.needsRevisitAfterTraversingChildren := false;
        context;
      | (true, Identifier(Identifier({id, string, isPlaceholder}))) =>
        if (isPlaceholder) {
          context;
        } else {
          let lookup = (context.patternNames)#get(string);
          switch (lookup) {
          | Some(value) => (context.identifierToPattern)#set(id, value)
          | None =>
            switch ((context.namespace)#get([string])) {
            | Some(patternId) =>
              (context.identifierToPattern)#set(id, patternId)
            | None =>
              switch (
                (context.namespace)#get(
                  context.currentNamespacePath^ @ [string],
                )
              ) {
              | Some(patternId) =>
                (context.identifierToPattern)#set(id, patternId)
              | None =>
                Js.log2("Failed to find pattern for identifier:", string);
                ();
              }
            }
          };
          context;
        }
      | (false, Expression(MemberExpression({id}) as expression)) =>
        config.ignoreChildren := true;

        switch (LogicProtocol.flattenedMemberExpression(expression)) {
        | Some(identifiers) =>
          let keyPath =
            identifiers
            |> List.map((identifier: LogicAst.identifier) =>
                 switch (identifier) {
                 | Identifier({string}) => string
                 }
               );
          switch ((context.namespace)#get(keyPath)) {
          | Some(patternId) =>
            (context.identifierToPattern)#set(id, patternId);
            context;
          | None => context
          };

        | None => context
        };
      | (true, Declaration(Variable({name: Pattern({id, name})}))) =>
        (context.patternToName)#set(id, name);
        (context.patternNames)#set(name, id);

        /* setInCurrentNamespace(name, id, context); */

        context;
      | (
          false,
          Declaration(
            Function({
              name: Pattern({id: functionId, name: functionName}),
              parameters,
              genericParameters,
            }),
          ),
        ) =>
        (context.patternToName)#set(functionId, functionName);
        (context.patternNames)#set(functionName, functionId);
        (context.patternNames)#push();
        /* setInCurrentNamespace(functionName, functionId, context); */

        parameters
        |> LogicUtils.unfoldPairs
        |> List.iter((parameter: LogicAst.functionParameter) =>
             switch (parameter) {
             | Placeholder(_) => ()
             | Parameter({
                 localName: Pattern({id: parameterId, name: parameterName}),
               }) =>
               (context.patternToName)#set(parameterId, parameterName);
               (context.patternNames)#set(parameterName, parameterId);
             }
           );

        setGenericParameters(genericParameters, context);

        context;
      | (true, Declaration(Function(_))) =>
        let _ = (context.patternNames)#pop();

        context;
      | (
          false,
          Declaration(
            Record({
              name: Pattern({id: functionId, name: functionName}),
              genericParameters,
              declarations,
            }),
          ),
        ) =>
        (context.patternToTypeName)#set(functionId, functionName);

        setGenericParameters(genericParameters, context);

        declarations
        |> LogicUtils.unfoldPairs
        |> List.iter((declaration: LogicAst.declaration) =>
             switch (declaration) {
             | Variable({initializer_: Some(expression)}) =>
               let _ =
                 LogicAst.Expression(expression)
                 |> LogicTraversal.reduce(config, context, walk);
               ();
             | _ => ()
             }
           );

        config.ignoreChildren := true;

        context;
      | (true, Declaration(Record({name: Pattern({id, name})}))) =>
        if (List.mem(name, builtInTypeConstructorNames)) {
          context;
        } else {
          (context.patternToName)#set(id, name);
          (context.patternNames)#set(name, id);

          /* setInCurrentNamespace(name, id, context); */

          context;
        }
      | (
          false,
          Declaration(
            Enumeration({
              name: Pattern({id: functionId, name: functionName}),
              genericParameters,
            }),
          ),
        ) =>
        (context.patternToTypeName)#set(functionId, functionName);

        setGenericParameters(genericParameters, context);

        context;
      | (
          true,
          Declaration(
            Enumeration({
              name: Pattern({name: functionName}),
              genericParameters,
            }),
          ),
        ) =>
        pushNamespace(functionName, context);

        /* Add initializers for each case into the namespace */
        /* cases
           |> LogicUtils.unfoldPairs
           |> List.iter((case: LogicAst.enumerationCase) =>
                switch (case) {
                | Placeholder(_) => ()
                | EnumerationCase({name: Pattern({id: caseId, name: caseName})}) =>
                  setInCurrentNamespace(caseName, caseId, context)
                }
              ); */

        setGenericParameters(genericParameters, context);

        popNamespace(context);

        context;
      | (false, Declaration(Namespace({name: Pattern({name})}))) =>
        (context.patternNames)#push();
        pushNamespace(name, context);

        context;
      | (true, Declaration(Namespace(_))) =>
        let _ = (context.patternNames)#pop();
        popNamespace(context);

        context;
      | _ => context
      };
    };
  };

  let contextWithNamespaceDeclarations =
    rootNode
    |> LogicTraversal.reduce(config, initialContext, namespaceDeclarations);

  rootNode
  |> LogicTraversal.reduce(config, contextWithNamespaceDeclarations, walk);
};