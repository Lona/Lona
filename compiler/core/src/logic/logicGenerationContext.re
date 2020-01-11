type t = {
  config: Config.t,
  isStatic: bool,
  isTopLevel: bool,
  rootNode: LogicAst.syntaxNode,
  resolvedRootNode: LogicAst.syntaxNode,
  scopeContext: LogicScope.scopeContext,
  unificationContext: LogicUnificationContext.t,
  substitution: LogicUnify.substitution,
  evaluationContext: option(LogicEvaluate.Context.t),
};