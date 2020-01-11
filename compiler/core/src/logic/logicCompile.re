let makeResolvedProgramNode =
    (
      libraryFiles: list(Config.file(LogicAst.syntaxNode)),
      logicFiles: list(Config.file(LogicAst.syntaxNode)),
    )
    : LogicAst.syntaxNode => {
  let program =
    logicFiles
    |> List.map((file: Config.file(LogicAst.syntaxNode)) => file.contents)
    |> Sequence.compactMap(LogicUtils.makeProgram)
    |> LogicUtils.joinPrograms;
  let program =
    LogicUtils.joinPrograms([LogicUtils.standardImportsProgram, program]);

  LogicAst.Program(
    Program(LogicUtils.resolveImports(libraryFiles, program, ())),
  );
};

let evaluate =
    (
      libraryFiles: list(Config.file(LogicAst.syntaxNode)),
      logicFiles: list(Config.file(LogicAst.syntaxNode)),
    )
    : option(LogicEvaluate.Context.t) => {
  let programNode = makeResolvedProgramNode(libraryFiles, logicFiles);
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