enum AccessLevelModifier {
  PrivateModifier = 'PrivateModifier',
  FileprivateModifier = 'FileprivateModifier',
  InternalModifier = 'InternalModifier',
  PublicModifier = 'PublicModifier',
  OpenModifier = 'OpenModifier',
}

enum MutationModifier {
  MutatingModifier = 'MutatingModifier',
  NonmutatingModifier = 'NonmutatingModifier',
}

enum OtherModifier {
  ClassModifier = 'ClassModifier',
  ConvenienceModifier = 'ConvenienceModifier',
  DynamicModifier = 'DynamicModifier',
  FinalModifier = 'FinalModifier',
  InfixModifier = 'InfixModifier',
  LazyModifier = 'LazyModifier',
  OptionalModifier = 'OptionalModifier',
  OverrideModifier = 'OverrideModifier',
  PostfixModifier = 'PostfixModifier',
  PrefixModifier = 'PrefixModifier',
  RequiredModifier = 'RequiredModifier',
  StaticModifier = 'StaticModifier',
  UnownedModifier = 'UnownedModifier',
  UnownedSafeModifier = 'UnownedSafeModifier',
  UnownedUnsafeModifier = 'UnownedUnsafeModifier',
  WeakModifier = 'WeakModifier',
}

type Attribute = string

export type DeclarationModifier =
  | AccessLevelModifier
  | MutationModifier
  | OtherModifier
export const DeclarationModifier = {
  ...AccessLevelModifier,
  ...MutationModifier,
  ...OtherModifier,
}

type Literal =
  | { type: 'Nil'; data: undefined }
  | { type: 'Boolean'; data: boolean }
  | { type: 'Integer'; data: number }
  | { type: 'FloatingPoint'; data: number }
  | { type: 'String'; data: string }
  | { type: 'Color'; data: string }
  | { type: 'Image'; data: string }
  | { type: 'Array'; data: SwiftNode[] }

type TupleTypeElement = {
  elementName?: string
  annotation: TypeAnnotation
}

export type TypeAnnotation =
  | { type: 'TypeName'; data: string }
  | {
      type: 'TypeIdentifier'
      data: {
        name: TypeAnnotation
        member: TypeAnnotation
      }
    }
  | { type: 'ArrayType'; data: TypeAnnotation }
  | {
      type: 'DictionaryType'
      data: {
        key: TypeAnnotation
        value: TypeAnnotation
      }
    }
  | { type: 'OptionalType'; data: TypeAnnotation }
  | { type: 'TupleType'; data: TupleTypeElement[] }
  | {
      type: 'FunctionType'
      data: {
        arguments: TypeAnnotation[]
        returnType?: TypeAnnotation
      }
    }
  | { type: 'TypeInheritanceList'; data: { list: TypeAnnotation[] } }
  | { type: 'ProtocolCompositionType'; data: TypeAnnotation[] }

type Pattern =
  | { type: 'WildcardPattern' }
  | {
      type: 'IdentifierPattern'
      data: {
        identifier: SwiftNode
        annotation?: TypeAnnotation
      }
    }
  | {
      type: 'ValueBindingPattern'
      data: {
        kind: string
        pattern: Pattern
      }
    }
  | { type: 'TuplePattern'; data: Pattern[] }
  | { type: 'OptionalPattern'; data: { value: Pattern } }
  | { type: 'ExpressionPattern'; data: { value: SwiftNode } }
  | {
      type: 'EnumCasePattern'
      data: {
        typeIdentifier?: string
        caseName: string
        tuplePattern?: Pattern
      }
    }
/* | IsPattern */
/* | AsPattern */

type InitializerBlock =
  | { type: 'GetterBlock'; data: SwiftNode }
  | {
      type: 'GetterSetterBlock'
      data: {
        get: SwiftNode[]
        set: SwiftNode[]
      }
    }
  | {
      type: 'WillSetDidSetBlock'
      data: {
        willSet?: SwiftNode[]
        didSet?: SwiftNode
      }
    }

