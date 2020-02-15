export type Identifier = {
  id: string
  string: string
  isPlaceholder: boolean
}

export type Pattern = {
  id: string
  name: string
}

export type Placeholder = {
  type: 'placeholder'
  data: { id: string }
}

export type VariableDeclaration = {
  type: 'variable'
  data: {
    id: string
    name: Pattern
    annotation?: TypeAnnotation
    initializer?: Expression
    declarationModifier?: string
    comment?: CommentNode
  }
}

export type FunctionDeclaration = {
  type: 'function'
  data: {
    id: string
    name: Pattern
    returnType: TypeAnnotation
    genericParameters: GenericParameter[]
    parameters: FunctionParameter[]
    block: Statement[]
    comment?: CommentNode
  }
}

export type EnumerationDeclaration = {
  type: 'enumeration'
  data: {
    id: string
    name: Pattern
    genericParameters: GenericParameter[]
    cases: EnumerationCase[]
    comment?: CommentNode
  }
}

export type NamespaceDeclaration = {
  type: 'namespace'
  data: {
    id: string
    name: Pattern
    declarations: Declaration[]
  }
}

export type RecordDeclaration = {
  type: 'record'
  data: {
    id: string
    name: Pattern
    genericParameters: GenericParameter[]
    declarations: Declaration[]
    comment?: CommentNode
  }
}

export type ImportDeclaration = {
  type: 'importDeclaration'
  data: {
    id: string
    name: Pattern
  }
}

export type Declaration =
  | VariableDeclaration
  | FunctionDeclaration
  | EnumerationDeclaration
  | NamespaceDeclaration
  | Placeholder
  | RecordDeclaration
  | ImportDeclaration

export type EnumerationCase =
  | Placeholder
  | {
      type: 'enumerationCase'
      data: {
        id: string
        name: Pattern
        associatedValueTypes: TypeAnnotation[]
        comment?: CommentNode
      }
    }

export type IsEqualToBinaryOperator = {
  type: 'isEqualTo'
  data: { id: string }
}

export type IsNotEqualToBinaryOperator = {
  type: 'isNotEqualTo'
  data: { id: string }
}

export type IsLessThanBinaryOperator = {
  type: 'isLessThan'
  data: { id: string }
}

export type IsGreaterThanBinaryOperator = {
  type: 'isGreaterThan'
  data: { id: string }
}

export type IsLessThanOrEqualToBinaryOperator = {
  type: 'isLessThanOrEqual'
  data: { id: string }
}

export type IsGreaterThanOrEqualToBinaryOperator = {
  type: 'isGreaterThanOrEqual'
  data: { id: string }
}

export type SetEqualToBinaryOperator = {
  type: 'setEqualTo'
  data: { id: string }
}

export type BinaryOperator =
  | IsEqualToBinaryOperator
  | IsNotEqualToBinaryOperator
  | IsLessThanBinaryOperator
  | IsGreaterThanBinaryOperator
  | IsLessThanOrEqualToBinaryOperator
  | IsGreaterThanOrEqualToBinaryOperator
  | SetEqualToBinaryOperator

export type FunctionCallArgument =
  | Placeholder
  | {
      type: 'argument'
      data: {
        id: string
        label?: string
        expression: Expression
      }
    }

export type BinaryExpression = {
  type: 'binaryExpression'
  data: {
    left: Expression
    right: Expression
    op: BinaryOperator
    id: string
  }
}

export type IdentifierExpression = {
  type: 'identifierExpression'
  data: {
    id: string
    identifier: Identifier
  }
}

export type FunctionCallExpression = {
  type: 'functionCallExpression'
  data: {
    id: string
    expression: Expression
    arguments: FunctionCallArgument[]
  }
}

export type LiteralExpression = {
  type: 'literalExpression'
  data: {
    id: string
    literal: Literal
  }
}

