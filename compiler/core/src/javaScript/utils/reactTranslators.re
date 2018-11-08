module Ast = JavaScriptAst;

let isUnitNumberParameter = (framework, key) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM =>
    ReactDomTranslators.isUnitNumberParameter(key)
  | _ => false
  };

let variableNames = (framework, variable) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM => ReactDomTranslators.variableNames(variable)
  | JavaScriptOptions.ReactSketchapp
  | JavaScriptOptions.ReactNative =>
    ReactNativeTranslators.variableNames(variable)
  | _ => variable |> ParameterKey.toString
  };

let convertUnitlessAstNode =
    (framework: JavaScriptOptions.framework, value: Ast.node) =>
  switch (framework) {
  | JavaScriptOptions.ReactDOM =>
    switch (value) {
    | Ast.Identifier(path) =>
      Ast.BinaryExpression({
        left: Ast.Identifier(path),
        operator: Ast.Plus,
        right: Ast.StringLiteral(ReactDomTranslators.styleUnit),
      })
    | Ast.Literal(lonaValue) =>
      Ast.Literal(
        LonaValue.string(
          ReactDomTranslators.convertUnitlessStyle(lonaValue.data),
        ),
      )
    | x => x
    }
  | _ => value
  };