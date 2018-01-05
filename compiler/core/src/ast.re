module Swift = {
  type accessLevelModifier =
    | PrivateModifier
    | FileprivateModifier
    | InternalModifier
    | PublicModifier
    | OpenModifier;
  type mutationModifier =
    | MutatingModifier
    | NonmutatingModifier;
  type declarationModifier =
    | ClassModifier
    | ConvenienceModifier
    | DynamicModifier
    | FinalModifier
    | InfixModifier
    | LazyModifier
    | OptionalModifier
    | OverrideModifier
    | PostfixModifier
    | PrefixModifier
    | RequiredModifier
    | StaticModifier
    | UnownedModifier
    | UnownedSafeModifier
    | UnownedUnsafeModifier
    | WeakModifier
    | AccessLevelModifier(accessLevelModifier)
    | MutationModifier(mutationModifier);
  type literal =
    | Nil
    | Boolean(bool)
    | Integer(int)
    | FloatingPoint(float)
    | String(string)
    | Color(string)
  and typeAnnotation =
    | TypeName(string)
    | TypeIdentifier({. "name": typeAnnotation, "member": typeAnnotation})
    | ArrayType({. "element": typeAnnotation})
    | DictionaryType({. "key": typeAnnotation, "value": typeAnnotation})
    | OptionalType({. "value": typeAnnotation})
    | TypeInheritanceList({. "list": list(typeAnnotation)})
  and pattern =
    | WildcardPattern
    | IdentifierPattern(string)
    | ValueBindingPattern({. "kind": string, "pattern": pattern})
    | TuplePattern({. "elements": list(pattern)})
    | OptionalPattern({. "value": pattern})
    | ExpressionPattern({. "value": node})
  /* | IsPattern */
  /* | AsPattern */
  and node =
    /* | Operator(string) */
    | LiteralExpression(literal)
    | ClassDeclaration({. "name": string, "body": list(node)})
    /* | VariableDeclaration({. "pattern": pattern, "init": option(node)}) */
    | SwiftIdentifier(string)
    | ConstantDeclaration(
        {. "modifiers": list(declarationModifier), "pattern": pattern, "init": option(node)}
      )
    | ImportDeclaration(string)
    | FunctionCallArgument({. "name": option(node), "value": node})
    | FunctionCallExpression({. "name": node, "arguments": list(node)})
    | LineComment({. "comment": string, "line": node})
    | TopLevelDeclaration({. "statements": list(node)});
};

module JavaScript = {
  type binaryOperator =
    | Eq
    | Neq
    | Gt
    | Gte
    | Lt
    | Lte
    | Plus
    | Noop;
  type node =
    | Return(node)
    | Literal(Types.lonaValue)
    | Identifier(list(string))
    | Class(string, option(string), list(node))
    | Method(string, list(string), list(node))
    | CallExpression(node, list(node))
    | JSXAttribute(string, node)
    | JSXElement(string, list(node), list(node))
    | VariableDeclaration(node)
    | AssignmentExpression(node, node)
    | BooleanExpression(node, binaryOperator, node)
    | ConditionalStatement(node, list(node))
    | ArrayLiteral(list(node))
    | ObjectLiteral(list(node))
    | ObjectProperty(node, node)
    | Block(list(node))
    | Program(list(node))
    | Unknown;
  /* Children are mapped first */
  let rec map = (f, node) =>
    switch node {
    | Return(value) => f(Return(value |> map(f)))
    | Literal(_) => f(node)
    | Identifier(_) => f(node)
    | Class(a, b, body) => f(Class(a, b, body |> List.map(map(f))))
    | Method(a, b, body) => f(Method(a, b, body |> List.map(map(f))))
    | CallExpression(value, body) => f(CallExpression(value |> map(f), body |> List.map(map(f))))
    | JSXAttribute(a, value) => f(JSXAttribute(a, value |> map(f)))
    | JSXElement(a, attributes, body) =>
      f(JSXElement(a, attributes |> List.map(map(f)), body |> List.map(map(f))))
    | VariableDeclaration(value) => f(VariableDeclaration(value |> map(f)))
    | AssignmentExpression(value1, value2) =>
      f(AssignmentExpression(value1 |> map(f), value2 |> map(f)))
    | BooleanExpression(value1, a, value2) =>
      f(BooleanExpression(value1 |> map(f), a, value2 |> map(f)))
    | ConditionalStatement(condition, body) =>
      f(ConditionalStatement(condition |> map(f), body |> List.map(map(f))))
    | ArrayLiteral(body) => f(ArrayLiteral(body |> List.map(map(f))))
    | ObjectLiteral(body) => f(ObjectLiteral(body |> List.map(map(f))))
    | ObjectProperty(value1, value2) => f(ObjectProperty(value1 |> map(f), value2 |> map(f)))
    | Block(body) => f(Block(body |> List.map(map(f))))
    | Program(body) => f(Program(body |> List.map(map(f))))
    | Unknown => f(node)
    };
  /* Takes an expression like `a === true` and converts it to `a` */
  let optimizeTruthyBooleanExpression = (node) => {
    let booleanValue = (sub) =>
      switch sub {
      | Literal(Types.Value(_, value)) => value |> Json.Decode.optional(Json.Decode.bool)
      | _ => (None: option(bool))
      };
    switch node {
    | BooleanExpression(a, cmp, b) =>
      let boolA = booleanValue(a);
      let boolB = booleanValue(b);
      switch (boolA, cmp, boolB) {
      | (_, Eq, Some(true)) => a
      | (Some(true), Eq, _) => b
      | _ => node
      }
    | _ => node
    }
  };
  /* Renamed "layer.View.backgroundColor" to something JS-safe and nice looking */
  let renameIdentifiers = (node) =>
    switch node {
    | Identifier([head, ...tail]) =>
      switch head {
      | "parameters" => Identifier(["this", "props", ...tail])
      | "layers" =>
        switch tail {
        | [second, ...tail] =>
          Identifier([tail |> List.fold_left((a, b) => a ++ "$" ++ b, second)])
        | _ => node
        }
      | _ => node
      }
    | _ => node
    };
  let optimize = (node) => node |> map(optimizeTruthyBooleanExpression);
  let prepareForRender = (node) => node |> map(renameIdentifiers);
};