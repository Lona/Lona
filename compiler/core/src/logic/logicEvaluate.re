module Value = {
  type t = {
    type_: LogicUnify.t,
    memory,
  }
  and memory =
    | Unit
    | Bool(bool)
    | Number(float)
    | String(string)
    | Enum(string, list(t))
    | Record(Jet.Dictionary.t(string, option(t)))
    | Function(func)
  and func =
    | ColorSaturate
    | ColorSetHue
    | ColorSetSaturation
    | ColorSetLightness
    | ColorFromHSL
    | NumberRange
    | ArrayAt
    | StringConcat
    | RecordInit(Jet.Dictionary.t(string, (LogicUnify.t, option(t))))
    | EnumInit(string);
};

module Thunk = {
  type t = {
    label: string,
    dependencies: list(string),
    f: list(Value.t) => Value.t,
  };
};

module Context = {
  type t = {
    values: Jet.Dictionary.t(string, Value.t),
    thunks: Jet.Dictionary.t(string, Thunk.t),
  };

  let empty = () => {
    values: new Jet.Dictionary.t,
    thunks: new Jet.Dictionary.t,
  };
};

let evaluate =
    (
      node: LogicAst.syntaxNode,
      rootNode: LogicAst.syntaxNode,
      scopeContext: LogicScope.scopeContext,
    ) =>
  /* unificationContext:  */
  {};