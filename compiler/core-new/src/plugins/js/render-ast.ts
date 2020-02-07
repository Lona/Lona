import {
  builders,
  group,
  indent,
  join,
  prefixAll,
  Doc,
  print,
} from '../../utils/printer'
import { assertNever } from '../../utils'

import * as JSAST from './js-ast'

type Options = {
  outputFile?: (filePath: string, data: string) => Promise<void>
  reporter: {
    log(...args: any[]): void
    warn(...args: any[]): void
    error(...args: any[]): void
  }
}

const printerOptions = { printWidth: 120, tabWidth: 2, useTabs: false }

let renderBinaryOperator = (x: JSAST.binaryOperator) => {
  switch (x) {
    case JSAST.binaryOperator.Eq:
      return '==='
    case JSAST.binaryOperator.LooseEq:
      return '=='
    case JSAST.binaryOperator.Neq:
      return '!=='
    case JSAST.binaryOperator.LooseNeq:
      return '!='
    case JSAST.binaryOperator.Gt:
      return '>'
    case JSAST.binaryOperator.Gte:
      return '>='
    case JSAST.binaryOperator.Lt:
      return '<'
    case JSAST.binaryOperator.Lte:
      return '<='
    case JSAST.binaryOperator.Plus:
      return '+'
    case JSAST.binaryOperator.Minus:
      return '-'
    case JSAST.binaryOperator.And:
      return '&&'
    case JSAST.binaryOperator.Or:
      return '||'
    case JSAST.binaryOperator.Noop:
      return ''
  }
}

const smartPath = (path: string[], pathNode: string) =>
  pathNode === path[0]
    ? pathNode
    : /\W/g.test(pathNode)
    ? `['${pathNode}']`
    : builders.concat([builders.softline, '.', pathNode])

