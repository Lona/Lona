open Jet;
open LogicProtocol;
open Monad;

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
    | Record(recordMembers)
    | Function(func)
  and recordMembers = Dictionary.t(string, option(t))
  and recordInit = Dictionary.t(string, (LogicUnify.t, option(t)))
  and func =
    | Path(list(string))
    | RecordInit(recordInit)
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

  let rec valueDescription = (value: t): string => {
    let {type_, memory} = value;
    "[ "
    ++ memoryDescription(memory)
    ++ ": $"
    ++ LogicUnify.typeDescription(type_)
    ++ " ]";
  }
  and memoryDescription = (memory: memory): string =>
    switch (memory) {
    | Unit => "Unit"
    | Bool(bool) => "Bool(" ++ string_of_bool(bool) ++ ")"
    | Number(float) => "Number(" ++ string_of_float(float) ++ ")"
    | String(string) => "String(" ++ string ++ ")"
    | Array(values) =>
      "Array("
      ++ (values |> List.map(valueDescription) |> Format.joinWith(", "))
      ++ ")"
    | Enum(string, associatedValues) =>
      "Enum("
      ++ string
      ++ (
        associatedValues
        |> List.map(valueDescription)
        |> Format.joinWith(", ")
      )
      ++ ")"
    | Record(members) =>
      "Record("
      ++ (
        members#pairs()
        |> List.map(((k, v)) =>
             k
             ++ ": "
             ++ (
               switch (v) {
               | Some(v) => valueDescription(v)
               | None => "_"
               }
             )
           )
        |> Format.joinWith(", ")
      )
      ++ ")"
    | Function(func) => "func"
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
          /* Js.log2("Evaluating", thunk.label); */
          switch (
            resolvedDependencies
            |> Sequence.firstIndexWhere(dep => dep == None)
          ) {
          | Some(index) =>
            Js.log(
              "Failed to evaluate thunk - missing dep "
              ++ List.nth(thunk.dependencies, index),
            );
            None;
          | None =>
            let result = thunk.f(resolvedDependencies |> Sequence.compact);
            values#set(uuid, result);
            Some(result);
          };
        | None =>
          Js.log("No thunk for " ++ uuid);
          None;
        }
      };
  };

  let makeEmpty = () => new t;
};

