import { doc, Doc } from 'prettier'
import { parseCSSColor } from 'csscolorparser'

import * as SwiftAST from '../../types/swift-ast'

type Options = {
  outputFile?: (filePath: string, data: string) => Promise<void>
  reporter: {
    log(...args: any[]): void
    warn(...args: any[]): void
    error(...args: any[]): void
  }
}

const printerOptions = { printWidth: 120, tabWidth: 2, useTabs: false }
const builders = doc.builders

function group(x: Doc[] | Doc): Doc {
  if (Array.isArray(x)) {
    return builders.group(builders.concat(x))
  }
  return builders.group(x)
}
function indent(x: Doc[] | Doc): Doc {
  if (Array.isArray(x)) {
    return builders.indent(builders.concat(x))
  }
  return builders.indent(x)
}

function join(x: Doc[], separator: Doc | Doc[]): Doc {
  if (Array.isArray(separator)) {
    return builders.join(builders.concat(separator), x)
  }
  return builders.join(separator, x)
}

function prefixAll(x: Doc[], prefix: Doc): Doc[] {
  return x.map(y => builders.concat([prefix, y]))
}

const reservedWords = ['true', 'false', 'default', 'case', 'break']

const stringWithSafeIdentifier = (id: string) => {
  if (/^\d/.test(id)) {
    return '_' + id
  } else if (reservedWords.indexOf(id) !== -1) {
    return '`' + id + '`'
  } else {
    return id
  }
}

function nodeWithSafeIdentifier(id: SwiftAST.SwiftNode): SwiftAST.SwiftNode {
  if (id.type === 'SwiftIdentifier') {
    if (/$\d/.test(id.data)) {
      return {
        type: 'SwiftIdentifier',
        data: `_${id.data}`,
      }
    }
    return {
      type: 'SwiftIdentifier',
      data: stringWithSafeIdentifier(id.data),
    }
  }
  return {
    type: 'SwiftIdentifier',
    data: '$ Bad call to nodeWithSafeIdentifier',
  }
}

function parseColorDefault(color: string, fallback: string) {
  let parsed = parseCSSColor(color)
  if (!parsed) {
    parsed = parseCSSColor(fallback)
  }
  if (!parsed) {
    return { r: 0, g: 0, b: 0, a: 0 }
  }
  return {
    r: parsed[0],
    g: parsed[1],
    b: parsed[2],
    a: parsed[3],
  }
}

function renderDeclarationModifier(node: SwiftAST.DeclarationModifier) {
  switch (node) {
    case SwiftAST.DeclarationModifier.ClassModifier:
      return 'class'
    case SwiftAST.DeclarationModifier.ConvenienceModifier:
      return 'convenience'
    case SwiftAST.DeclarationModifier.DynamicModifier:
      return 'dynamic'
    case SwiftAST.DeclarationModifier.FileprivateModifier:
      return 'fileprivate'
    case SwiftAST.DeclarationModifier.FinalModifier:
      return 'final'
    case SwiftAST.DeclarationModifier.InfixModifier:
      return 'infix'
    case SwiftAST.DeclarationModifier.InternalModifier:
      return 'internal'
    case SwiftAST.DeclarationModifier.LazyModifier:
      return 'lazy'
    case SwiftAST.DeclarationModifier.MutatingModifier:
      return 'mutating'
    case SwiftAST.DeclarationModifier.NonmutatingModifier:
      return 'nonmutating'
    case SwiftAST.DeclarationModifier.OpenModifier:
      return 'open'
    case SwiftAST.DeclarationModifier.OptionalModifier:
      return 'optional'
    case SwiftAST.DeclarationModifier.OverrideModifier:
      return 'override'
    case SwiftAST.DeclarationModifier.PostfixModifier:
      return 'postfix'
    case SwiftAST.DeclarationModifier.PrefixModifier:
      return 'prefix'
    case SwiftAST.DeclarationModifier.PrivateModifier:
      return 'private'
    case SwiftAST.DeclarationModifier.PublicModifier:
      return 'public'
    case SwiftAST.DeclarationModifier.RequiredModifier:
      return 'required'
    case SwiftAST.DeclarationModifier.StaticModifier:
      return 'static'
    case SwiftAST.DeclarationModifier.UnownedModifier:
      return 'unowned'
    case SwiftAST.DeclarationModifier.UnownedSafeModifier:
      return 'unownedsafe'
    case SwiftAST.DeclarationModifier.UnownedUnsafeModifier:
      return 'unownedunsafe'
    case SwiftAST.DeclarationModifier.WeakModifier:
      return 'weak'
  }
}

