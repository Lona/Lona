open Jet;
open LogicProtocol;

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
    | Array(list(t))
    | Enum(string, list(t))
    | Record(Dictionary.t(string, option(t)))
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
    | RecordInit(Dictionary.t(string, (LogicUnify.t, option(t))))
    | EnumInit(string);

  let unit: t = {type_: LogicUnify.unit, memory: Unit};
  let bool = value: t => {type_: LogicUnify.bool, memory: Bool(value)};
  let number = value: t => {type_: LogicUnify.number, memory: Number(value)};
  let string = value: t => {type_: LogicUnify.string, memory: String(value)};
  let color = (value: string): t => {
    type_: LogicUnify.color,
    memory: Record(Dictionary.init([("value", Some(string(value)))])),
  };
  let optional = (value: t): t => {
    type_: LogicUnify.color,
    memory: Record(Dictionary.init([("value", Some(value))])),
  };
  let unwrapOptional = (value: t): option(t) =>
    switch (value) {
    | {type_: Cons("Optional", _), memory: Enum("value", values)} =>
      Some(List.hd(values))
    | _ => None
    };
};

module Thunk = {
  type t = {
    label: string,
    dependencies: list(string),
    f: list(Value.t) => Value.t,
  };
};

module Context = {
  class t = {
    as self;
    val mutable values: Dictionary.t(string, Value.t) = new Dictionary.t;
    val mutable thunks: Dictionary.t(string, Thunk.t) = new Dictionary.t;
    pub values = values;
    pub thunks = thunks;
    /* Methods */
    pub add = (uuid: string, thunk: Thunk.t) => thunks#set(uuid, thunk);
    pub evaluate = (uuid: string): option(Value.t) =>
      switch (self#values#get(uuid)) {
      | Some(value) => Some(value)
      | None =>
        switch (self#thunks#get(uuid)) {
        | Some((thunk: Thunk.t)) =>
          let resolvedDependencies =
            thunk.dependencies |> List.map(dep => self#evaluate(dep));
          if (resolvedDependencies |> List.exists(dep => dep == None)) {
            Js.log("Failed to evaluate thunk - missing deps");
            None;
          } else {
            let result = thunk.f(resolvedDependencies |> Sequence.compact);
            values#set(uuid, result);
            Some(result);
          };
        | None => None
        }
      };
  };
};

let evaluate =
    (
      node: LogicAst.syntaxNode,
      rootNode: LogicAst.syntaxNode,
      scopeContext: LogicScope.scopeContext,
      unificationContext: LogicUnificationContext.t,
      substitution: LogicUnify.substitution,
      context: Context.t,
    )
    : option(Context.t) => {
  /* TODO: handle statements */
  switch (node) {
  | Literal(Boolean({value})) =>
    context#add(
      uuid(node),
      {
        label: "Boolean Literal",
        dependencies: [],
        f: _ => Value.bool(value),
      },
    )
  | Literal(Number({value})) =>
    context#add(
      uuid(node),
      {
        label: "Number Literal",
        dependencies: [],
        f: _ => Value.number(value),
      },
    )
  | Literal(String({value})) =>
    context#add(
      uuid(node),
      {
        label: "String Literal",
        dependencies: [],
        f: _ => Value.string(value),
      },
    )
  | Literal(Color({value})) =>
    context#add(
      uuid(node),
      {label: "Color Literal", dependencies: [], f: _ => Value.color(value)},
    )
  | Literal(Array({value: expressions})) =>
    let type_ = (unificationContext.nodes)#get(uuid(node));

    switch (type_) {
    | None => Js.log("Failed to unify type of array")
    | Some(type_) =>
      let resolvedType = LogicUnify.substitute(substitution, type_);
      let dependencies =
        expressions
        |> LogicUtils.unfoldPairs
        |> Sequence.rejectWhere(LogicUtils.isPlaceholderExpression)
        |> List.map(expression => uuid(Expression(expression)));

      context#add(
        uuid(node),
        {
          label: "Array Literal",
          dependencies,
          f: values => {type_: resolvedType, memory: Array(values)},
        },
      );
    };
  | Expression(LiteralExpression({literal})) =>
    context#add(
      uuid(node),
      {
        label: "Literal expression",
        dependencies: [uuid(Literal(literal))],
        f: values => List.hd(values),
      },
    )
  | Expression(IdentifierExpression({identifier: Identifier({id, string})})) =>
    let patternId = (scopeContext.identifierToPattern)#get(id);

    switch (patternId) {
    | Some(patternId) =>
      context#add(
        id,
        {
          label: "Identifier " ++ string,
          dependencies: [patternId],
          f: values => List.hd(values),
        },
      );
      context#add(
        uuid(node),
        {
          label: "Identifier expression " ++ string,
          dependencies: [patternId],
          f: values => List.hd(values),
        },
      );
    | None => ()
    };
  | _ => ()
  };

  Some(context);
};