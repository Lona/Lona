let evaluateFiles =
    (config: Config.t, logicFiles: list(Config.file(LogicAst.syntaxNode)))
    : option(LogicEvaluate.Context.t) => {
  let program =
    logicFiles
    |> List.map((file: Config.file(LogicAst.syntaxNode)) => file.contents)
    |> Sequence.compactMap(LogicUtils.makeProgram)
    |> LogicUtils.joinPrograms;
  let program =
    LogicUtils.joinPrograms([LogicUtils.standardImportsProgram, program]);
  let programNode =
    LogicAst.Program(
      Program(LogicUtils.resolveImports(config, program, ())),
    );
  let scopeContext = LogicScope.build(programNode, ());
  let unificationContext =
    LogicUnificationContext.makeUnificationContext(
      ~rootNode=programNode,
      ~scopeContext,
      (),
    );
  let substitution =
    LogicUnify.unify(~constraints=unificationContext.constraints^, ());

  /* Js.log("-- Namespace --");
     Js.log(LogicScope.namespaceDescription(scopeContext.namespace));

     Js.log("-- Unification --");
     Js.log(
       LogicUnificationContext.description(scopeContext, unificationContext),
     ); */

  let evaluationContext =
    LogicEvaluate.evaluate(
      ~currentNode=programNode,
      ~rootNode=programNode,
      ~scopeContext,
      ~unificationContext,
      ~substitution,
      (),
    );

  evaluationContext;
};