function render(ast: SwiftAST.SwiftNode, options: Options): Doc {
  switch (ast.type) {
    case 'SwiftIdentifier':
      return ast.data
    case 'LiteralExpression':
      return renderLiteral(ast.data, options)
    case 'MemberExpression':
      return group(
        indent(
          join(
            ast.data.map(x => render(x, options)),
            [builders.softline, '.']
          )
        )
      )
    case 'TupleExpression':
      return builders.concat(
        (['('] as Doc[])
          .concat(
            group(
              indent(
                join(
                  ast.data.map(x => render(x, options)),
                  [',', builders.line]
                )
              )
            )
          )
          .concat([')'])
      )
    case 'BinaryExpression': {
      if (
        ast.data.right.type === 'LiteralExpression' &&
        ast.data.right.data.type === 'Array'
      ) {
        return group([
          render(ast.data.left, options),
          ' ',
          ast.data.operator,
          ' ',
          render(ast.data.right, options),
        ])
      }
      return group([
        render(ast.data.left, options),
        ' ',
        ast.data.operator,
        indent([builders.line, render(ast.data.right, options)]),
      ])
    }
    case 'PrefixExpression': {
      if (
        ast.data.expression.type === 'LiteralExpression' ||
        ast.data.expression.type === 'SwiftIdentifier' ||
        ast.data.expression.type === 'MemberExpression'
      ) {
        return builders.concat([
          ast.data.operator,
          render(ast.data.expression, options),
        ])
      }
      return group([
        ast.data.operator,
        '(',
        builders.softline,
        render(ast.data.expression, options),
        builders.softline,
        ')',
      ])
    }
    case 'TryExpression': {
      const operator =
        ast.data.forced && !ast.data.optional
          ? 'try!'
          : !ast.data.forced && ast.data.optional
          ? 'try?'
          : 'try'
      return builders.concat([
        operator,
        builders.line,
        render(ast.data.expression, options),
      ])
    }
    case 'ClassDeclaration': {
      const maybeFinal = ast.data.isFinal
        ? builders.concat(['final', builders.line])
        : ''
      const maybeModifier = ast.data.modifier
        ? builders.concat([
            renderDeclarationModifier(ast.data.modifier),
            builders.line,
          ])
        : ''
      const maybeInherits = ast.data.inherits.length
        ? builders.concat([
            ': ',
            builders.join(
              ', ',
              ast.data.inherits.map(x => renderTypeAnnotation(x, options))
            ),
          ])
        : ''
      const opening = group([
        maybeModifier,
        maybeFinal,
        'class',
        builders.line,
        ast.data.name,
        maybeInherits,
        builders.line,
        '{',
      ])

      const closing = builders.concat([builders.hardline, '}'])

      return builders.concat([
        opening,
        indent(
          prefixAll(
            ast.data.body.map(x => render(x, options)),
            builders.hardline
          )
        ),
        closing,
      ])
    }
    case 'StructDeclaration': {
      /* Copied from ClassDeclaration */
      const maybeModifier = ast.data.modifier
        ? builders.concat([
            renderDeclarationModifier(ast.data.modifier),
            builders.line,
          ])
        : ''
      const maybeInherits = ast.data.inherits.length
        ? builders.concat([
            ': ',
            join(
              ast.data.inherits.map(x => renderTypeAnnotation(x, options)),
              ', '
            ),
          ])
        : ''
      const opening = group([
        maybeModifier,
        'struct',
        builders.line,
        ast.data.name,
        maybeInherits,
        builders.line,
        '{',
      ])
      const closing = builders.concat([builders.hardline, '}'])

      return builders.concat([
        opening,
        indent(
          prefixAll(
            ast.data.body.map(x => render(x, options)),
            builders.hardline
          )
        ),
        closing,
      ])
    }
    case 'ExtensionDeclaration': {
      /* Copied from ClassDeclaration */
      /* TODO: Where */
      const maybeModifier = ast.data.modifier
        ? builders.concat([
            renderDeclarationModifier(ast.data.modifier),
            builders.line,
          ])
        : ''
      const maybeProtocols = ast.data.protocols.length
        ? builders.concat([
            ': ',
            join(
              ast.data.protocols.map(x => renderTypeAnnotation(x, options)),
              ', '
            ),
          ])
        : ''
      const opening = group([
        maybeModifier,
        'struct',
        builders.line,
        ast.data.name,
        maybeProtocols,
        builders.line,
        '{',
      ])

      const closing = builders.concat([builders.hardline, '}'])

      return builders.concat([
        opening,
        indent(
          prefixAll(
            ast.data.body.map(x => render(x, options)),
            builders.hardline
          )
        ),
        closing,
      ])
    }
    case 'EnumDeclaration': {
      /* Copied from ClassDeclaration */
      const maybeIndirect = ast.data.isIndirect
        ? builders.concat(['indirect', builders.line])
        : ''
      const maybeModifier = ast.data.modifier
        ? builders.concat([
            renderDeclarationModifier(ast.data.modifier),
            builders.line,
          ])
        : ''
      const maybeInherits = ast.data.inherits.length
        ? builders.concat([
            ': ',
            join(
              ast.data.inherits.map(x => renderTypeAnnotation(x, options)),
              ', '
            ),
          ])
        : ''
      const opening = group([
        maybeModifier,
        maybeIndirect,
        'struct',
        builders.line,
        ast.data.name,
        maybeInherits,
        builders.line,
        '{',
      ])
      const closing = builders.concat([builders.hardline, '}'])

      return builders.concat([
        opening,
        indent(
          prefixAll(
            ast.data.body.map(x => render(x, options)),
            builders.hardline
          )
        ),
        closing,
      ])
    }
    case 'TypealiasDeclaration': {
      const maybeModifier = ast.data.modifier
        ? builders.concat([
            renderDeclarationModifier(ast.data.modifier),
            builders.line,
          ])
        : ''
      return group([
        maybeModifier,
        'typealias',
        builders.line,
        ast.data.name,
        builders.line,
        '=',
        builders.line,
        renderTypeAnnotation(ast.data.annotation, options),
      ])
    }
    case 'ConstantDeclaration': {
      const modifiers = join(
        ast.data.modifiers.map(renderDeclarationModifier),
        ' '
      )
      const maybeInit = ast.data.init
        ? builders.concat([' = ', render(ast.data.init, options)])
        : ''

      // check if we have a public color literal declaration
      if (
        ast.data.pattern.type === 'IdentifierPattern' &&
        ast.data.pattern.data.identifier.type === 'SwiftIdentifier' &&
        ast.data.pattern.data.annotation &&
        ast.data.pattern.data.annotation.type === 'TypeName' &&
        ast.data.pattern.data.annotation.data === 'Color' &&
        ast.data.init &&
        ast.data.init.type === 'LiteralExpression' &&
        ast.data.init.data.type === 'Color' &&
        ast.data.modifiers.indexOf(
          SwiftAST.DeclarationModifier.PublicModifier
        ) !== -1
      ) {
        const rgba = parseColorDefault(ast.data.init.data.data, 'black')

        if (options.outputFile) {
          Promise.all([
            options.outputFile(
              './Assets.xcassets/Contents.json',
              JSON.stringify(
                {
                  info: {
                    version: 1,
                    author: 'Lona',
                  },
                },
                null,
                '  '
              )
            ),
            options.outputFile(
              './Assets.xcassets/colors/Contents.json',
              JSON.stringify(
                {
                  info: {
                    version: 1,
                    author: 'Lona',
                  },
                },
                null,
                '  '
              )
            ),
            options.outputFile(
              `./Assets.xcassets/colors/${ast.data.pattern.data.identifier.data}.colorset/Contents.json`,
              JSON.stringify(
                {
                  info: {
                    version: 1,
                    author: 'Lona',
                  },
                  colors: [
                    {
                      idiom: 'universal',
                      color: {
                        'color-space': 'srgb',
                        components: {
                          red: `0x${rgba.r.toString(16).toUpperCase()}`,
                          alpha: `${rgba.a.toFixed(3)}`,
                          blue: `0x${rgba.b.toString(16).toUpperCase()}`,
                          green: `0x${rgba.g.toString(16).toUpperCase()}`,
                        },
                      },
                    },
                  ],
                },
                null,
                '  '
              )
            ),
          ]).catch(err => options.reporter.error(err))
        } else {
          options.reporter.warn(
            `The output needs an xcasset file which wasn't emitted`
          )
        }

        return group([
          modifiers,
          ast.data.modifiers.length ? ' ' : '',
          'let ',
          renderPattern(ast.data.pattern, options),
          ' = ',
          'Color(',
          'named: ',
          `"${ast.data.pattern.data.identifier.data}"`,
          ')!',
        ])
      }

      return group([
        modifiers,
        ast.data.modifiers.length ? ' ' : '',
        'let ',
        renderPattern(ast.data.pattern, options),
        maybeInit,
      ])
    }
    case 'VariableDeclaration': {
      const modifiers = join(
        ast.data.modifiers.map(renderDeclarationModifier),
        ' '
      )
      const maybeInit = ast.data.init
        ? builders.concat([' = ', render(ast.data.init, options)])
        : ''
      const maybeBlock = ast.data.block
        ? builders.concat([
            builders.line,
            renderInitializerBlock(ast.data.block, options),
          ])
        : ''
      return group([
        modifiers,
        ast.data.modifiers.length ? ' ' : '',
        'var ',
        renderPattern(ast.data.pattern, options),
        maybeInit,
        maybeBlock,
      ])
    }
    case 'Parameter':
      return builders.concat([
        ast.data.externalName
          ? builders.concat([ast.data.externalName, ' '])
          : '',
        ast.data.localName,
        ': ',
        renderTypeAnnotation(ast.data.annotation, options),
        ast.data.defaultValue
          ? builders.concat([' = ', render(ast.data.defaultValue, options)])
          : '',
      ])
    case 'InitializerDeclaration':
      return group([
        join(ast.data.modifiers.map(renderDeclarationModifier), ' '),
        ast.data.modifiers.length ? ' ' : '',
        'init',
        ast.data.failable || '',
        '(',
        indent([
          builders.softline,
          join(
            ast.data.parameters.map(x => render(x, options)),
            [',', builders.line]
          ),
        ]),
        ')',
        ast.data.throws ? ' throws' : '',
        builders.line,
        render(
          {
            type: 'CodeBlock',
            data: {
              statements: ast.data.body,
            },
          },
          options
        ),
      ])
    case 'DeinitializerDeclaration':
      return builders.concat([
        'deinit ',
        render(
          {
            type: 'CodeBlock',
            data: {
              statements: ast.data,
            },
          },
          options
        ),
      ])
    case 'FunctionDeclaration':
      return group([
        group([
          builders.concat(
            ast.data.attributes.map(x => builders.concat([x, ' ']))
          ),
          join(ast.data.modifiers.map(renderDeclarationModifier), ' '),
          ast.data.modifiers.length ? ' ' : '',
          'func ',
          ast.data.name,
          '(',
          indent([
            builders.softline,
            join(
              ast.data.parameters.map(x => render(x, options)),
              [',', builders.line]
            ),
          ]),
          ')',
          ast.data.result
            ? builders.concat([
                ' -> ',
                renderTypeAnnotation(ast.data.result, options),
              ])
            : '',
          ast.data.throws ? ' throws' : '',
        ]),
        builders.line,
        render(
          {
            type: 'CodeBlock',
            data: {
              statements: ast.data.body,
            },
          },
          options
        ),
      ])
    case 'ImportDeclaration':
      return group(['import', builders.line, ast.data])

    case 'IfStatement':
      return group([
        /* Line break here due to personal preference */
        /* builders.hardline, */
        'if',
        builders.line,
        render(ast.data.condition, options),
        builders.line,
        render(
          {
            type: 'CodeBlock',
            data: { statements: ast.data.block },
          },
          options
        ),
      ])
    case 'ForInStatement':
      return group([
        'for',
        builders.line,
        renderPattern(ast.data.item, options),
        builders.line,
        'in',
        builders.line,
        render(ast.data.collection, options),
        builders.line,
        render(
          { type: 'CodeBlock', data: { statements: ast.data.block } },
          options
        ),
      ])
    case 'WhileStatement':
      return group([
        'while',
        builders.line,
        render(ast.data.condition, options),
        builders.line,
        render(
          { type: 'CodeBlock', data: { statements: ast.data.block } },
          options
        ),
      ])
    case 'SwitchStatement':
      return group([
        'while',
        builders.line,
        render(ast.data.expression, options),
        builders.line,
        render(
          { type: 'CodeBlock', data: { statements: ast.data.cases } },
          options
        ),
      ])
    case 'CaseLabel': {
      /* Automatically add break statement if needed, for convenience */
      const statements: SwiftAST.SwiftNode[] =
        ast.data.statements.length >= 1
          ? ast.data.statements
          : [{ type: 'SwiftIdentifier', data: 'break' }]

      return builders.concat([
        'case ',
        join(
          ast.data.patterns.map(x => renderPattern(x, options)),
          [',', builders.line]
        ),
        ':',
        indent(
          prefixAll(
            statements.map(x => render(x, options)),
            builders.hardline
          )
        ),
      ])
    }
    case 'DefaultCaseLabel': {
      /* Automatically add break statement if needed, for convenience */
      const statements: SwiftAST.SwiftNode[] =
        ast.data.statements.length >= 1
          ? ast.data.statements
          : [{ type: 'SwiftIdentifier', data: 'break' }]

      return builders.concat([
        'default:',
        indent(
          prefixAll(
            statements.map(x => render(x, options)),
            builders.hardline
          )
        ),
      ])
    }
    case 'ReturnStatement':
      return group(['return', ast.data ? render(ast.data, options) : ''])
    case 'FunctionCallArgument':
      return ast.data.name
        ? group([
            render(ast.data.name, options),
            ':',
            builders.line,
            render(ast.data.value, options),
          ])
        : group(render(ast.data.value, options))
    case 'FunctionCallExpression': {
      // TODO: (Mathieu): is that right?
      const endsWithLiteral =
        ast.data.arguments.length !== 1 ||
        ast.data.arguments[0].type !== 'FunctionCallArgument' ||
        ast.data.arguments[0].data.value.type !== 'LiteralExpression'
      const args = builders.concat([
        endsWithLiteral ? builders.softline : '',
        join(
          ast.data.arguments.map(x => render(x, options)),
          [',', builders.line]
        ),
      ])

      return group([
        render(ast.data.name, options),
        '(',
        endsWithLiteral ? indent(args) : args,
        ')',
      ])
    }
    case 'EnumCase': {
      const name = nodeWithSafeIdentifier(ast.data.name)
      if (!ast.data.value) {
        const params = ast.data.parameters
          ? renderTypeAnnotation(ast.data.parameters, options)
          : ''
        return group(['case ', render(name, options), params])
      }
      return group([
        'case ',
        render(name, options),
        ' = ',
        render(ast.data.value, options),
      ])
    }
    case 'ConditionList':
      return group(
        indent(
          join(
            ast.data.map(x => render(x, options)),
            [',', builders.line]
          )
        )
      )

    case 'CaseCondition':
      return group([
        'case ',
        renderPattern(ast.data.pattern, options),
        builders.line,
        '=',
        builders.line,
        render(ast.data.init, options),
      ])
    case 'OptionalBindingCondition':
      return group([
        ast.data.const ? 'let' : 'var',
        ' ',
        renderPattern(ast.data.pattern, options),
        builders.line,
        '=',
        builders.line,
        render(ast.data.init, options),
      ])
    case 'Empty':
      return '' // This only works if lines are added between statements...
    case 'LineComment':
      return `// ${ast.data}`
    case 'DocComment': {
      const comment = ast.data.match(/.{1,100}/g)

      if (!comment) {
        return '///'
      }
      return comment.map(x => `/// ${x}`).join('\n')
    }
    case 'LineEndComment':
      return builders.concat([
        render(ast.data.line, options),
        builders.lineSuffix(` // ${ast.data.comment}`),
      ])
    case 'CodeBlock': {
      if (!ast.data.statements.length) {
        return '{}'
      }
      if (
        ast.data.statements.length === 1 &&
        ast.data.statements[0].type === 'SwiftIdentifier'
      ) {
        return builders.concat([
          '{',
          builders.line,
          render(ast.data.statements[0], options),
          builders.line,
          '}',
        ])
      }
      return builders.concat([
        '{',
        indent(
          prefixAll(
            ast.data.statements.map(x => render(x, options)),
            builders.hardline
          )
        ),
        builders.hardline,
        '}',
      ])
    }
    case 'StatementListHelper':
      /* TODO: Get rid of this? */
      return join(
        ast.data.map(x => render(x, options)),
        builders.hardline
      )
    case 'TopLevelDeclaration':
      return builders.concat([
        join(
          ast.data.statements.map(x => render(x, options)),
          [builders.hardline]
        ),
        builders.hardline,
      ])
  }
}

