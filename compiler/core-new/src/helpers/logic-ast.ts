import { LogicAST } from '@lona/serialization'
import uuid from '../utils/uuid'

export { LogicAST as AST }

export function joinPrograms(
  programs: (LogicAST.Program | void)[]
): LogicAST.Program {
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

export function isStatement(
  node: LogicAST.SyntaxNode
): node is LogicAST.Statement {
  return (
    node.type === 'loop' ||
    node.type === 'branch' ||
    node.type === 'declaration' ||
    node.type === 'expression'
  )
}

export function isDeclaration(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier
): node is LogicAST.Declaration {
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

export function isTypeAnnotation(
  node: LogicAST.SyntaxNode
): node is LogicAST.TypeAnnotation {
  return (
    node.type === 'typeIdentifier' ||
    node.type === 'functionType' ||
    node.type === 'placeholder'
  )
}

export function makeProgram(
  node: LogicAST.SyntaxNode
): LogicAST.Program | void {
  if (node.type === 'program') {
    return node
  }
  if (isStatement(node)) {
    return { type: 'program', data: { id: uuid(), block: [node] } }
  }
  if (isDeclaration(node)) {
    return makeProgram({
      type: 'declaration',
      data: { id: uuid(), content: node },
    })
  }
  if (node.type === 'topLevelDeclarations') {
    return {
      type: 'program',
      data: {
        id: uuid(),
        block: node.data.declarations.map(x => ({
          type: 'declaration',
          data: { id: uuid(), content: x },
        })),
      },
    }
  }
}

export function getPattern(node: LogicAST.SyntaxNode): LogicAST.Pattern | void {
  if (
    node.type === 'variable' ||
    node.type === 'enumeration' ||
    node.type === 'namespace' ||
    node.type === 'record' ||
    node.type === 'importDeclaration' ||
    node.type === 'enumerationCase' ||
    node.type === 'function'
  ) {
    return node.data.name
  }

  if (node.type === 'parameter') {
    if ('localName' in node.data) {
      return node.data.localName
    }
    return node.data.name
  }
}

export function getIdentifier(
  node: LogicAST.SyntaxNode
): LogicAST.Identifier | void {
  if (node.type === 'identifierExpression' || node.type === 'typeIdentifier') {
    return node.data.identifier
  }
  if (node.type === 'memberExpression') {
    return node.data.memberName
  }
}

export function subNodes(node: LogicAST.SyntaxNode): LogicAST.SyntaxNode[] {
  if (node.type === 'loop') {
    return ([node.data.expression] as LogicAST.SyntaxNode[]).concat(
      node.data.block
    )
  }
  if (node.type === 'branch') {
    return ([node.data.condition] as LogicAST.SyntaxNode[]).concat(
      node.data.block
    )
  }
  if (node.type === 'declaration') {
    return [node.data.content]
  }
  if (node.type === 'expression') {
    return [node.data.expression]
  }

  if (node.type === 'variable') {
    return ([] as LogicAST.SyntaxNode[])
      .concat(node.data.annotation ? [node.data.annotation] : [])
      .concat(node.data.initializer ? [node.data.initializer] : [])
  }
  if (node.type === 'function') {
    return ([node.data.returnType] as LogicAST.SyntaxNode[])
      .concat(node.data.genericParameters)
      .concat(node.data.parameters)
      .concat(node.data.block)
  }
  if (node.type === 'enumeration') {
    return ([] as LogicAST.SyntaxNode[])
      .concat(node.data.genericParameters)
      .concat(node.data.cases)
  }
  if (node.type === 'namespace') {
    return ([] as LogicAST.SyntaxNode[]).concat(node.data.declarations)
  }
  if (node.type === 'record') {
    return ([] as LogicAST.SyntaxNode[])
      .concat(node.data.declarations)
      .concat(node.data.genericParameters)
  }
  if (node.type === 'importDeclaration') {
    return []
  }

  if (node.type === 'binaryExpression') {
    return [node.data.left, node.data.right, node.data.op]
  }
  if (node.type === 'identifierExpression') {
    return []
  }
  if (node.type === 'functionCallExpression') {
    return ([node.data.expression] as LogicAST.SyntaxNode[]).concat(
      node.data.arguments
    )
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
    return []
  }

  if (node.type === 'value') {
    return [node.data.expression]
  }

  if (node.type === 'typeIdentifier') {
    return node.data.genericArguments
  }
  if (node.type === 'functionType') {
    return ([node.data.returnType] as LogicAST.SyntaxNode[]).concat(
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

export function flattenedMemberExpression(
  memberExpression: LogicAST.Expression
): LogicAST.Identifier[] | void {
  if (memberExpression.type === 'identifierExpression') {
    return [memberExpression.data.identifier]
  }
  if (memberExpression.type !== 'memberExpression') {
    return undefined
  }
  if (memberExpression.data.expression.type === 'identifierExpression') {
    return [
      memberExpression.data.expression.data.identifier,
      memberExpression.data.memberName,
    ]
  }
  const flattenedChildren = flattenedMemberExpression(
    memberExpression.data.expression
  )
  if (!flattenedChildren) {
    return undefined
  }
  return flattenedChildren.concat(memberExpression.data.memberName)
}

export function getNode(
  rootNode: LogicAST.SyntaxNode,
  id: string
): LogicAST.SyntaxNode | void {
  if (rootNode.data.id === id) {
    return rootNode
  }

  if ('name' in rootNode.data && rootNode.data.name.id === id) {
    return rootNode
  }

  const children = subNodes(rootNode)

  for (let child of children) {
    const node = getNode(child, id)
    if (node) {
      return node
    }
  }
}

function pathTo(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier,
  id: string
): (LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier)[] | void {
  if (id === ('id' in node ? node.id : node.data.id)) {
    return [node]
  }
  if (!('type' in node)) {
    return undefined
  }
  return subNodes(node).reduce<
    (LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier)[] | void
  >((prev, item) => {
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

export function declarationPathTo(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier,
  id: string
) {
  const path = pathTo(node, id)
  if (!path) {
    return []
  }
  return path.filter(isDeclaration).map(x => {
    switch (x.type) {
      case 'variable':
      case 'function':
      case 'enumeration':
      case 'namespace':
      case 'record':
      case 'importDeclaration': {
        return x.data.name.name
      }
      case 'placeholder': {
        return ''
      }
    }
  })
}