function render(ast: JSAST.JSNode, options: Options): Doc {
  switch (ast.type) {
    case 'InterfaceDeclaration':
      return builders.concat([
        'interface ',
        ast.data.data.identifier,
        renderTypeParameters(ast.data.data.typeParameters),
        ' ',
        renderObjectType(ast.data.data.objectType),
      ])
    case 'TypeAliasDeclaration':
      return builders.concat([
        'type ',
        ast.data.data.identifier,
        renderTypeParameters(ast.data.data.typeParameters),
        ' = ',
        renderType(ast.data.data.type),
      ])
    case 'Identifier':
      return group(ast.data.map(pathNode => smartPath(ast.data, pathNode)))
    case 'Literal':
      return JSON.stringify(ast.data.data)
    case 'StringLiteral':
      return builders.concat(['"', ast.data.replace(/"/g, '\\"'), '"'])
    case 'VariableDeclaration':
      return group(['let ', render(ast.data, options)])
    case 'AssignmentExpression':
      return builders.fill([
        group([render(ast.data.left, options), builders.line, '=']),
        ' ',
        render(ast.data.right, options),
      ])
    case 'BinaryExpression':
      return group([
        render(ast.data.left, options),
        ' ',
        renderBinaryOperator(ast.data.operator),
        builders.line,
        render(ast.data.right, options),
      ])
    case 'UnaryExpression':
      return ast.data.prefix
        ? builders.concat([
            ast.data.operator,
            render(ast.data.argument, options),
          ])
        : builders.concat([
            render(ast.data.argument, options),
            ast.data.operator,
          ])
    case 'IfStatement': {
      const ifPart = builders.concat([
        group([
          'if (',
          indent([
            builders.softline,
            render(ast.data.test, options),
            builders.softline,
            ') ',
          ]),
        ]),
        renderBlockBody(ast.data.consequent, true, options),
      ])

      if (ast.data.alternate.length === 0) {
        return ifPart
      }
      if (
        ast.data.alternate.length === 1 &&
        ast.data.alternate[0].type === 'IfStatement'
      ) {
        return builders.concat([
          ifPart,
          ' else ',
          render(ast.data.alternate[0], options),
        ])
      }

      return builders.concat([
        ifPart,
        ' else ',
        renderBlockBody(ast.data.alternate, true, options),
      ])
    }
    case 'ConditionalExpression':
      return group([
        '(',
        indent([
          builders.line,
          render(ast.data.test, options),
          indent([
            builders.line,
            '? ',
            render(ast.data.consequent, options),
            builders.line,
            ': ',
            render(ast.data.alternate, options),
          ]),
        ]),
        builders.line,
        ')',
      ])
    case 'ImportDefaultSpecifier':
      return ast.data
    case 'ImportSpecifier':
      return ast.data.local
        ? `${ast.data.imported} as ${ast.data.local}`
        : ast.data.imported
    case 'ImportDeclaration': {
      const defaultSpecifiers = ast.data.specifiers.filter(
        x => x.type === 'ImportDefaultSpecifier'
      )
      const specifiers = ast.data.specifiers.filter(
        x => x.type === 'ImportSpecifier'
      )

      const namedImports = group([
        '{',
        builders.line,
        join(
          specifiers.map(x => render(x, options)),
          ', '
        ),
        builders.line,
        '}',
      ])
      const imports = group(
        join(
          defaultSpecifiers
            .map(x => render(x, options))
            .concat(specifiers.length > 0 ? namedImports : []),
          ', '
        )
      )

      return group([
        'import',
        ' ',
        imports,
        ' ',
        'from',
        indent([builders.line, `"${ast.data.source}"`]),
      ])
    }
    case 'ClassDeclaration': {
      const decl = ast.data.superClass
        ? ['class', ast.data.id, 'extends', ast.data.superClass]
        : ['class', ast.data.id]

      return builders.concat([
        group([join(decl, builders.line), ' {']),
        indent(
          prefixAll(
            ast.data.body.map(x => render(x, options)),
            builders.hardline
          )
        ),
        builders.hardline,
        '}',
      ])
    }
    case 'MethodDefinition':
      return group([ast.data.key, render(ast.data.value, options)])
    case 'FunctionExpression': {
      /* TODO: o.id */
      const parameterList = join(
        ast.data.params.map(x => render(x, options)),
        builders.line
      )
      return group([
        '(',
        parameterList,
        ') ',
        renderBlockBody(ast.data.body, false, options),
      ])
    }
    case 'ArrowFunctionExpression': {
      const parameterList = join(
        ast.data.params.map(x => render(x, options)),
        builders.line
      )

      if (ast.data.body.length === 1 && ast.data.body[0].type === 'Return') {
        if (ast.data.body[0].data.type === 'ObjectLiteral') {
          return builders.concat([
            group(['(', parameterList, ') => (']),
            render(ast.data.body[0].data, options),
            ')',
          ])
        }
        return builders.concat([
          group(['(', parameterList, ') => (']),
          indent([builders.line, render(ast.data.body[0].data, options)]),
          builders.line,
          ')',
        ])
      }

      return group([
        '(',
        parameterList,
        ') => ',
        renderBlockBody(ast.data.body, false, options),
      ])
    }
    case 'CallExpression': {
      const parameterList = join(
        ast.data.arguments.map(x => render(x, options)),
        builders.line
      )
      return builders.fill([
        render(ast.data.callee, options),
        '(',
        parameterList,
        ')',
      ])
    }
    case 'MemberExpression':
      return builders.concat([
        render(ast.data.expression, options),
        builders.softline,
        '.',
        ast.data.memberName,
      ])
    case 'Return':
      return group([
        group('return '),
        builders.ifBreak('(', ''),
        indent([builders.softline, render(ast.data, options)]),
        builders.softline,
        builders.ifBreak(')', ''),
        ';',
      ])
    case 'JSXAttribute':
      return builders.concat([
        ast.data.name,
        '={',
        render(ast.data.value, options),
        '}',
      ])
    case 'JSXElement': {
      const hasAttributes = ast.data.attributes.length > 0
      const hasChildren = ast.data.content.length > 0

      const openingContent = join(
        ast.data.attributes.map(x => render(x, options)),
        builders.line
      )
      const openingTag = group([
        '<',
        ast.data.tag,
        hasAttributes
          ? builders.concat([
              indent([builders.line, openingContent]),
              builders.softline,
            ])
          : '',
        hasChildren ? '>' : builders.concat([builders.line, '/>']),
      ])

      if (!hasChildren) {
        return openingTag
      }

      const closingTag = group(['</', ast.data.tag, '>'])
      const children = indent([
        builders.line,
        join(
          ast.data.content.map(x => render(x, options)),
          builders.line
        ),
      ])

      return builders.concat([openingTag, children, builders.line, closingTag])
    }
    case 'JSXExpressionContainer':
      return group([
        '{',
        indent([builders.softline, render(ast.data, options)]),
        builders.softline,
        '}',
      ])
    case 'JSXSpreadAttribute':
      return builders.concat(['{...', render(ast.data, options), '}'])
    case 'SpreadElement':
      return builders.concat(['...', render(ast.data, options)])
    case 'ArrayLiteral': {
      const maybeLine = ast.data.length > 0 ? builders.line : ''
      const body = join(
        ast.data.map(x => render(x, options)),
        [',', builders.line]
      )

      return group(['[', indent([maybeLine, body]), maybeLine, ']'])
    }
    case 'ObjectLiteral': {
      const maybeLine = ast.data.length > 0 ? builders.line : ''
      const body = join(
        ast.data.map(x => render(x, options)),
        [',', builders.line]
      )

      return group(['{', indent([maybeLine, body]), maybeLine, '}'])
    }
    case 'Property': {
      const maybeValue = ast.data.value
        ? builders.concat([': ', render(ast.data.value, options)])
        : ''

      if (ast.data.key.type === 'Identifier') {
        return /\W/g.test(ast.data.key.data[0])
          ? group([`'${ast.data.key.data[0]}'`, maybeValue])
          : group([ast.data.key.data[0], maybeValue])
      }
      return group([render(ast.data.key, options), maybeValue])
    }
    case 'ExportDefaultDeclaration':
      return builders.concat([
        'export default ',
        render(ast.data, options),
        ';',
      ])
    case 'ExportNamedDeclaration':
      return builders.concat(['export ', render(ast.data, options), ';'])
    case 'Program':
      return join(
        ast.data.map(x => render(x, options)),
        builders.hardline
      )
    case 'LineEndComment':
      return builders.concat([
        render(ast.data.line, options),
        builders.lineSuffix(` // ${ast.data.comment}`),
      ])
    case 'Empty':
      return ''
    default: {
      // TODO: assert never
      return ''
    }
  }
}

const renderTypeParameters = (parameters: JSAST.JSType[]) => {
  if (!parameters.length) {
    return ''
  }
  return builders.concat([
    '<',
    join(
      parameters.map(x => renderType(x)),
      builders.line
    ),
    '>',
  ])
}

const renderObjectType = (objectType: JSAST.ObjectType) => {
  const renderedMembers = join(
    objectType.members.map(x => {
      if (x.type === 'PropertySignature') {
        if (x.data.type) {
          if (x.data.type.type === 'TypeReference') {
            return builders.concat([
              x.data.name,
              '?: ',
              renderType(x.data.type.data.arguments[0]),
            ])
          }
          return builders.concat([x.data.name, '? ', renderType(x.data.type)])
        }
        return x.data.name
      }
      assertNever(x.type)
    }),
    [',', builders.hardline]
  )

  return builders.concat([
    '{',
    indent([builders.hardline, renderedMembers]),
    builders.hardline,
    '}',
  ])
}

const renderType = (type: JSAST.JSType): Doc => {
  switch (type.type) {
    case 'LiteralType':
      return `'${type.data}'`
    case 'TypeReference': {
      if (!type.data.arguments.length) {
        return type.data.name
      }
      return builders.concat([
        '<',
        join(
          type.data.arguments.map(x => renderType(x)),
          builders.line
        ),
        '>',
      ])
    }
    case 'UnionType':
      return join(type.data.map(renderType), ' | ')
    case 'TupleType':
      return builders.concat([
        '[',
        builders.softline,
        join(type.data.map(renderType), ', '),
        builders.softline,
        ' ]',
      ])
    case 'ObjectType':
      return renderObjectType(type.data)
  }
}

const renderBlockBody = (
  nodes: JSAST.JSNode[],
  preferMultiLine: boolean,
  options: Options
) => {
  const renderSingleLineBlock = (node: JSAST.JSNode) =>
    builders.concat([
      '{',
      indent([builders.line, render(node, options)]),
      builders.line,
      '}',
    ])

  const renderMultiLineBlock = (nodes: JSAST.JSNode[]) =>
    builders.concat([
      '{',
      indent(
        prefixAll(
          nodes.map(x => render(x, options)),
          builders.hardline
        )
      ),
      builders.hardline,
      '}',
    ])

  if (!nodes.length) {
    return '{}'
  }

  if (nodes.length === 1 && !preferMultiLine) {
    if (nodes[0].type === 'IfStatement') {
      return renderMultiLineBlock(nodes)
    }
    return renderSingleLineBlock(nodes[0])
  }
  return renderMultiLineBlock(nodes)
}

export default function toString(ast: JSAST.JSNode, options: Options) {
  return print(render(ast, options), printerOptions)
}