function renderLiteral(node: SwiftAST.Literal, options: Options): Doc {
  switch (node.type) {
    case 'Nil':
      return 'nil'
    case 'Boolean':
      return node.data ? 'true' : 'false'
    case 'Integer':
      return `${node.data}`
    case 'FloatingPoint':
      return `${node.data}`
    case 'String':
      // TODO: is it just `JSON.stringify`?
      return builders.concat(['"', node.data.replace(/"/g, '\\"'), '"'])
    case 'Color': {
      const rgba = parseColorDefault(node.data, 'black')
      const values = [
        builders.concat(['red: ', `${rgba.r / 255}`]),
        builders.concat(['green: ', `${rgba.g / 255}`]),
        builders.concat(['blue: ', `${rgba.b / 255}`]),
        builders.concat(['alpha: ', `${rgba.a}`]),
      ]
      return group(['#colorLiteral(', join(values, ', '), ')'])
    }
    case 'Image':
      return group(['#imageLiteral(resourceName: "', node.data, '")'])
    case 'Array': {
      const maybeLine = node.data.length ? builders.softline : ''
      const body = join(
        node.data.map(x => render(x, options)),
        [',', builders.line]
      )

      return group(['[', indent([maybeLine, body]), maybeLine, ']'])
    }
  }
}

function renderTypeAnnotation(
  node: SwiftAST.TypeAnnotation,
  options: Options
): Doc {
  switch (node.type) {
    case 'TypeName':
      return node.data
    case 'TypeIdentifier':
      return group([
        renderTypeAnnotation(node.data.name, options),
        builders.line,
        '.',
        builders.line,
        renderTypeAnnotation(node.data.member, options),
      ])
    case 'ArrayType':
      return group(['[', renderTypeAnnotation(node.data, options), ']'])
    case 'DictionaryType':
      return group([
        '[',
        renderTypeAnnotation(node.data.key, options),
        ': ',
        renderTypeAnnotation(node.data.value, options),
      ])
    case 'OptionalType':
      return group([renderTypeAnnotation(node.data, options), '?'])
    case 'TupleType':
      return builders.concat([
        '(',
        group(
          join(
            node.data.map(x =>
              x.elementName
                ? builders.concat([
                    `${x.elementName}: `,
                    renderTypeAnnotation(x.annotation, options),
                  ])
                : renderTypeAnnotation(x.annotation, options)
            ),
            ', '
          )
        ),
        ')',
      ])
    case 'FunctionType': {
      const args = group(
        join(
          node.data.arguments.map(x => renderTypeAnnotation(x, options)),
          ', '
        )
      )
      return group([
        '(',
        '(',
        args,
        ') -> ',
        node.data.returnType
          ? renderTypeAnnotation(node.data.returnType, options)
          : 'Void',
        ')',
      ])
    }
    case 'TypeInheritanceList':
      return group(
        join(
          node.data.list.map(x => renderTypeAnnotation(x, options)),
          ', '
        )
      )
    case 'ProtocolCompositionType':
      return group(
        join(
          node.data.map(x => renderTypeAnnotation(x, options)),
          ' & '
        )
      )
  }
}

function renderPattern(node: SwiftAST.Pattern, options: Options): Doc {
  switch (node.type) {
    case 'WildcardPattern':
      return '_'
    case 'IdentifierPattern': {
      const name = nodeWithSafeIdentifier(node.data.identifier)
      if (!node.data.annotation) {
        return render(name, options)
      }
      return builders.concat([
        render(name, options),
        ': ',
        renderTypeAnnotation(node.data.annotation, options),
      ])
    }
    case 'ValueBindingPattern':
      return group([
        node.data.kind,
        builders.line,
        renderPattern(node.data.pattern, options),
      ])
    case 'TuplePattern':
      return group([
        '(',
        join(
          node.data.map(x => renderPattern(x, options)),
          ', '
        ),
        ')',
      ])
    case 'OptionalPattern':
      return builders.concat([renderPattern(node.data.value, options), '?'])
    case 'ExpressionPattern':
      return render(node.data.value, options)
    case 'EnumCasePattern': {
      const maybeTypeIdentifier = node.data.typeIdentifier || ''
      const maybePattern = node.data.tuplePattern
        ? renderPattern(node.data.tuplePattern, options)
        : ''
      return group([
        maybeTypeIdentifier,
        '.',
        stringWithSafeIdentifier(node.data.caseName),
        maybePattern,
      ])
    }
  }
}

const isSingleLine = (x: SwiftAST.SwiftNode[]) =>
  x.length === 1 && x[0].type !== 'IfStatement'
const renderStatements = (x: SwiftAST.SwiftNode[], options: Options) =>
  isSingleLine(x)
    ? builders.concat([
        '{ ',
        builders.concat(x.map(x => render(x, options))),
        ' }',
      ])
    : render({ type: 'CodeBlock', data: { statements: x } }, options)

function renderInitializerBlock(
  node: SwiftAST.InitializerBlock,
  options: Options
): Doc {
  switch (node.type) {
    case 'GetterBlock':
      return render(
        { type: 'CodeBlock', data: { statements: node.data } },
        options
      )
    case 'GetterSetterBlock':
      return builders.concat([
        '{',
        indent([
          builders.hardline,
          'get ',
          renderStatements(node.data.get, options),
          builders.hardline,
          'set ',
          renderStatements(node.data.set, options),
        ]),
        builders.hardline,
        '}',
      ])

    case 'WillSetDidSetBlock': {
      /* Special case some single-statement willSet/didSet and render them in a single line
         since they are common in our generated code and are easier to read than multiline */
      const willSet = node.data.willSet
        ? builders.concat([
            'willSet ',
            renderStatements(node.data.willSet, options),
          ])
        : ''
      const didSet = node.data.didSet
        ? builders.concat([
            'didSet ',
            renderStatements(node.data.didSet, options),
          ])
        : ''

      if (!node.data.willSet && !node.data.didSet) {
        return ''
      }
      if (!node.data.willSet && node.data.didSet) {
        if (isSingleLine(node.data.didSet)) {
          return group(join(['{', indent(didSet), '}'], builders.line))
        }
        return builders.concat([
          '{',
          indent([builders.hardline, didSet]),
          builders.hardline,
          '}',
        ])
      }
      if (node.data.willSet && !node.data.didSet) {
        if (isSingleLine(node.data.willSet)) {
          return group(join(['{', indent(willSet), '}'], builders.line))
        }
        return builders.concat([
          '{',
          indent([builders.hardline, willSet]),
          builders.hardline,
          '}',
        ])
      }
      return builders.concat([
        '{',
        indent([builders.hardline, willSet, builders.hardline, didSet]),
        builders.hardline,
        '}',
      ])
    }
  }
}

export default function toString(ast: SwiftAST.SwiftNode, options: Options) {
  return doc.printer.printDocToString(render(ast, options), printerOptions)
    .formatted
}
