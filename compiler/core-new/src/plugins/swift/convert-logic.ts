import { LogicAST } from '@lona/serialization'

import { Helpers, HardcodedMap, EvaluationContext } from '../../helpers'
import * as SwiftAST from '../../types/swift-ast'

type LogicGenerationContext = {
  isStatic: boolean
  isTopLevel: boolean
  helpers: Helpers
  handlePreludeDeps: (
    node: LogicAST.SyntaxNode,
    evaluationContext: void | EvaluationContext,
    context: LogicGenerationContext
  ) => SwiftAST.SwiftNode | void
}

function fontWeight(weight: string): SwiftAST.SwiftNode {
  return {
    type: 'MemberExpression',
    data: [
      {
        type: 'MemberExpression',
        data: [
          { type: 'SwiftIdentifier', data: 'Font' },
          { type: 'SwiftIdentifier', data: 'Weight' },
        ],
      },
      { type: 'SwiftIdentifier', data: weight },
    ],
  }
}

let hardcoded: HardcodedMap<SwiftAST.SwiftNode> = {
  functionCallExpression: {
    'Color.saturate': () => {},
    'Boolean.or': () => {},
    'Boolean.and': () => {},
    'String.concat': () => {},
    'Optional.value': (node, context) => {
      if (
        node.data.arguments[0] &&
        node.data.arguments[0].type === 'argument'
      ) {
        return expression(node.data.arguments[0].data.expression, context)
      }
      throw new Error(
        'The first argument of `Optional.value` needs to be a value'
      )
    },
    Shadow: () => {
      // polyfilled
    },
    TextStyle: () => {
      // polyfilled
    },
  },
  memberExpression: {
    'Optional.none': () => ({
      type: 'LiteralExpression',
      data: { type: 'Nil', data: undefined },
    }),
    'FontWeight.ultraLight': () => fontWeight('ultraLight'),
    'FontWeight.thin': () => fontWeight('thin'),
    'FontWeight.light': () => fontWeight('light'),
    'FontWeight.regular': () => fontWeight('regular'),
    'FontWeight.medium': () => fontWeight('medium'),
    'FontWeight.semibold': () => fontWeight('semibold'),
    'FontWeight.bold': () => fontWeight('bold'),
    'FontWeight.heavy': () => fontWeight('heavy'),
    'FontWeight.black': () => fontWeight('back'),
    'FontWeight.w100': () => fontWeight('ultraLight'),
    'FontWeight.w200': () => fontWeight('thin'),
    'FontWeight.w300': () => fontWeight('light'),
    'FontWeight.w400': () => fontWeight('regular'),
    'FontWeight.w500': () => fontWeight('medium'),
    'FontWeight.w600': () => fontWeight('semibold'),
    'FontWeight.w700': () => fontWeight('bold'),
    'FontWeight.w800': () => fontWeight('heavy'),
    'FontWeight.w900': () => fontWeight('back'),
    'TextStyle.systemTextColor': () => {},
  },
}

export default function convert(
  node: LogicAST.SyntaxNode,
  helpers: Helpers
): SwiftAST.SwiftNode {
  const context: LogicGenerationContext = {
    isStatic: false,
    isTopLevel: true,
    helpers,
    handlePreludeDeps: helpers.HandlePreludeFactory(hardcoded),
  }

  if (node.type === 'program') {
    return {
      type: 'TopLevelDeclaration',
      data: {
        statements: node.data.block
          .filter(x => x.type !== 'placeholder')
          .map(x => statement(x, context)),
      },
    }
  }

  if (node.type === 'topLevelDeclarations') {
    return {
      type: 'TopLevelDeclaration',
      data: {
        statements: node.data.declarations
          .filter(x => x.type !== 'placeholder')
          .map(x => declaration(x, context)),
      },
    }
  }

  helpers.reporter.warn(`Unhandled syntaxNode type "${node.type}"`)

  return { type: 'Empty', data: undefined }
}

const statement = (
  node: LogicAST.Statement,
  context: LogicGenerationContext
): SwiftAST.SwiftNode => {
  const potentialHandled = context.handlePreludeDeps(
    node,
    context.helpers.evaluationContext,
    context
  )
  if (potentialHandled) {
    return potentialHandled
  }
  if (node.type === 'declaration') {
    return declaration(node.data.content, context)
  }
  if (node.type === 'placeholder') {
    return { type: 'Empty', data: undefined }
  }

  context.helpers.reporter.warn(`Unhandled statement type "${node.type}"`)
  return { type: 'Empty', data: undefined }
}