export type SwiftNode =
  /* | Operator(string) */
  | { type: 'LiteralExpression'; data: Literal }
  | { type: 'MemberExpression'; data: SwiftNode[] }
  | { type: 'TupleExpression'; data: SwiftNode[] }
  | {
      type: 'BinaryExpression'
      data: {
        left: SwiftNode
        operator: string
        right: SwiftNode
      }
    }
  | {
      type: 'PrefixExpression'
      data: {
        operator: string
        expression: SwiftNode
      }
    }
  | {
      type: 'TryExpression'
      data: {
        forced: boolean
        optional: boolean
        expression: SwiftNode
      }
    }
  | {
      type: 'ClassDeclaration'
      data: {
        name: string
        inherits: TypeAnnotation[]
        modifier?: AccessLevelModifier
        isFinal: boolean
        body: SwiftNode[]
      }
    }
  | {
      type: 'StructDeclaration'
      data: {
        name: string
        inherits: TypeAnnotation[]
        modifier?: AccessLevelModifier
        body: SwiftNode[]
      }
    }
  | {
      type: 'EnumDeclaration'
      data: {
        name: string
        isIndirect: boolean
        inherits: TypeAnnotation[]
        modifier?: AccessLevelModifier
        body: SwiftNode[]
      }
    }
  | {
      type: 'TypealiasDeclaration'
      data: {
        name: string
        modifier?: AccessLevelModifier
        annotation: TypeAnnotation
      }
    }
  | {
      type: 'ExtensionDeclaration'
      data: {
        name: string
        protocols: TypeAnnotation[]
        where?: SwiftNode
        modifier?: AccessLevelModifier
        body: SwiftNode[]
      }
    }
  /* | {type: 'VariableDeclaration', data: {"pattern": Pattern, "init"?: SwiftNode}} */
  | { type: 'SwiftIdentifier'; data: string }
  | {
      type: 'ConstantDeclaration'
      data: {
        modifiers: DeclarationModifier[]
        pattern: Pattern
        init?: SwiftNode
      }
    }
  | {
      type: 'VariableDeclaration'
      data: {
        modifiers: DeclarationModifier[]
        pattern: Pattern
        init?: SwiftNode
        block?: InitializerBlock
      }
    }
  | {
      type: 'InitializerDeclaration'
      data: {
        modifiers: DeclarationModifier[]
        parameters: SwiftNode[]
        failable?: string
        throws: boolean
        body: SwiftNode[]
      }
    }
  | { type: 'DeinitializerDeclaration'; data: SwiftNode[] }
  | {
      type: 'FunctionDeclaration'
      data: {
        name: string
        attributes: Attribute[]
        modifiers: DeclarationModifier[]
        parameters: SwiftNode[]
        result?: TypeAnnotation
        body: SwiftNode[]
        throws: boolean
      }
    }
  | { type: 'ImportDeclaration'; data: string }
  | {
      type: 'IfStatement'
      data: {
        condition: SwiftNode
        block: SwiftNode[]
      }
    }
  | {
      type: 'WhileStatement'
      data: {
        condition: SwiftNode
        block: SwiftNode[]
      }
    }
  | {
      type: 'ForInStatement'
      data: {
        item: Pattern
        collection: SwiftNode
        block: SwiftNode[]
      }
    }
  | {
      type: 'SwitchStatement'
      data: {
        expression: SwiftNode
        cases: SwiftNode[]
      }
    }
  | {
      type: 'CaseLabel'
      data: {
        patterns: Pattern[]
        statements: SwiftNode[]
      }
    }
  | { type: 'DefaultCaseLabel'; data: { statements: SwiftNode[] } }
  | { type: 'ReturnStatement'; data?: SwiftNode }
  | {
      type: 'Parameter'
      data: {
        externalName?: string
        localName: string
        annotation: TypeAnnotation
        defaultValue?: SwiftNode
      }
    }
  | {
      type: 'FunctionCallArgument'
      data: {
        name?: SwiftNode
        value: SwiftNode
      }
    }
  | {
      type: 'FunctionCallExpression'
      data: {
        name: SwiftNode
        arguments: SwiftNode[]
      }
    }
  | {
      type: 'EnumCase'
      data: {
        name: SwiftNode
        parameters?: TypeAnnotation
        value?: SwiftNode
      }
    }
  | { type: 'ConditionList'; data: SwiftNode[] }
  | {
      type: 'OptionalBindingCondition'
      data: {
        const: boolean
        pattern: Pattern
        init: SwiftNode
      }
    }
  | {
      type: 'CaseCondition'
      data: {
        pattern: Pattern
        init: SwiftNode
      }
    }
  | { type: 'Empty'; data: undefined }
  | { type: 'LineComment'; data: string }
  | { type: 'DocComment'; data: string }
  | {
      type: 'LineEndComment'
      data: {
        comment: string
        line: SwiftNode
      }
    }
  | { type: 'CodeBlock'; data: { statements: SwiftNode[] } }
  | { type: 'StatementListHelper'; data: SwiftNode[] }
  | { type: 'TopLevelDeclaration'; data: { statements: SwiftNode[] } }

// /* Ast builders for convenience, agnostic to the kind of data they use */
// module Builders = {
//   let memberExpression = (list: list(string)): node =>
//     switch (list) {
//     | [item] => SwiftIdentifier(item)
//     | _ => MemberExpression(list |> List.map(item => SwiftIdentifier(item)))
//     };

//   let functionCall =
//       (
//         name: list(string),
//         arguments: list((option(string), list(string))),
//       )
//       : node =>
//     FunctionCallExpression({
//       "name": memberExpression(name),
//       "arguments":
//         arguments
//         |> List.map(((label, expr)) =>
//              FunctionCallArgument({
//                "name":
//                  switch (label) {
//                  | Some(value) => Some(SwiftIdentifier(value))
//                  | None => None
//                  },
//                "value": memberExpression(expr),
//              })
//            ),
//     });

//   let privateVariableDeclaration =
//       (name: string, annotation: option(typeAnnotation), init: option(node)) =>
//     VariableDeclaration({
//       "modifiers": [AccessLevelModifier(PrivateModifier)],
//       "pattern":
//         IdentifierPattern({
//           "identifier": SwiftIdentifier(name),
//           "annotation": annotation,
//         }),
//       "init": init,
//       "block": None,
//     });

//   let publicVariableDeclaration =
//       (name: string, annotation: option(typeAnnotation), init: option(node)) =>
//     VariableDeclaration({
//       "modifiers": [AccessLevelModifier(PublicModifier)],
//       "pattern":
//         IdentifierPattern({
//           "identifier": SwiftIdentifier(name),
//           "annotation": annotation,
//         }),
//       "init": init,
//       "block": None,
//     });

//   let convenienceInit = (body: list(node)): node =>
//     InitializerDeclaration({
//       "modifiers": [
//         AccessLevelModifier(PublicModifier),
//         ConvenienceModifier,
//       ],
//       "parameters": [],
//       "failable": None,
//       "throws": false,
//       "body": body,
//     });

//   let memberOrSelfExpression = (firstIdentifier, statements) =>
//     switch (firstIdentifier) {
//     | "self" => MemberExpression(statements)
//     | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
//     };
// };

// /* Fixes reason complication where field names weren't importing from this module */
// let makeTupleElement =
//     (elementName: option(string), annotation: typeAnnotation) => {
//   elementName,
//   annotation,
// };
