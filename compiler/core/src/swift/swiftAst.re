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
[@bs.deriving accessors]
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
  | TryExpression(
      {
        .
        "forced": bool,
        "optional": bool,
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
        "inherits": list(typeAnnotation),
        "modifier": option(accessLevelModifier),
        "body": list(node)
      }
    )
  | ExtensionDeclaration(
      {
        .
        "name": string,
        "protocols": list(typeAnnotation),
        "where": option(node),
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
        "throws": bool,
        "body": list(node)
      }
    )
  | DeinitializerDeclaration(list(node))
  | FunctionDeclaration(
      {
        .
        "name": string,
        "modifiers": list(declarationModifier),
        "parameters": list(node),
        "result": option(typeAnnotation),
        "body": list(node),
        "throws": bool
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
  | ReturnStatement(option(node))
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
  | EnumCase(
      {
        .
        "name": node,
        "value": option(node)
      }
    )
  | Empty
  | LineComment(string)
  | DocComment(string)
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