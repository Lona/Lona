import { indentBlock } from '../../formatting'
import parser from './pegjs/logicSwiftParser'

export function parse(code: string, options?: {}) {
  return parser.parse(code, options)
}

export function print(node, options: { indent?: number } = {}) {
  const { indent = 2 } = options

  function printNode(node) {
    const { data } = node

    switch (node.type) {
      case 'program': {
        const { block } = data

        return block
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join('\n\n')
      }
      case 'topLevelDeclarations': {
        const { declarations } = data

        return declarations
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join('\n\n')
      }
      // Declaration statement
      case 'declaration': {
        const { content } = data

        return printNode(content)
      }
      case 'importDeclaration': {
        const {
          name: { name },
        } = data

        return `import ${name}`
      }
      case 'namespace': {
        const {
          name: { name },
          declarations,
        } = data

        const normalizedDeclarations = declarations.map(declaration => {
          return {
            ...declaration,
            data: { ...declaration.data, declarationModifier: 'static' },
          }
        })

        const printedDeclarations = normalizedDeclarations
          .filter(declaration => declaration.type !== 'placeholder')
          .map(x => printNode(x))
          .map(x => indentBlock(x, indent))
          .join('\n')

        return `enum ${name} {
${printedDeclarations}
}`
      }
      case 'record': {
        const {
          name: { name },
          declarations,
        } = data

        const printedDeclarations = declarations
          .filter(declaration => declaration.type !== 'placeholder')
          .map(x => printNode(x))
          .map(x => indentBlock(x, indent))
          .join('\n')

        return `struct ${name} {
${printedDeclarations}
}`
      }
      case 'variable': {
        const {
          annotation,
          initializer,
          name: { name },
          declarationModifier,
        } = data

        const printedDeclarationModifier = declarationModifier
          ? declarationModifier + ' '
          : ''

        return `${printedDeclarationModifier}let ${name}: ${printNode(
          annotation
        )} = ${printNode(initializer)}`
      }
      case 'typeIdentifier': {
        const {
          genericArguments,
          identifier: { string },
        } = data

        return genericArguments.length > 0
          ? `${string}<${genericArguments.map(printNode).join(', ')}>`
          : string
      }
      case 'functionCallExpression': {
        const { expression } = data

        const printedArguments = data.arguments
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .join(', ')

        return `${printNode(expression)}(${printedArguments})`
      }
      case 'argument': {
        const { expression, label } = data

        return label
          ? `${label}: ${printNode(expression)}`
          : printNode(expression)
      }
      case 'memberExpression': {
        const {
          expression,
          memberName: { string },
        } = data

        return printNode(expression) + '.' + string
      }
      case 'identifierExpression': {
        const {
          identifier: { string },
        } = data

        return string
      }
      case 'literalExpression': {
        const { literal } = data

        return printNode(literal)
      }
      case 'boolean':
      case 'number': {
        const { value } = data

        return value.toString()
      }
      case 'string': {
        const { value } = data

        return JSON.stringify(value)
      }
      case 'color': {
        const { value } = data

        return `#color(css: ${JSON.stringify(value)})`
      }
      case 'array': {
        const { value } = data

        const printedExpressions = value
          .filter(node => node.type !== 'placeholder')
          .map(printNode)
          .map(x => indentBlock(x, indent))
          .join('\n\n')

        return `[
${printedExpressions}
]`
      }
    }
  }

  return printNode(node)
}
