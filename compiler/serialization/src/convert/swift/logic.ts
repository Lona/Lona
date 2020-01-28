import * as AST from '../../types/logic-ast'
import { indentBlock } from '../../formatting'
import parser from './pegjs/logicSwiftParser'
import { visit } from './visit-logic-ast'

export function parse(code: string, options?: {}): AST.SyntaxNode {
  const ast = parser.parse(code, options)

  visit(ast, node => {
    if (node.type !== 'argument') {
      return
    }
    const arg = node.data.expression

    // in case we have an argument `Optional.value(x)`, we just want `x`
    if (
      arg.type === 'functionCallExpression' &&
      arg.data.expression.type === 'memberExpression' &&
      arg.data.expression.data.memberName.string === 'value' &&
      arg.data.expression.data.expression.type === 'identifierExpression' &&
      arg.data.expression.data.expression.data.identifier.string ===
        'Optional' &&
      arg.data.arguments[0].type === 'argument'
    ) {
      node.data.expression = arg.data.arguments[0].data.expression
    }
  })

  return ast
}

export function print(node: AST.SyntaxNode, options: { indent?: number } = {}) {
  const { indent = 2 } = options

  function printNode(node: AST.SyntaxNode): string {
    if (!('type' in node)) {
      // pattern or identifier
      return
    }
    switch (node.type) {
      case 'program': {
        const { block } = node.data

        return block
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join('\n\n')
      }
      case 'topLevelDeclarations': {
        const { declarations } = node.data

        return declarations
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join('\n\n')
      }
      // Declaration statement
      case 'declaration': {
        if ('content' in node.data) {
          return printNode(node.data.content)
        }
        break
      }
      case 'importDeclaration': {
        const { name } = node.data

        return `import ${name.name}`
      }
      case 'namespace': {
        const { name, declarations } = node.data

        const normalizedDeclarations = declarations.map(declaration => {
          return {
            ...declaration,
            data: { ...declaration.data, declarationModifier: 'static' },
          }
        })

        const printedDeclarations = normalizedDeclarations
          .filter(declaration => declaration.type !== 'placeholder')
          // @ts-ignore
          .map(x => printNode(x))
          .map(x => indentBlock(x, indent))
          .join('\n')

        return `enum ${name.name} {
${printedDeclarations}
}`
      }
      case 'record': {
        const { name, declarations } = node.data

        const printedDeclarations = declarations
          .filter(declaration => declaration.type !== 'placeholder')
          .map(x => printNode(x))
          .map(x => indentBlock(x, indent))
          .join('\n')

        return `struct ${name.name} {
${printedDeclarations}
}`
      }
      case 'variable': {
        const { annotation, initializer, name, declarationModifier } = node.data

        const printedDeclarationModifier = declarationModifier
          ? declarationModifier + ' '
          : ''

        return `${printedDeclarationModifier}let ${name.name}: ${printNode(
          annotation
        )} = ${printNode(initializer)}`
      }
      case 'typeIdentifier': {
        const { genericArguments, identifier } = node.data

        return genericArguments.length > 0
          ? `${identifier.string}<${genericArguments
              .map(printNode)
              .join(', ')}>`
          : identifier.string
      }
      case 'functionCallExpression': {
        const { expression } = node.data

        const printedArguments = node.data.arguments
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join(', ')

        return `${printNode(expression)}(${printedArguments})`
      }
      case 'argument': {
        const { expression, label } = node.data

        return label
          ? `${label}: ${printNode(expression)}`
          : printNode(expression)
      }
      case 'memberExpression': {
        const { expression, memberName } = node.data

        return printNode(expression) + '.' + memberName.string
      }
      case 'identifierExpression': {
        const { identifier } = node.data

        return identifier.string
      }
      case 'literalExpression': {
        const { literal } = node.data

        return printNode(literal)
      }
      case 'boolean':
      case 'number': {
        const { value } = node.data

        return value.toString()
      }
      case 'string': {
        const { value } = node.data

        return JSON.stringify(value)
      }
      case 'color': {
        const { value } = node.data

        return `#color(css: ${JSON.stringify(value)})`
      }
      case 'array': {
        const { value } = node.data

        const printedExpressions = value
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .map(x => indentBlock(x, indent))
          .join('\n\n')

        return `[
${printedExpressions}
]`
      }
      default: {
        return ''
      }
    }
  }

  return printNode(node)
}
