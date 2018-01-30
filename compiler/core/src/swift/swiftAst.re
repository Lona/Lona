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
  | Array(list(node))
and typeAnnotation =
  | TypeName(string)
  | TypeIdentifier(
      {
        .
        "name": typeAnnotation,
        "member": typeAnnotation
      }
    )
  | ArrayType({. "element": typeAnnotation})
  | DictionaryType(
      {
        .
        "key": typeAnnotation,
        "value": typeAnnotation
      }
    )
  | OptionalType(typeAnnotation)
  | TypeInheritanceList({. "list": list(typeAnnotation)})
and pattern =
  | WildcardPattern
  | IdentifierPattern(
      {
        .
        "identifier": node,
        "annotation": option(typeAnnotation)
      }
    )
  | ValueBindingPattern(
      {
        .
        "kind": string,
        "pattern": pattern
      }
    )
  | TuplePattern({. "elements": list(pattern)})
  | OptionalPattern({. "value": pattern})
  | ExpressionPattern({. "value": node})
/* | IsPattern */
/* | AsPattern */
and initializerBlock =
  | WillSetDidSetBlock(
      {
        .
        "willSet": option(list(node)),
        "didSet": option(list(node))
      }
    )
and node =
  /* | Operator(string) */
  | LiteralExpression(literal)
  | MemberExpression(list(node))
  | BinaryExpression(
      {
        .
        "left": node,
        "operator": string,
        "right": node
      }
    )
  | PrefixExpression(
      {
        .
        "operator": string,
        "expression": node
      }
    )
  | ClassDeclaration(
      {
        .
        "name": string,
        "inherits": list(typeAnnotation),
        "modifier": option(accessLevelModifier),
        "isFinal": bool,
        "body": list(node)
      }
    )
  | EnumDeclaration(
      {
        .
        "name": string,
        "modifier": option(accessLevelModifier),
        "body": list(node)
      }
    )
  /* | VariableDeclaration({. "pattern": pattern, "init": option(node)}) */
  | SwiftIdentifier(string)
  | ConstantDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "pattern": pattern,
        "init": option(node)
      }
    )
  | VariableDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "pattern": pattern,
        "init": option(node),
        "block": option(initializerBlock)
      }
    )
  | InitializerDeclaration(
      {
        .
        "modifiers": list(declarationModifier),
        "parameters": list(node),
        "failable": option(string),
        "body": list(node)
      }
    )
  | FunctionDeclaration(
      {
        .
        "name": string,
        "modifiers": list(declarationModifier),
        "parameters": list(node),
        "body": list(node)
      }
    )
  | ImportDeclaration(string)
  | IfStatement(
      {
        .
        "condition": node,
        "block": list(node)
      }
    )
  | Parameter(
      {
        .
        "externalName": option(string),
        "localName": string,
        "annotation": typeAnnotation,
        "defaultValue": option(node)
      }
    )
  | FunctionCallArgument(
      {
        .
        "name": option(node),
        "value": node
      }
    )
  | FunctionCallExpression(
      {
        .
        "name": node,
        "arguments": list(node)
      }
    )
  | Empty
  | LineComment(string)
  | LineEndComment(
      {
        .
        "comment": string,
        "line": node
      }
    )
  | CodeBlock({. "statements": list(node)})
  | StatementListHelper(list(node))
  | TopLevelDeclaration({. "statements": list(node)});
