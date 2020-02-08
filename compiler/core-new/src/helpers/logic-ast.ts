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
        [] as LogicAST.Statement[]
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
): LogicAST.Program | undefined {
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

  return undefined
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

export function subNodes(
  node: LogicAST.SyntaxNode
): {
  nodes: LogicAST.SyntaxNode[]
  patterns: LogicAST.Pattern[]
  identifiers: LogicAST.Identifier[]
} {
  if (node.type === 'loop') {
    return {
      nodes: ([node.data.expression] as LogicAST.SyntaxNode[]).concat(
        node.data.block
      ),
      patterns: [node.data.pattern],
      identifiers: [],
    }
  }
  if (node.type === 'branch') {
    return {
      nodes: ([node.data.condition] as LogicAST.SyntaxNode[]).concat(
        node.data.block
      ),
      patterns: [],
      identifiers: [],
    }
  }
  if (node.type === 'declaration') {
    return { nodes: [node.data.content], patterns: [], identifiers: [] }
  }
  if (node.type === 'expression') {
    return { nodes: [node.data.expression], patterns: [], identifiers: [] }
  }

  if (node.type === 'variable') {
    return {
      nodes: ([] as LogicAST.SyntaxNode[])
        .concat(node.data.annotation ? [node.data.annotation] : [])
        .concat(node.data.initializer ? [node.data.initializer] : []),
      patterns: [node.data.name],
      identifiers: [],
    }
  }
  if (node.type === 'function') {
    return {
      nodes: ([node.data.returnType] as LogicAST.SyntaxNode[])
        .concat(node.data.genericParameters)
        .concat(node.data.parameters)
        .concat(node.data.block),
      patterns: [node.data.name],
      identifiers: [],
    }
  }
  if (node.type === 'enumeration') {
    return {
      nodes: ([] as LogicAST.SyntaxNode[])
        .concat(node.data.genericParameters)
        .concat(node.data.cases),
      patterns: [node.data.name],
      identifiers: [],
    }
  }
  if (node.type === 'namespace') {
    return {
      nodes: node.data.declarations,
      patterns: [node.data.name],
      identifiers: [],
    }
  }
  if (node.type === 'record') {
    return {
      nodes: ([] as LogicAST.SyntaxNode[])
        .concat(node.data.declarations)
        .concat(node.data.genericParameters),
      patterns: [node.data.name],
      identifiers: [],
    }
  }
  if (node.type === 'importDeclaration') {
    return { nodes: [], patterns: [node.data.name], identifiers: [] }
  }

  if (node.type === 'binaryExpression') {
    return {
      nodes: [node.data.left, node.data.right, node.data.op],
      patterns: [],
      identifiers: [],
    }
  }
  if (node.type === 'identifierExpression') {
    return { nodes: [], patterns: [], identifiers: [node.data.identifier] }
  }
  if (node.type === 'functionCallExpression') {
    return {
      nodes: ([node.data.expression] as LogicAST.SyntaxNode[]).concat(
        node.data.arguments
      ),
      patterns: [],
      identifiers: [],
    }
  }
  if (node.type === 'literalExpression') {
    return { nodes: [node.data.literal], patterns: [], identifiers: [] }
  }
  if (node.type === 'memberExpression') {
    return {
      nodes: [node.data.expression],
      patterns: [],
      identifiers: [node.data.memberName],
    }
  }

  if (node.type === 'program') {
    return { nodes: node.data.block, patterns: [], identifiers: [] }
  }

  if (node.type === 'parameter') {
    if ('localName' in node.data) {
      return {
        nodes: [node.data.annotation, node.data.defaultValue],
        patterns: [node.data.localName],
        identifiers: [],
      }
    }
    return { nodes: [], patterns: [node.data.name], identifiers: [] }
  }

  if (node.type === 'value') {
    return { nodes: [node.data.expression], patterns: [], identifiers: [] }
  }

  if (node.type === 'typeIdentifier') {
    return {
      nodes: node.data.genericArguments,
      patterns: [],
      identifiers: [node.data.identifier],
    }
  }
  if (node.type === 'functionType') {
    return {
      nodes: ([node.data.returnType] as LogicAST.SyntaxNode[]).concat(
        node.data.argumentTypes
      ),
      patterns: [],
      identifiers: [],
    }
  }

  if (node.type === 'array') {
    return { nodes: node.data.value, patterns: [], identifiers: [] }
  }

  if (node.type === 'topLevelParameters') {
    return { nodes: node.data.parameters, patterns: [], identifiers: [] }
  }

  if (node.type === 'enumerationCase') {
    return {
      nodes: node.data.associatedValueTypes,
      patterns: [node.data.name],
      identifiers: [],
    }
  }

  if (node.type === 'topLevelDeclarations') {
    return { nodes: node.data.declarations, patterns: [], identifiers: [] }
  }

  if (node.type === 'argument') {
    return { nodes: [node.data.expression], patterns: [], identifiers: [] }
  }

  return { nodes: [], patterns: [], identifiers: [] }
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
): LogicAST.SyntaxNode | undefined {
  if (rootNode.data.id === id) {
    return rootNode
  }

  if ('name' in rootNode.data && rootNode.data.name.id === id) {
    return rootNode
  }

  const children = subNodes(rootNode).nodes

  for (let child of children) {
    const node = getNode(child, id)
    if (node) {
      return node
    }
  }

  return undefined
}

function pathTo(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier,
  id: string
):
  | (LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier)[]
  | undefined {
  if (id === ('id' in node ? node.id : node.data.id)) {
    return [node]
  }
  if (!('type' in node)) {
    return undefined
  }

  const { nodes, patterns, identifiers } = subNodes(node)

  const matchingPattern = patterns.find(x => x.id === id)
  if (matchingPattern) {
    return [matchingPattern]
  }

  const matchingIdentifier = identifiers.find(x => x.id === id)
  if (matchingIdentifier) {
    return [matchingIdentifier]
  }

  return nodes.reduce<
    (LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier)[] | undefined
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

export function findNode(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier,
  id: string
) {
  const path = pathTo(node, id)
  if (!path) {
    return undefined
  }

  return path[path.length - 1]
}

export function findParentNode(
  node: LogicAST.SyntaxNode | LogicAST.Pattern | LogicAST.Identifier,
  id: string
) {
  const path = pathTo(node, id)
  if (!path || path.length <= 1) {
    return undefined
  }

  return path[path.length - 2]
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
