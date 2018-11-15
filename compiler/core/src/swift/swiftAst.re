[@bs.deriving accessors]
type accessLevelModifier =
  | PrivateModifier
  | FileprivateModifier
  | InternalModifier
  | PublicModifier
  | OpenModifier;

[@bs.deriving accessors]
type mutationModifier =
  | MutatingModifier
  | NonmutatingModifier;

type attribute = string;

[@bs.deriving accessors]
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
  | Image(string)
  | Array(list(node))
and typeAnnotation =
  | TypeName(string)
  | TypeIdentifier(
      {
        .
        "name": typeAnnotation,
        "member": typeAnnotation,
      },
    )
  | ArrayType(typeAnnotation)
  | DictionaryType(
      {
        .
        "key": typeAnnotation,
        "value": typeAnnotation,
      },
    )
  | OptionalType(typeAnnotation)
  | TupleType(list(typeAnnotation))
  | TypeInheritanceList({. "list": list(typeAnnotation)})
and pattern =
  | WildcardPattern
  | IdentifierPattern(
      {
        .
        "identifier": node,
        "annotation": option(typeAnnotation),
      },
    )
  | ValueBindingPattern(
      {
        .
        "kind": string,
        "pattern": pattern,
      },
    )
  | TuplePattern(list(pattern))
  | OptionalPattern({. "value": pattern})
  | ExpressionPattern({. "value": node})
  | EnumCasePattern(
      {
        .
        "typeIdentifier": option(string),
        "caseName": string,
        "tuplePattern": option(pattern),
      },
    )
/* | IsPattern */
/* | AsPattern */
and initializerBlock =
  | GetterBlock(list(node))
  | GetterSetterBlock(
      {
        .
        "get": list(node),
        "set": list(node),
      },
    )
  | WillSetDidSetBlock(
      {
        .
        "willSet": option(list(node)),
        "didSet": option(list(node)),
      },
    )
[@bs.deriving accessors]
and node =
  /* | Operator(string) */
  | LiteralExpression(literal)
  | MemberExpression(list(node))
  | TupleExpression(list(node))
  | BinaryExpression(
      {
        .
        "left": node,
        "operator": string,
        "right": node,
      },
    )
  | PrefixExpression(
      {
        .
        "operator": string,
        "expression": node,
      },
    )
  | TryExpression(
      {
        .
        "forced": bool,
        "optional": bool,
        "expression": node,
      },
    )
  | ClassDeclaration(
      {
        .
        "name": string,
        "inherits": list(typeAnnotation),
        "modifier": option(accessLevelModifier),
        "isFinal": bool,
        "body": list(node),
      },
    )
  | StructDeclaration(
      {
        .
        "name": string,
        "inherits": list(typeAnnotation),
        "modifier": option(accessLevelModifier),
        "body": list(node),
      },
    )
  | EnumDeclaration(
      {
        .
        "name": string,
        "isIndirect": bool,
        "inherits": list(typeAnnotation),
        "modifier": option(accessLevelModifier),
        "body": list(node),
      },
    )
  | TypealiasDeclaration(
      {
        .
        "name": string,
        "modifier": option(accessLevelModifier),
        "annotation": typeAnnotation,
      },
    )
  | ExtensionDeclaration(
      {
        .
        "name": string,
        "protocols": list(typeAnnotation),
        "where": option(node),
        "modifier": option(accessLevelModifier),
        "body": list(node),
      },
    )
  /* | VariableDeclaration({. "pattern": pattern, "init": option(node)}) */
  | SwiftIdentifier(string)
  | ConstantDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "pattern": pattern,
        "init": option(node),
      },
    )
  | VariableDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "pattern": pattern,
        "init": option(node),
        "block": option(initializerBlock),
      },
    )
  | InitializerDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "parameters": list(node),
        "failable": option(string),
        "throws": bool,
        "body": list(node),
      },
    )
  | DeinitializerDeclaration(list(node))
  | FunctionDeclaration(
      {
        .
        "name": string,
        "attributes": list(attribute),
        "modifiers": list(declarationModifier),
        "parameters": list(node),
        "result": option(typeAnnotation),
        "body": list(node),
        "throws": bool,
      },
    )
  | ImportDeclaration(string)
  | IfStatement(
      {
        .
        "condition": node,
        "block": list(node),
      },
    )
  | WhileStatement(
      {
        .
        "condition": node,
        "block": list(node),
      },
    )
  | SwitchStatement(
      {
        .
        "expression": node,
        "cases": list(node),
      },
    )
  | CaseLabel(
      {
        .
        "patterns": list(pattern),
        "statements": list(node),
      },
    )
  | DefaultCaseLabel({. "statements": list(node)})
  | ReturnStatement(option(node))
  | Parameter(
      {
        .
        "externalName": option(string),
        "localName": string,
        "annotation": typeAnnotation,
        "defaultValue": option(node),
      },
    )
  | FunctionCallArgument(
      {
        .
        "name": option(node),
        "value": node,
      },
    )
  | FunctionCallExpression(
      {
        .
        "name": node,
        "arguments": list(node),
      },
    )
  | EnumCase(
      {
        .
        "name": node,
        "parameters": option(typeAnnotation),
        "value": option(node),
      },
    )
  | ConditionList(list(node))
  | OptionalBindingCondition(
      {
        .
        "const": bool,
        "pattern": pattern,
        "init": node,
      },
    )
  | CaseCondition(
      {
        .
        "pattern": pattern,
        "init": node,
      },
    )
  | Empty
  | LineComment(string)
  | DocComment(string)
  | LineEndComment(
      {
        .
        "comment": string,
        "line": node,
      },
    )
  | CodeBlock({. "statements": list(node)})
  | StatementListHelper(list(node))
  | TopLevelDeclaration({. "statements": list(node)});

/* Ast builders for convenience, agnostic to the kind of data they use */
module Builders = {
  let memberExpression = (list: list(string)): node =>
    switch (list) {
    | [item] => SwiftIdentifier(item)
    | _ => MemberExpression(list |> List.map(item => SwiftIdentifier(item)))
    };

  let functionCall =
      (
        name: list(string),
        arguments: list((option(string), list(string))),
      )
      : node =>
    FunctionCallExpression({
      "name": memberExpression(name),
      "arguments":
        arguments
        |> List.map(((label, expr)) =>
             FunctionCallArgument({
               "name":
                 switch (label) {
                 | Some(value) => Some(SwiftIdentifier(value))
                 | None => None
                 },
               "value": memberExpression(expr),
             })
           ),
    });

  let privateVariableDeclaration =
      (name: string, annotation: option(typeAnnotation), init: option(node)) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PrivateModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(name),
          "annotation": annotation,
        }),
      "init": init,
      "block": None,
    });

  let publicVariableDeclaration =
      (name: string, annotation: option(typeAnnotation), init: option(node)) =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(name),
          "annotation": annotation,
        }),
      "init": init,
      "block": None,
    });

  let convenienceInit = (body: list(node)): node =>
    InitializerDeclaration({
      "modifiers": [
        AccessLevelModifier(PublicModifier),
        ConvenienceModifier,
      ],
      "parameters": [],
      "failable": None,
      "throws": false,
      "body": body,
    });
};