export type MemberExpression = {
  type: 'memberExpression'
  data: {
    id: string
    expression: Expression
    memberName: Identifier
  }
}

export type Expression =
  | BinaryExpression
  | IdentifierExpression
  | FunctionCallExpression
  | LiteralExpression
  | MemberExpression
  | Placeholder

export type LoopStatement = {
  type: 'loop'
  data: {
    pattern: Pattern
    expression: Expression
    block: Statement[]
    id: string
  }
}

export type BranchStatement = {
  type: 'branch'
  data: {
    id: string
    condition: Expression
    block: Statement[]
  }
}

export type DeclarationStatement = {
  type: 'declaration'
  data: {
    id: string
    content: Declaration
  }
}

export type ExpressionStatement = {
  type: 'expression'
  data: {
    id: string
    expression: Expression
  }
}

export type Statement =
  | LoopStatement
  | BranchStatement
  | DeclarationStatement
  | ExpressionStatement
  | Placeholder

export type FunctionParameter =
  | Placeholder
  | {
      type: 'parameter'
      data: {
        id: string
        externalName?: string
        localName: Pattern
        annotation: TypeAnnotation
        defaultValue: FunctionParameterDefaultValue
        comment?: CommentNode
      }
    }

export type NoneFunctionParameterDefaultValue = {
  type: 'none'
  data: { id: string }
}

export type ValueFunctionParameterDefaultValue = {
  type: 'value'
  data: {
    id: string
    expression: Expression
  }
}

export type FunctionParameterDefaultValue =
  | NoneFunctionParameterDefaultValue
  | ValueFunctionParameterDefaultValue

export type TypeIdentifierTypeAnnotation = {
  type: 'typeIdentifier'
  data: {
    id: string
    identifier: Identifier
    genericArguments: TypeAnnotation[]
  }
}

export type FunctionTypeTypeAnnotation = {
  type: 'functionType'
  data: {
    id: string
    returnType: TypeAnnotation
    argumentTypes: TypeAnnotation[]
  }
}

export type TypeAnnotation =
  | TypeIdentifierTypeAnnotation
  | FunctionTypeTypeAnnotation
  | Placeholder

export type NoneLiteral = { type: 'none'; data: { id: string } }

export type BooleanLiteral = {
  type: 'boolean'
  data: {
    id: string
    value: boolean
  }
}

export type NumberLiteral = {
  type: 'number'
  data: {
    id: string
    value: number
  }
}

export type StringLiteral = {
  type: 'string'
  data: {
    id: string
    value: string
  }
}

export type ColorLiteral = {
  type: 'color'
  data: {
    id: string
    value: string
  }
}

export type ArrayLiteral = {
  type: 'array'
  data: {
    id: string
    value: Expression[]
  }
}

export type Literal =
  | NoneLiteral
  | BooleanLiteral
  | NumberLiteral
  | StringLiteral
  | ColorLiteral
  | ArrayLiteral

export type TopLevelParameters = {
  type: 'topLevelParameters'
  data: {
    id: string
    parameters: FunctionParameter[]
  }
}

export type GenericParameter =
  | Placeholder
  | {
      type: 'parameter'
      data: {
        id: string
        name: Pattern
      }
    }

export type CommentNode = {
  type: 'comment'
  data: {
    id: string
    string: string
  }
}

export type TopLevelDeclarations = {
  type: 'topLevelDeclarations'
  data: {
    id: string
    declarations: Declaration[]
  }
}

export type Program = {
  type: 'program'
  data: {
    id: string
    block: Statement[]
  }
}

export type SyntaxNode =
  | Statement
  | Declaration
  | Expression
  | BinaryOperator
  | Program
  | FunctionParameter
  | FunctionParameterDefaultValue
  | TypeAnnotation
  | Literal
  | TopLevelParameters
  | EnumerationCase
  | GenericParameter
  | TopLevelDeclarations
  | CommentNode
  | FunctionCallArgument

/**
 * Typescript type predicates
 */

