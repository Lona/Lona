import uuid from '../utils/uuid'

export type Identifier = {
  type: 'identifier'
  data: {
    id: string
    string: string
    isPlaceholder: boolean
  }
}

export type VariableDeclaration = {
  type: 'variable'
  data: {
    id: string
    name: Pattern
    annotation?: TypeAnnotation
    initializer?: Expression
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

export type PlaceholderDeclaration = {
  type: 'placeholder'
  data: { id: string }
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

export type ImportDeclarationDeclaration = {
  type: 'importDeclaration'
  data: {
    id: string
    name: Pattern
  }
}

export type Declaration = {
  type: 'declaration'
  data:
    | VariableDeclaration
    | FunctionDeclaration
    | EnumerationDeclaration
    | NamespaceDeclaration
    | PlaceholderDeclaration
    | RecordDeclaration
    | ImportDeclarationDeclaration
}

export type PlaceholderEnumerationCase = {
  type: 'placeholder'
  data: { id: string }
}

export type EnumerationCaseEnumerationCase = {
  type: 'enumerationCase'
  data: {
    id: string
    name: Pattern
    associatedValueTypes: TypeAnnotation[]
    comment?: CommentNode
  }
}

export type EnumerationCase = {
  type: 'enumerationCase'
  data: PlaceholderEnumerationCase | EnumerationCaseEnumerationCase
}

export type Pattern = {
  type: 'pattern'
  data: {
    id: string
    name: string
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

export type BinaryOperator = {
  type: 'binaryOperator'
  data:
    | IsEqualToBinaryOperator
    | IsNotEqualToBinaryOperator
    | IsLessThanBinaryOperator
    | IsGreaterThanBinaryOperator
    | IsLessThanOrEqualToBinaryOperator
    | IsGreaterThanOrEqualToBinaryOperator
    | SetEqualToBinaryOperator
}

export type ArgumentFunctionCallArgument = {
  type: 'argument'
  data: {
    id: string
    label?: string
    expression: Expression
  }
}

export type PlaceholderFunctionCallArgument = {
  type: 'placeholder'
  data: { id: string }
}

export type FunctionCallArgument = {
  type: 'functionCallArgument'
  data: ArgumentFunctionCallArgument | PlaceholderFunctionCallArgument
}

export type BinaryExpressionExpression = {
  type: 'binaryExpression'
  data: {
    left: Expression
    right: Expression
    op: BinaryOperator
    id: string
  }
}

export type IdentifierExpressionExpression = {
  type: 'identifierExpression'
  data: {
    id: string
    identifier: Identifier
  }
}

export type FunctionCallExpressionExpression = {
  type: 'functionCallExpression'
  data: {
    id: string
    expression: Expression
    arguments: FunctionCallArgument[]
  }
}

export type LiteralExpressionExpression = {
  type: 'literalExpression'
  data: {
    id: string
    literal: Literal
  }
}

export type MemberExpressionExpression = {
  type: 'memberExpression'
  data: {
    id: string
    expression: Expression
    memberName: Identifier
  }
}

export type PlaceholderExpression = {
  type: 'placeholder'
  data: { id: string }
}

export type Expression = {
  type: 'expression'
  data:
    | BinaryExpressionExpression
    | IdentifierExpressionExpression
    | FunctionCallExpressionExpression
    | LiteralExpressionExpression
    | MemberExpressionExpression
    | PlaceholderExpression
}

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

export type ExpressionStatementStatement = {
  type: 'expression'
  data: {
    id: string
    expression: Expression
  }
}

export type PlaceholderStatement = { type: 'placeholder'; data: { id: string } }

export type Statement = {
  type: 'statement'
  data:
    | LoopStatement
    | BranchStatement
    | DeclarationStatement
    | ExpressionStatementStatement
    | PlaceholderStatement
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
  | Identifier
  | Expression
  | Pattern
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

export type ParameterFunctionParameter = {
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

export type PlaceholderFunctionParameter = {
  type: 'placeholder'
  data: { id: string }
}

export type FunctionParameter = {
  type: 'functionParameter'
  data: ParameterFunctionParameter | PlaceholderFunctionParameter
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

export type FunctionParameterDefaultValue = {
  type: 'functionParameterDefaultValue'
  data: NoneFunctionParameterDefaultValue | ValueFunctionParameterDefaultValue
}

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

export type PlaceholderTypeAnnotation = {
  type: 'placeholder'
  data: { id: string }
}

export type TypeAnnotation = {
  type: 'typeAnnotation'
  data:
    | TypeIdentifierTypeAnnotation
    | FunctionTypeTypeAnnotation
    | PlaceholderTypeAnnotation
}

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

export type Literal = {
  type: 'literal'
  data:
    | NoneLiteral
    | BooleanLiteral
    | NumberLiteral
    | StringLiteral
    | ColorLiteral
    | ArrayLiteral
}

export type TopLevelParametersTopLevelParameters = {
  id: string
  parameters: FunctionParameter[]
}

export type TopLevelParameters = {
  type: 'topLevelParameters'
  data: TopLevelParametersTopLevelParameters
}

export type ParameterGenericParameter = {
  type: 'parameter'
  data: {
    id: string
    name: Pattern
  }
}

export type PlaceholderGenericParameter = {
  type: 'placeholder'
  data: { id: string }
}

export type GenericParameter = {
  type: 'genericParameter'
  data: ParameterGenericParameter | PlaceholderGenericParameter
}

export type TopLevelDeclarationsTopLevelDeclarations = {
  id: string
  declarations: Declaration[]
}

export type TopLevelDeclarations = {
  type: 'topLevelDeclarations'
  data: TopLevelDeclarationsTopLevelDeclarations
}

export type CommentNode = {
  type: 'comment'
  data: {
    id: string
    string: string
  }
}

export function joinPrograms(programs: (Program | void)[]): Program {
  return {
    type: 'program',
    data: {
      id: uuid(),
      block: programs.reduce(
        (prev, x) => (x ? prev.concat(x.data.block) : prev),
        []
      ),
    },
  }
}

export function makeProgram(node: SyntaxNode): Program | void {
  if (node.type === 'program') {
    return node
  }
  if (node.type === 'statement') {
    return { type: 'program', data: { id: uuid(), block: [node] } }
  }
  if (node.type === 'declaration') {
    return makeProgram({
      type: 'statement',
      data: { type: 'declaration', data: { id: uuid(), content: node } },
    })
  }
  if (node.type === 'topLevelDeclarations') {
    return {
      type: 'program',
      data: {
        id: uuid(),
        block: node.data.declarations.map(x => ({
          type: 'statement',
          data: { type: 'declaration', data: { id: uuid(), content: x } },
        })),
      },
    }
  }
}

export function subNodes(node: SyntaxNode): SyntaxNode[] {
  if (node.type === 'statement') {
    if (node.data.type === 'loop') {
      return ([node.data.data.expression] as SyntaxNode[]).concat(
        node.data.data.block
      )
    }
    if (node.data.type === 'branch') {
      return ([node.data.data.condition] as SyntaxNode[]).concat(
        node.data.data.block
      )
    }
    if (node.data.type === 'declaration') {
      return [node.data.data.content]
    }
    if (node.data.type === 'expression') {
      return [node.data.data.expression]
    }
  }

  if (node.type === 'declaration') {
    if (node.data.type === 'variable') {
      return ([node.data.data.name] as SyntaxNode[])
        .concat(node.data.data.annotation ? [node.data.data.annotation] : [])
        .concat(node.data.data.initializer ? [node.data.data.initializer] : [])
    }
    if (node.data.type === 'function') {
      return ([node.data.data.name, node.data.data.returnType] as SyntaxNode[])
        .concat(node.data.data.genericParameters)
        .concat(node.data.data.parameters)
        .concat(node.data.data.block)
    }
    if (node.data.type === 'enumeration') {
      return ([node.data.data.name] as SyntaxNode[])
        .concat(node.data.data.genericParameters)
        .concat(node.data.data.cases)
    }
    if (node.data.type === 'namespace') {
      return ([node.data.data.name] as SyntaxNode[]).concat(
        node.data.data.declarations
      )
    }
    if (node.data.type === 'record') {
      return ([node.data.data.name] as SyntaxNode[])
        .concat(node.data.data.declarations)
        .concat(node.data.data.genericParameters)
    }
    if (node.data.type === 'importDeclaration') {
      return [node.data.data.name]
    }
  }

  if (node.type === 'expression') {
    if (node.data.type === 'binaryExpression') {
      return [node.data.data.left, node.data.data.right, node.data.data.op]
    }
    if (node.data.type === 'identifierExpression') {
      return [node.data.data.identifier]
    }
    if (node.data.type === 'functionCallExpression') {
      return ([node.data.data.expression] as SyntaxNode[]).concat(
        node.data.data.arguments
      )
    }
    if (node.data.type === 'literalExpression') {
      return [node.data.data.literal]
    }
    if (node.data.type === 'memberExpression') {
      return [node.data.data.expression, node.data.data.memberName]
    }
  }

  if (node.type === 'program') {
    return node.data.block
  }

  if (node.type === 'functionParameter') {
    if (node.data.type === 'parameter') {
      return [
        node.data.data.localName,
        node.data.data.annotation,
        node.data.data.defaultValue,
      ]
    }
  }

  if (node.type === 'functionParameterDefaultValue') {
    if (node.data.type === 'value') {
      return [node.data.data.expression]
    }
  }

  if (node.type === 'typeAnnotation') {
    if (node.data.type === 'typeIdentifier') {
      return ([node.data.data.identifier] as SyntaxNode[]).concat(
        node.data.data.genericArguments
      )
    }
    if (node.data.type === 'functionType') {
      return ([node.data.data.returnType] as SyntaxNode[]).concat(
        node.data.data.argumentTypes
      )
    }
  }

  if (node.type === 'literal') {
    if (node.data.type === 'array') {
      return node.data.data.value
    }
  }

  if (node.type === 'topLevelParameters') {
    return node.data.parameters
  }

  if (node.type === 'enumerationCase') {
    if (node.data.type === 'enumerationCase') {
      return ([node.data.data.name] as SyntaxNode[]).concat(
        node.data.data.associatedValueTypes
      )
    }
  }

  if (node.type === 'genericParameter') {
    if (node.data.type === 'parameter') {
      return [node.data.data.name]
    }
  }

  if (node.type === 'topLevelDeclarations') {
    return node.data.declarations
  }

  if (node.type === 'functionCallArgument') {
    if (node.data.type === 'argument') {
      return [node.data.data.expression]
    }
  }

  return []
}

export function flattenedMemberExpression(
  memberExpression: Expression
): Identifier[] | void {
  if (memberExpression.data.type !== 'memberExpression') {
    return undefined
  }
  if (
    memberExpression.data.data.expression.data.type === 'identifierExpression'
  ) {
    return [
      memberExpression.data.data.expression.data.data.identifier,
      memberExpression.data.data.memberName,
    ]
  }
  const flattenedChildren = flattenedMemberExpression(
    memberExpression.data.data.expression
  )
  if (!flattenedChildren) {
    return undefined
  }
  return flattenedChildren.concat(memberExpression.data.data.memberName)
}

function pathTo(node: SyntaxNode, id: string): SyntaxNode[] | void {
  if (id === ('id' in node.data ? node.data.id : node.data.data.id)) {
    return [node]
  }
  return subNodes(node).reduce<SyntaxNode[] | void>((prev, item) => {
    if (prev) {
      return prev
    }
    const subPath = pathTo(item, id)
    if (subPath) {
      return [node, ...subPath]
    }
    return undefined
  }, undefined)
}

export function declarationPathTo(node: SyntaxNode, id: string) {
  const path = pathTo(node, id)
  if (!path) {
    return []
  }
  return (path.filter(x => x.type === 'declaration') as Declaration[]).map(
    x => {
      switch (x.data.type) {
        case 'variable':
        case 'function':
        case 'enumeration':
        case 'namespace':
        case 'record':
        case 'importDeclaration': {
          return x.data.data.name.data.name
        }
        case 'placeholder': {
          return ''
        }
      }
    }
  )
}
