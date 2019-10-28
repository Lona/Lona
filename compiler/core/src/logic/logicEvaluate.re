type func =
  | ColorSaturate
  | ColorSetHue
  | ColorSetSaturation
  | ColorSetLightness
  | ColorFromHSL
  | NumberRange
  | ArrayAt
  | StringConcat
  | EnumInit(string)
/* | RecordInit(members: KeyValueList<String, (Unification.T, LogicValue?)>) */
and recordMember = {
  key: string,
  value: option(value),
}
and memory =
  | Unit
  | Bool(bool)
  | Number(float)
  | String(string)
  | Enum(string, list(value))
  | Record(list(recordMember))
  | Function(func)
and value = {
  type_: string,
  memory,
};

type thunk = {
  label: string,
  dependencies: list(string),
  f: value => value,
};

let evaluate =
    (
      node: LogicAst.syntaxNode,
      rootNode: LogicAst.syntaxNode,
      scopeContext: LogicScope.scopeContext,
    ) =>
  /* unificationContext:  */
  {};