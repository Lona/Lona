const { indentBlock } = require('./formatting')
const parser = require('./pegjs/logicSwiftParser')

function parse(code, options) {
  return parser.parse(code, options)
}

function printWithOptions(node, options = {}) {
  const { indent = 2 } = options

  function print(node) {
    const { type, data } = node

    switch (node.type) {
      case 'program': {
        const { block } = data

        return block
          .filter(node => node.type !== 'placeholder')
          .map(print)
          .join('\n\n')
      }
      case 'topLevelDeclarations': {
        const { declarations } = data

        return declarations
          .filter(node => node.type !== 'placeholder')
          .map(print)
          .join('\n\n')
      }
      // Declaration statement
      case 'declaration': {
        const { content } = data

        return print(content)
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
          .map(x => print(x))
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
          .map(x => print(x))
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

        return `${printedDeclarationModifier}let ${name}: ${print(
          annotation
        )} = ${print(initializer)}`
      }
      case 'typeIdentifier': {
        const {
          genericArguments,
          identifier: { string },
        } = data

        return genericArguments.length > 0
          ? `${string}<${genericArguments.map(print).join(', ')}>`
          : string
      }
      case 'functionCallExpression': {
        const { expression } = data

        const printedArguments = data.arguments
          .filter(node => node.type !== 'placeholder')
          .map(print)
          .join(', ')

        return `${print(expression)}(${printedArguments})`
      }
      case 'argument': {
        const { expression, label } = data

        return label ? `${label}: ${print(expression)}` : print(expression)
      }
      case 'memberExpression': {
        const {
          expression,
          memberName: { string },
        } = data

        return print(expression) + '.' + string
      }
      case 'identifierExpression': {
        const {
          identifier: { string },
        } = data

        return string
      }
      case 'literalExpression': {
        const { literal } = data

        return print(literal)
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
          .map(print)
          .map(x => indentBlock(x, indent))
          .join('\n\n')

        return `[
${printedExpressions}
]`
      }
    }
  }

  return print(node)
}

module.exports = {
  parse,
  print: printWithOptions,
}