let rec evaluate =
        (
          ~currentNode as node: LogicAst.syntaxNode,
          ~rootNode: LogicAst.syntaxNode,
          ~scopeContext: LogicScope.scopeContext,
          ~unificationContext: LogicUnificationContext.t,
          ~substitution: LogicUnify.substitution,
          ~context: Context.t=Context.makeEmpty(),
          (),
        )
        : option(Context.t) => {
  let result =
    subnodes(node)
    |> List.fold_left(
         (result, subnode) =>
           switch (result) {
           | Some(result) =>
             evaluate(
               ~currentNode=subnode,
               ~rootNode,
               ~scopeContext,
               ~unificationContext,
               ~substitution,
               ~context=result,
               (),
             )
           | None => None
           },
         Some(context),
       );
  switch (result) {
  | Some(context) =>
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
        {
          label: "Color Literal",
          dependencies: [],
          f: _ => Value.color(value),
        },
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
    | Expression(
        IdentifierExpression({identifier: Identifier({id, string})}),
      ) =>
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
            label: "IdentifierExpression " ++ string,
            dependencies: [patternId],
            f: values => List.hd(values),
          },
        );
      | None =>
        /* Js.log(
             "Failed to find declaration (pattern) for identifier `"
             ++ string
             ++ "` ("
             ++ id
             ++ ")",
           ); */
        ()
      };
    | Expression(MemberExpression(_)) =>
      let patternId = (scopeContext.identifierToPattern)#get(uuid(node));

      switch (patternId) {
      | Some(patternId) =>
        context#add(
          uuid(node),
          {
            label: "Member expression",
            dependencies: [patternId],
            f: values => List.hd(values),
          },
        )
      | None => ()
      };
    | Expression(BinaryExpression(_)) => Js.log("TODO: Binary Expression")
    | Expression(FunctionCallExpression({expression, arguments})) =>
      let functionType =
        (unificationContext.nodes)#get(uuid(Expression(expression)));
      switch (functionType) {
      | None => Js.log("Unknown type of functionCallExpression")
      | Some(functionType) =>
        let resolvedType = LogicUnify.substitute(substitution, functionType);
        switch (resolvedType) {
        | Evar(_)
        | Gen(_)
        | Cons(_) =>
          Js.log(
            "Invalid functionCallExpression type (only functions are valid): "
            ++ LogicUnify.typeDescription(resolvedType),
          )
        | Fun(_, returnType) =>
          let dependencies =
            [uuid(Expression(expression))]
            @ (
              arguments
              |> LogicUtils.unfoldPairs
              |> Sequence.compactMap((arg: LogicAst.functionCallArgument) =>
                   switch (arg) {
                   | Argument({
                       expression:
                         IdentifierExpression({
                           identifier: Identifier({isPlaceholder: true}),
                         }),
                     }) =>
                     None
                   | Argument({expression}) =>
                     Some(uuid(Expression(expression)))
                   | Placeholder(_) => None
                   }
                 )
            );
          context#add(
            uuid(node),
            {
              label: "FunctionCallExpression",
              dependencies,
              f: values => {
                let [functionValue, ...args] = values;
                switch (functionValue.memory) {
                | Function(EnumInit(patternName)) => {
                    type_: returnType,
                    memory: Enum(patternName, args),
                  }
                | Function(RecordInit(members)) =>
                  let members: list((string, option(Value.t))) =
                    members#pairs()
                    |> List.map(((key, value)) => {
                         let arg =
                           arguments
                           |> LogicUtils.unfoldPairs
                           |> Sequence.firstWhere(
                                (arg: LogicAst.functionCallArgument) =>
                                switch (arg) {
                                | Argument({label: Some(label)})
                                    when key == label =>
                                  true
                                | Argument(_)
                                | Placeholder(_) => false
                                }
                              );
                         let argumentValue =
                           arg
                           >>= (
                             (arg: LogicAst.functionCallArgument) =>
                               switch (arg) {
                               | Argument({
                                   expression:
                                     IdentifierExpression({
                                       identifier:
                                         Identifier({isPlaceholder: true}),
                                     }),
                                 }) =>
                                 None
                               | Argument({expression}) =>
                                 let dependencyIndex =
                                   dependencies
                                   |> Sequence.firstIndexMem(
                                        uuid(Expression(expression)),
                                      );
                                 switch (dependencyIndex) {
                                 | Some(dependencyIndex) =>
                                   let x =
                                     Some(List.nth(values, dependencyIndex));
                                   x;
                                 | None => None
                                 };
                               | Placeholder(_) => None
                               }
                           );
                         switch (argumentValue) {
                         | Some(argumentValue) => (key, Some(argumentValue))
                         | None =>
                           let (_, argumentValue) = value;
                           (key, argumentValue);
                         };
                       });
                  {
                    type_: returnType,
                    memory: Record(Dictionary.init(members)),
                  };
                | _ => Value.unit
                };
              },
            },
          );
        };
      };

    | Declaration(
        Variable({
          name: Pattern(pattern),
          initializer_: Some(initializer_),
        }),
      ) =>
      context#add(
        pattern.id,
        {
          label: "Variable initializer for " ++ pattern.name,
          dependencies: [uuid(Expression(initializer_))],
          f: values => List.hd(values),
        },
      )
    | Declaration(Function({name: Pattern(pattern)})) =>
      let type_ = (unificationContext.patternTypes)#get(pattern.id);
      let fullPath = declarationPathTo(rootNode, uuid(node));

      switch (type_) {
      | Some(type_) =>
        context#add(
          pattern.id,
          {
            label: "Function declaration for " ++ pattern.name,
            dependencies: [],
            f: _ => {type_, memory: Function(Path(fullPath))},
          },
        )
      | None => Js.log("Unknown function type")
      };
    | Declaration(Record({name: Pattern(functionName), declarations})) =>
      let type_ = (unificationContext.patternTypes)#get(functionName.id);

      switch (type_) {
      | Some(type_) =>
        let resolvedType = LogicUnify.substitute(substitution, type_);

        let dependencies =
          declarations
          |> LogicUtils.unfoldPairs
          |> Sequence.compactMap((declaration: LogicAst.declaration) =>
               switch (declaration) {
               | Variable({initializer_: Some(initializer_)}) =>
                 Some(uuid(Expression(initializer_)))
               | _ => None
               }
             );

        context#add(
          functionName.id,
          {
            label: "Record declaration for " ++ functionName.name,
            dependencies,
            f: values => {
              let parameterTypes: Value.recordInit = new Dictionary.t;

              let index: ref(int) = ref(0);

              declarations
              |> LogicUtils.unfoldPairs
              |> List.iter((declaration: LogicAst.declaration) =>
                   switch (declaration) {
                   | Variable({name: Pattern(pattern), initializer_}) =>
                     let parameterType =
                       (unificationContext.patternTypes)#get(pattern.id);

                     switch (parameterType) {
                     | Some(parameterType) =>
                       let initialValue =
                         switch (initializer_) {
                         | Some(_) =>
                           let value = Some(List.nth(values, index^));
                           index := index^ + 1;
                           value;
                         | None => None
                         };

                       parameterTypes#set(
                         pattern.name,
                         (parameterType, initialValue),
                       );
                     | None => ()
                     };
                   | _ => ()
                   }
                 );

              {
                type_: resolvedType,
                memory: Function(RecordInit(parameterTypes)),
              };
            },
          },
        );
      | None => Js.log("Unknown record type")
      };
    | Declaration(
        Enumeration({name: Pattern(functionName), cases: enumCases}),
      ) =>
      let type_ = (unificationContext.patternTypes)#get(functionName.id);

      switch (type_) {
      | Some(type_) =>
        enumCases
        |> LogicUtils.unfoldPairs
        |> List.iter((enumCase: LogicAst.enumerationCase) =>
             switch (enumCase) {
             | EnumerationCase({name: Pattern(pattern)}) =>
               let resolvedConsType =
                 LogicUnify.substitute(substitution, type_);
               context#add(
                 pattern.id,
                 {
                   label: "Enum case declaration for " ++ pattern.name,
                   dependencies: [],
                   f: _ => {
                     type_: resolvedConsType,
                     memory: Function(EnumInit(pattern.name)),
                   },
                 },
               );
             | _ => ()
             }
           )
      | None => Js.log("Unknown record type")
      };
    | _ => ()
    };

    Some(context);
  | None => None
  };
};