const declaration = (
  node: LogicAST.Declaration,
  context: LogicGenerationContext
): SwiftAST.SwiftNode => {
  const potentialHandled = context.handlePreludeDeps(
    node,
    context.helpers.evaluationContext,
    context
  )
  if (potentialHandled) {
    return potentialHandled
  }
  switch (node.type) {
    case 'importDeclaration': {
      return { type: 'Empty', data: undefined }
    }
    case 'namespace': {
      const newContext = { ...context, isStatic: true }
      return {
        type: 'EnumDeclaration',
        data: {
          name: node.data.name.name,
          isIndirect: true,
          inherits: [],
          modifier: SwiftAST.DeclarationModifier.PublicModifier,
          body: node.data.declarations
            .filter(x => x.type !== 'placeholder')
            .map(x => declaration(x, newContext)),
        },
      }
    }
    case 'variable': {
      return {
        type: 'ConstantDeclaration',
        data: {
          modifiers: (context.isStatic
            ? ([
                SwiftAST.DeclarationModifier.StaticModifier,
              ] as SwiftAST.DeclarationModifier[])
            : []
          ).concat([SwiftAST.DeclarationModifier.PublicModifier]),
          pattern: {
            type: 'IdentifierPattern',
            data: {
              identifier: {
                type: 'SwiftIdentifier',
                data: node.data.name.name,
              },
              annotation: node.data.annotation
                ? typeAnnotation(node.data.annotation, context)
                : undefined,
            },
          },
          init: node.data.initializer
            ? expression(node.data.initializer, context)
            : undefined,
        },
      }
    }
    case 'record': {
      const newContext = { ...context, isStatic: false }

      const memberVariables = node.data.declarations.filter<
        LogicAST.VariableDeclaration
        // @ts-ignore
      >(x => x.type === 'variable')

      const initFunction: SwiftAST.SwiftNode = {
        type: 'InitializerDeclaration',
        data: {
          modifiers: [SwiftAST.DeclarationModifier.PublicModifier],
          parameters: memberVariables.map(x => ({
            type: 'Parameter',
            data: {
              localName: x.data.name.name,
              annotation: typeAnnotation(x.data.annotation, newContext),
              defaultValue: x.data.initializer
                ? expression(x.data.initializer, newContext)
                : undefined,
            },
          })),
          throws: false,
          body: memberVariables.map(x => ({
            type: 'BinaryExpression',
            data: {
              left: {
                type: 'MemberExpression',
                data: [
                  {
                    type: 'SwiftIdentifier',
                    data: 'self',
                  },
                  {
                    type: 'SwiftIdentifier',
                    data: x.data.name.name,
                  },
                ],
              },
              operator: '=',
              right: {
                type: 'SwiftIdentifier',
                data: x.data.name.name,
              },
            },
          })),
        },
      }

      return {
        type: 'StructDeclaration',
        data: {
          name: node.data.name.name,
          inherits: [{ type: 'TypeName', data: 'Equatable' }],
          modifier: SwiftAST.DeclarationModifier.PublicModifier,
          body: (memberVariables.length ? [initFunction] : []).concat(
            memberVariables.map(x =>
              declaration({ type: 'variable', data: { ...x.data } }, newContext)
            )
          ),
          /* TODO: Other declarations */
        },
      }
    }
    case 'enumeration': {
      return {
        type: 'EnumDeclaration',
        data: {
          name: node.data.name.name,
          isIndirect: true,
          inherits: node.data.genericParameters.map(x =>
            genericParameter(x, context)
          ),
          modifier: SwiftAST.DeclarationModifier.PublicModifier,
          body: node.data.cases
            .map(x => {
              if (x.type !== 'enumerationCase') {
                return undefined
              }
              const associatedValueTypes = x.data.associatedValueTypes.filter(
                y => y.type !== 'placeholder'
              )

              const associatedType: SwiftAST.TypeAnnotation | undefined =
                associatedValueTypes.length === 0
                  ? undefined
                  : {
                      type: 'TupleType',
                      data: associatedValueTypes.map(y => ({
                        annotation: typeAnnotation(y, context),
                      })),
                    }

              const enumCase: SwiftAST.SwiftNode = {
                type: 'EnumCase',
                data: {
                  name: {
                    type: 'SwiftIdentifier',
                    data: x.data.name.name,
                  },
                  parameters: associatedType,
                },
              }
              return enumCase
            })
            .filter(x => !!x),
        },
      }
    }
    case 'placeholder': {
      return { type: 'Empty', data: undefined }
    }
    default: {
      context.helpers.reporter.warn(`Unhandled declaration type "${node.type}"`)
      return { type: 'Empty', data: undefined }
    }
  }
}

