open LogicProtocol;
open LogicUtils;
open Monad;

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

let rec convert =
        (
          config: Config.t,
          evaluationContext: LogicEvaluate.Context.t,
          node: LogicAst.syntaxNode,
        )
        : list(TokenTypes.token) => {
  let declarations =
    switch (node) {
    | LogicAst.Program(Program({block})) =>
      block
      |> unfoldPairs
      |> Sequence.rejectWhere(isPlaceholderStatement)
      |> Sequence.compactMap((statement: LogicAst.statement) =>
           switch (statement) {
           | Declaration({content: declaration}) => Some(declaration)
           | _ => None
           }
         )
    | LogicAst.TopLevelDeclarations(TopLevelDeclarations({declarations})) =>
      declarations
      |> unfoldPairs
      |> Sequence.rejectWhere(isPlaceholderDeclaration)
    | _ =>
      Log.warn("Unhandled top-level syntaxNode type");
      [];
    };
  declarations
  |> Sequence.compactMap((declaration: LogicAst.declaration) =>
       switch (declaration) {
       | Variable({name: Pattern({name}), initializer_: Some(initializer_)}) =>
         let logicValue =
           evaluationContext#evaluate(uuid(Expression(initializer_)));
         let tokenValue = logicValue >>= TokenValue.create;
         switch (tokenValue) {
         | Some(tokenValue) =>
           Some({TokenTypes.qualifiedName: [name], value: tokenValue})
         | None =>
           Log.warn("Failed to evaluate `" ++ name ++ "`");
           None;
         };
       | _ => None
       }
     );
};