const parser = require('./pegjs/logicSwiftParser')

function parse(code, options) {
  return parser.parse(code, options)
}

function print(node) {
  const { type, data } = node

  switch (node.type) {
    case 'topLevelDeclarations': {
      const { declarations } = data

      return declarations
        .filter(declaration => declaration.type !== 'placeholder')
        .map(print)
        .join('\n\n')
    }
    case 'importDeclaration': {
      const {
        name: { name },
      } = data

      return `import ${name}`
    }
    case 'variable': {
      const {
        annotation,
        initializer,
        name: { name },
      } = data

      return `let ${name}: ${print(annotation)} = ${print(initializer)}`
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
  }
}

module.exports = {
  parse,
  print,
}