export function isStatement(
  node: SyntaxNode | Pattern | Identifier
): node is Statement {
  return (
    'type' in node &&
    (node.type === 'loop' ||
      node.type === 'branch' ||
      node.type === 'declaration' ||
      node.type === 'expression')
  )
}

export function isDeclaration(
  node: SyntaxNode | Pattern | Identifier
): node is Declaration {
  return (
    'type' in node &&
    (node.type === 'variable' ||
      node.type === 'function' ||
      node.type === 'enumeration' ||
      node.type === 'namespace' ||
      node.type === 'placeholder' ||
      node.type === 'record' ||
      node.type === 'importDeclaration')
  )
}

export function isExpression(
  node: SyntaxNode | Pattern | Identifier
): node is Expression {
  return (
    'type' in node &&
    (node.type === 'binaryExpression' ||
      node.type === 'functionCallExpression' ||
      node.type === 'identifierExpression' ||
      node.type === 'literalExpression' ||
      node.type === 'memberExpression')
  )
}

export function isTypeAnnotation(
  node: SyntaxNode | Pattern | Identifier
): node is TypeAnnotation {
  return (
    'type' in node &&
    (node.type === 'typeIdentifier' ||
      node.type === 'functionType' ||
      node.type === 'placeholder')
  )
}

export function subNodes(node: SyntaxNode): SyntaxNode[] {
  if (node.type === 'loop') {
    return ([node.data.expression] as SyntaxNode[]).concat(node.data.block)
  }
  if (node.type === 'branch') {
    return ([node.data.condition] as SyntaxNode[]).concat(node.data.block)
  }
  if (node.type === 'declaration') {
    return [node.data.content]
  }
  if (node.type === 'expression') {
    return [node.data.expression]
  }

  if (node.type === 'variable') {
    return ([] as SyntaxNode[])
      .concat(node.data.annotation ? [node.data.annotation] : [])
      .concat(node.data.initializer ? [node.data.initializer] : [])
  }
  if (node.type === 'function') {
    return ([node.data.returnType] as SyntaxNode[])
      .concat(node.data.genericParameters)
      .concat(node.data.parameters)
      .concat(node.data.block)
  }
  if (node.type === 'enumeration') {
    return ([] as SyntaxNode[])
      .concat(node.data.genericParameters)
      .concat(node.data.cases)
  }
  if (node.type === 'namespace') {
    return node.data.declarations
  }
  if (node.type === 'record') {
    return ([] as SyntaxNode[])
      .concat(node.data.declarations)
      .concat(node.data.genericParameters)
  }
  if (node.type === 'binaryExpression') {
    return [node.data.left, node.data.right, node.data.op]
  }
  if (node.type === 'functionCallExpression') {
    return ([node.data.expression] as SyntaxNode[]).concat(node.data.arguments)
  }
  if (node.type === 'literalExpression') {
    return [node.data.literal]
  }
  if (node.type === 'memberExpression') {
    return [node.data.expression]
  }

  if (node.type === 'program') {
    return node.data.block
  }

  if (node.type === 'parameter') {
    if ('localName' in node.data) {
      return [node.data.annotation, node.data.defaultValue]
    }
  }

  if (node.type === 'value') {
    return [node.data.expression]
  }

  if (node.type === 'typeIdentifier') {
    return node.data.genericArguments
  }
  if (node.type === 'functionType') {
    return ([node.data.returnType] as SyntaxNode[]).concat(
      node.data.argumentTypes
    )
  }

  if (node.type === 'array') {
    return node.data.value
  }

  if (node.type === 'topLevelParameters') {
    return node.data.parameters
  }

  if (node.type === 'enumerationCase') {
    return node.data.associatedValueTypes
  }

  if (node.type === 'topLevelDeclarations') {
    return node.data.declarations
  }

  if (node.type === 'argument') {
    return [node.data.expression]
  }

  return []
}
