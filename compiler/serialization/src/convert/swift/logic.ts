import * as AST from '../../types/logic-ast'
import { indentBlock } from '../../formatting'
import parser from './pegjs/logicSwiftParser'

export function parse(code: string, options?: {}): AST.SyntaxNode {
  return parser.parse(code, options)
}

export function print(node: AST.SyntaxNode, options: { indent?: number } = {}) {
  const { indent = 2 } = options

  function printNode(node: AST.SyntaxNode): string {
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

        const normalizedDeclarations = declarations
          .filter(declaration => declaration.type !== 'placeholder')
          .map(declaration => {
            return {
              ...declaration,
              data: { ...declaration.data, declarationModifier: 'static' },
            } as AST.Declaration
          })

        const printedDeclarations = normalizedDeclarations
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
          ? `${declarationModifier} `
          : ''
        const printedAnnotation = annotation ? `: ${printNode(annotation)}` : ''
        const printedInitializer = initializer
          ? ` = ${printNode(initializer)}`
          : ''

        return `${printedDeclarationModifier}let ${name.name}${printedAnnotation}${printedInitializer}`
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
    }
    return ''
  }

  return printNode(node)
}
