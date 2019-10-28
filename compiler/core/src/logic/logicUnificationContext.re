open LogicProtocol;

type t = {
  constraints: list(LogicUnify.constraint_),
  nodes: Jet.dictionary(string, LogicUnify.t),
  patternTypes: Jet.dictionary(string, LogicUnify.t),
  typeNameGenerator: LogicNameGenerator.t,
};

let makeEmptyContext = (): t => {
  constraints: [],
  nodes: new Jet.dictionary,
  patternTypes: new Jet.dictionary,
  typeNameGenerator: (new LogicNameGenerator.t)("?"),
};

let rec unificationType =
        (
          genericsInScope: list((string, string)),
          getName: unit => string,
          typeAnnotation: LogicAst.typeAnnotation,
        )
        : LogicUnify.t =>
  switch (typeAnnotation) {
  | TypeIdentifier({
      identifier: Identifier({string, isPlaceholder}),
      genericArguments,
    }) =>
    if (isPlaceholder) {
      LogicUnify.Evar(getName());
    } else if (List.mem_assoc(string, genericsInScope)) {
      LogicUnify.Gen(List.assoc(string, genericsInScope));
    } else {
      let parameters =
        genericArguments
        |> LogicUtils.unfoldPairs
        |> List.map(arg => unificationType(genericsInScope, getName, arg));
      LogicUnify.Cons(string, parameters);
    }
  | Placeholder(_) => LogicUnify.Evar(getName())
  | FunctionType(_) => LogicUnify.Evar("Function type error")
  };

let makeUnificationContext =
    (
      ~rootNode: LogicAst.syntaxNode,
      ~scopeContext: LogicScope.scopeContext,
      ~initialContext: t=makeEmptyContext(),
      (),
    )
    : t => {
  let build =
      (
        result: t,
        node: LogicAst.syntaxNode,
        config: LogicTraversal.traversalConfig,
      )
      : t => {
    config.needsRevisitAfterTraversingChildren := true;

    switch (config._isRevisit^, node) {
    | (true, Statement(Branch({condition}))) =>
      (result.nodes)#set(uuid(Expression(condition)), LogicUnify.bool)
    | (
        false,
        Declaration(
          Record({
            name: Pattern(functionName),
            genericParameters,
            declarations,
          }),
        ),
      ) =>
      let genericNames: list(string) =
        genericParameters
        |> LogicUtils.unfoldPairs
        |> Sequence.compactMap((param: LogicAst.genericParameter) =>
             switch (param) {
             | Parameter({name: Pattern({name: patternName})}) =>
               Some(patternName)
             | Placeholder(_) => None
             }
           );
      let genericsInScope =
        genericNames
        |> List.map(name => (name, (result.typeNameGenerator)#next()));
      let universalTypes =
        genericNames
        |> List.map(name =>
             LogicUnify.Gen(List.assoc(name, genericsInScope))
           );
      let parameterTypes: ref(list(LogicUnify.functionArgument)) = ref([]);

      declarations
      |> LogicUtils.unfoldPairs
      |> List.iter(declaration =>
           switch (declaration) {
           | LogicAst.Variable({
               name: Pattern(pattern),
               annotation: Some(annotation),
             }) =>
             let annotationType =
               annotation
               |> unificationType([], (result.typeNameGenerator)#next);
             parameterTypes :=
               [
                 {label: Some(pattern.name), type_: annotationType},
                 ...parameterTypes^,
               ];

             (result.nodes)#set(pattern.id, annotationType);
             (result.patternTypes)#set(pattern.id, annotationType);
           | _ => ()
           }
         );

      let returnType = LogicUnify.Cons(functionName.name, universalTypes);
      let functionType = LogicUnify.Fun(parameterTypes^, returnType);

      (result.nodes)#set(functionName.id, functionType);
      (result.patternTypes)#set(functionName.id, functionType);
    | _ => ()
    };

    result;
  };

  let result =
    rootNode
    |> LogicTraversal.reduce(
         LogicTraversal.emptyConfig(),
         initialContext,
         build,
       );

  result;
};