const expression = (
  node: LogicAST.Expression,
  context: LogicGenerationContext
): SwiftAST.SwiftNode => {
  const potentialHandled = context.handlePreludeDeps(
    node,
    context.helpers.evaluationContext,
    context
  )
  if (potentialHandled) {
    return potentialHandled
  }
  switch (node.type) {
    case 'identifierExpression': {
      return {
        type: 'SwiftIdentifier',
        data: node.data.identifier.string,
      }
    }
    case 'literalExpression': {
      return literal(node.data.literal, context)
    }
    case 'memberExpression': {
      return {
        type: 'MemberExpression',
        data: [
          expression(node.data.expression, context),
          { type: 'SwiftIdentifier', data: node.data.memberName.string },
        ],
      }
    }
    case 'functionCallExpression': {
      return {
        type: 'FunctionCallExpression',
        data: {
          name: expression(node.data.expression, context),
          arguments: node.data.arguments
            .map<SwiftAST.SwiftNode | undefined>(arg => {
              if (arg.type === 'placeholder') {
                return undefined
              }
              return {
                type: 'FunctionCallArgument',
                data: {
                  name: arg.data.label
                    ? { type: 'SwiftIdentifier', data: arg.data.label }
                    : undefined,
                  value: expression(arg.data.expression, context),
                },
              }
            })
            .filter(x => !!x),
        },
      }
    }
    case 'placeholder': {
      context.helpers.reporter.warn('Placeholder expression remaining')
      return { type: 'Empty', data: undefined }
    }
    default: {
      context.helpers.reporter.warn(`Unhandled expression type "${node.type}"`)
      return { type: 'Empty', data: undefined }
    }
  }
}

const literal = (
  node: LogicAST.Literal,
  context: LogicGenerationContext
): SwiftAST.SwiftNode => {
  const potentialHandled = context.handlePreludeDeps(
    node,
    context.helpers.evaluationContext,
    context
  )
  if (potentialHandled) {
    return potentialHandled
  }
  switch (node.type) {
    case 'none': {
      return {
        type: 'LiteralExpression',
        data: { type: 'Nil', data: undefined },
      }
    }
    case 'boolean': {
      return {
        type: 'LiteralExpression',
        data: { type: 'Boolean', data: node.data.value },
      }
    }
    case 'number': {
      return {
        type: 'LiteralExpression',
        data: { type: 'FloatingPoint', data: node.data.value },
      }
    }
    case 'string': {
      return {
        type: 'LiteralExpression',
        data: { type: 'String', data: node.data.value },
      }
    }
    case 'color': {
      return {
        type: 'LiteralExpression',
        data: { type: 'Color', data: node.data.value },
      }
    }
    case 'array': {
      return {
        type: 'LiteralExpression',
        data: {
          type: 'Array',
          data: node.data.value.map(x => expression(x, context)),
        },
      }
    }
  }
}

const convertNativeType = (
  typeName: string,
  _context: LogicGenerationContext
): string => {
  switch (typeName) {
    case 'Boolean':
      return 'Bool'
    case 'Number':
      return 'CGFloat'
    case 'WholeNumber':
      return 'Int'
    case 'String':
      return 'String'
    case 'Optional':
      return 'Optional'
    case 'URL':
      return 'Image'
    case 'Color':
      return 'Color'
    default:
      return typeName
  }
}

const typeAnnotation = (
  node: LogicAST.TypeAnnotation,
  context: LogicGenerationContext
): SwiftAST.TypeAnnotation => {
  switch (node.type) {
    case 'typeIdentifier': {
      return {
        type: 'TypeName',
        data: convertNativeType(node.data.identifier.string, context),
      }
    }
    case 'placeholder': {
      context.helpers.reporter.warn('Type placeholder remaining in file')
      return { type: 'TypeName', data: '_' }
    }
    default: {
      context.helpers.reporter.warn(`Unhandled type annotation "${node.type}"`)
      return { type: 'TypeName', data: '_' }
    }
  }
}

const genericParameter = (
  node: LogicAST.GenericParameter,
  context: LogicGenerationContext
): SwiftAST.TypeAnnotation => {
  switch (node.type) {
    case 'parameter': {
      return {
        type: 'TypeName',
        data: convertNativeType(node.data.name.name, context),
      }
    }
    case 'placeholder': {
      context.helpers.reporter.warn(
        'Generic type placeholder remaining in file'
      )
      return { type: 'TypeName', data: '_' }
    }
  }
}