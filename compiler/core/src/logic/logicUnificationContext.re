open LogicProtocol;
open Operators;

type t = {
  constraints: ref(list(LogicUnify.constraint_)),
  nodes: Jet.Dictionary.t(string, LogicUnify.t),
  patternTypes: Jet.Dictionary.t(string, LogicUnify.t),
  typeNameGenerator: LogicNameGenerator.t,
};

let makeEmptyContext = (): t => {
  constraints: ref([]),
  nodes: new Jet.Dictionary.t,
  patternTypes: new Jet.Dictionary.t,
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

let specificIdentifierType =
    (
      ~scopeContext: LogicScope.scopeContext,
      ~unificationContext: t,
      ~id: string,
    ) =>
  switch ((scopeContext.identifierToPattern)#get(id)) {
  | Some(patternId) =>
    switch ((unificationContext.patternTypes)#get(patternId)) {
    | Some(scopedType) =>
      LogicUnify.replaceGenericsWithEvars(
        (unificationContext.typeNameGenerator)#next,
        scopedType,
      )
    | None => Evar((unificationContext.typeNameGenerator)#next())
    }
  | None => Evar((unificationContext.typeNameGenerator)#next())
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
    | (
        false,
        Declaration(
          Enumeration({
            name: Pattern(functionName),
            genericParameters,
            cases: enumCases,
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
      let returnType = LogicUnify.Cons(functionName.name, universalTypes);

      enumCases
      |> LogicUtils.unfoldPairs
      |> List.iter((enumCase: LogicAst.enumerationCase) =>
           switch (enumCase) {
           | EnumerationCase({name: Pattern(pattern), associatedValueTypes}) =>
             let parameterTypes: list(LogicUnify.functionArgument) =
               associatedValueTypes
               |> LogicUtils.unfoldPairs
               |> Sequence.compactMap((annotation: LogicAst.typeAnnotation) =>
                    switch (annotation) {
                    | LogicAst.TypeIdentifier(_)
                    | LogicAst.FunctionType(_) =>
                      Some({
                        LogicUnify.label: None,
                        type_:
                          unificationType(
                            genericsInScope,
                            (result.typeNameGenerator)#next,
                            annotation,
                          ),
                      })
                    | Placeholder(_) => None
                    }
                  );

             let functionType = LogicUnify.Fun(parameterTypes, returnType);

             (result.nodes)#set(pattern.id, functionType);
             (result.patternTypes)#set(pattern.id, functionType);
           | Placeholder(_) => ()
           }
         );

      /* Not used for unification, but used for convenience in evaluation */
      (result.nodes)#set(functionName.id, returnType);
      (result.patternTypes)#set(functionName.id, returnType);
    | (
        false,
        Declaration(
          Function({
            name: Pattern(functionName),
            returnType: returnTypeAnnotation,
            genericParameters,
            parameters,
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

      let parameterTypes: ref(list(LogicUnify.functionArgument)) = ref([]);

      parameters
      |> LogicUtils.unfoldPairs
      |> List.iter((parameter: LogicAst.functionParameter) =>
           switch (parameter) {
           | LogicAst.Parameter({localName: Pattern(pattern), annotation}) =>
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

      let returnType =
        unificationType(
          genericsInScope,
          (result.typeNameGenerator)#next,
          returnTypeAnnotation,
        );
      let functionType = LogicUnify.Fun(parameterTypes^, returnType);

      (result.nodes)#set(functionName.id, functionType);
      (result.patternTypes)#set(functionName.id, functionType);
    | (true, Declaration(Variable({annotation: None})))
    | (true, Declaration(Variable({annotation: Some(Placeholder(_))})))
    | (true, Declaration(Variable({initializer_: None}))) =>
      config.ignoreChildren := true
    | (
        true,
        Declaration(
          Variable({
            name: Pattern(pattern),
            annotation: Some(annotation),
            initializer_: Some(initializer_),
          }),
        ),
      ) =>
      let annotationType =
        unificationType([], (result.typeNameGenerator)#next, annotation);

      let initializerId = uuid(Expression(initializer_));
      switch ((result.nodes)#get(initializerId)) {
      | Some(initializerType) =>
        result.constraints :=
          result.constraints^
          @ [{head: annotationType, tail: initializerType}]
      | None => Js.log("WARNING: No initializer type for " ++ initializerId)
      };

      (result.patternTypes)#set(pattern.id, annotationType);
    | (true, Expression(Placeholder(_))) =>
      let type_ = LogicUnify.Evar((result.typeNameGenerator)#next());

      (result.nodes)#set(uuid(node), type_);
    | (
        true,
        Expression(
          IdentifierExpression({identifier: Identifier(identifier)}),
        ),
      ) =>
      let type_ =
        specificIdentifierType(
          ~scopeContext,
          ~unificationContext=result,
          ~id=identifier.id,
        );

      (result.nodes)#set(uuid(node), type_);
      (result.nodes)#set(identifier.id, type_);
    | (true, Expression(FunctionCallExpression({expression, arguments}))) =>
      let calleeType = (result.nodes)#getExn(uuid(Expression(expression)));
      ();

      /* Unify against these to enforce a function type */

      let placeholderReturnType =
        LogicUnify.Evar((result.typeNameGenerator)#next());
      let placeholderArgTypes: list(LogicUnify.functionArgument) =
        arguments
        |> LogicUtils.unfoldPairs
        |> Sequence.compactMap((param: LogicAst.functionCallArgument) =>
             switch (param) {
             | Argument({label}) =>
               Some({
                 LogicUnify.label,
                 type_: LogicUnify.Evar((result.typeNameGenerator)#next()),
               })
             | Placeholder(_) => None
             }
           );

      ();
      let placeholderFunctionType: LogicUnify.t =
        Fun(placeholderArgTypes, placeholderReturnType);

      result.constraints :=
        result.constraints^
        @ [{head: calleeType, tail: placeholderFunctionType}];

      (result.nodes)#set(uuid(node), placeholderReturnType);

      let argumentValues: list(LogicAst.expression) =
        arguments
        |> LogicUtils.unfoldPairs
        |> Sequence.compactMap((param: LogicAst.functionCallArgument) =>
             switch (param) {
             | Argument({expression}) => Some(expression)
             | Placeholder(_) => None
             }
           );

      let constraints =
        List.combine(placeholderArgTypes, argumentValues)
        |> List.map(((argType: LogicUnify.functionArgument, argValue)) =>
             {
               LogicUnify.head: argType.type_,
               tail: (result.nodes)#getExn(uuid(Expression(argValue))),
             }
           );
      result.constraints := result.constraints^ @ constraints;
    | (false, Expression(MemberExpression(_))) =>
      config.ignoreChildren := true
    | (true, Expression(MemberExpression(_))) =>
      let type_ =
        specificIdentifierType(
          ~scopeContext,
          ~unificationContext=result,
          ~id=uuid(node),
        );

      (result.nodes)#set(uuid(node), type_);
    /* TODO: Binary expression */
    | (true, Literal(Boolean(_))) =>
      (result.nodes)#set(uuid(node), LogicUnify.bool)
    | (true, Literal(Number(_))) =>
      (result.nodes)#set(uuid(node), LogicUnify.number)
    | (true, Literal(String(_))) =>
      (result.nodes)#set(uuid(node), LogicUnify.string)
    | (true, Literal(Color(_))) =>
      (result.nodes)#set(uuid(node), LogicUnify.color)
    | (true, Literal(Array({value: expressions}))) =>
      let elementType: LogicUnify.t = Evar((result.typeNameGenerator)#next());
      (result.nodes)#set(uuid(node), elementType);

      let constraints =
        expressions
        |> LogicUtils.unfoldPairs
        |> List.map(expression => {
             let expressionType =
               (result.nodes)#get(uuid(Expression(expression)))
               %? Evar((result.typeNameGenerator)#next());
             {LogicUnify.head: elementType, tail: expressionType};
           });

      result.constraints := result.constraints^ @ constraints;
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