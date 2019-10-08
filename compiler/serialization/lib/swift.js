const parser = require('./pegjs/logicSwiftParser')

function parse(code, options) {
  return parser.parse(code, options)
}

function print(node, options = {}) {
  const { indent = 0 } = options

  const { type, data } = node

  switch (node.type) {
    // Declaration statement
    case 'declaration': {
      const { content } = data

      return print(content)
    }
    case 'topLevelDeclarations': {
      const { declarations } = data

      return declarations
        .filter(node => node.type !== 'placeholder')
        .map(print)
        .join('\n\n')
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
        .map(print)
        .map(x => ' '.repeat(indent + 2) + x)
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
        .map(print)
        .map(x => ' '.repeat(indent + 2) + x)
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
        .map(x => ' '.repeat(indent + 2) + x)
        .join('\n\n')

      return `[
${printedExpressions}
]`
    }
  }
}

module.exports = {
  parse,
  print,
}
