import { LogicAST } from '@lona/serialization'
import lowerFirst from 'lodash.lowerfirst'
import { Helpers, HardcodedMap, EvaluationContext } from '../../helpers'
import { nonNullable } from '../../utils'
import * as JSAST from './js-ast'
import {
  declarationPathTo,
  makeProgram,
  findParentNode,
} from '../../helpers/logic-ast'
import { reduce as traverseLogic } from '../../helpers/logic-traversal'
import { enumName } from './format'

type LogicGenerationContext = {
  isStatic: boolean
  isTopLevel: boolean
  rootNode: LogicAST.SyntaxNode
  helpers: Helpers
  handlePreludeDeps: (
    node: LogicAST.SyntaxNode,
    evaluationContext: undefined | EvaluationContext,
    context: LogicGenerationContext
  ) => JSAST.JSNode | undefined
}

type RecordParameter = {
  name: string
  defaultValue: LogicAST.Expression
}

type EnumerationParameter = {
  enumerationName: string
  caseName: string
}

const createVariableOrProperty = (
  isStaticContext: boolean,
  isDynamic: boolean,
  name: string,
  value: JSAST.JSNode
): JSAST.JSNode => {
  if (isStaticContext) {
    if (isDynamic) {
      return {
        type: 'MethodDefinition',
        data: {
          key: `get ${name}`,
          value: {
            type: 'FunctionExpression',
            data: {
              params: [],
              body: [{ type: 'Return', data: value }],
            },
          },
        },
      }
    }

    return {
      type: 'Property',
      data: { key: { type: 'Identifier', data: [name] }, value: value },
    }
  } else {
    return {
      type: 'VariableDeclaration',
      data: {
        type: 'AssignmentExpression',
        data: { left: { type: 'Identifier', data: [name] }, right: value },
      },
    }
  }
}

const sharedPrefix = (
  rootNode: LogicAST.SyntaxNode,
  a: string,
  b: string
): string[] => {
  function inner(aPath: string[], bPath: string[]): string[] {
    const a = aPath.shift()
    const b = bPath.shift()
    if ((aPath.length > 0, a === b)) {
      return [aPath[0], ...inner(aPath, bPath)]
    }
    return []
  }

  const aPath = declarationPathTo(rootNode, a)
  const bPath = declarationPathTo(rootNode, b)
  return inner(aPath, bPath)
}

function fontWeight(weight: number): JSAST.JSNode {
  return { type: 'Literal', data: { type: 'Number', data: weight } }
}

function evaluateColor(
  node: LogicAST.SyntaxNode,
  context: LogicGenerationContext
): JSAST.JSNode | undefined {
  if (!context.helpers.evaluationContext) {
    return undefined
  }
  const color = context.helpers.evaluationContext.evaluate(node.data.id)

  if (
    !color ||
    color.type.type !== 'constant' ||
    color.type.name !== 'Color' ||
    color.memory.type !== 'record' ||
    !color.memory.value.value ||
    color.memory.value.value.memory.type !== 'string'
  ) {
    return undefined
  }

  return {
    type: 'Literal',
    data: {
      type: 'Color',
      data: color.memory.value.value.memory.value,
    },
  }
}

const hardcoded: HardcodedMap<JSAST.JSNode, [LogicGenerationContext]> = {
  functionCallExpression: {
    'Color.saturate': evaluateColor,
    'Color.setHue': evaluateColor,
    'Color.setSaturation': evaluateColor,
    'Color.setLightness': evaluateColor,
    'Color.fromHSL': evaluateColor,
    'Boolean.or': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument' ||
        !node.data.arguments[1] ||
        node.data.arguments[1].type !== 'argument'
      ) {
        throw new Error(
          'The first 2 arguments of `Boolean.or` need to be a value'
        )
      }

      return {
        type: 'BinaryExpression',
        data: {
          left: expression(node.data.arguments[0].data.expression, context),
          operator: JSAST.binaryOperator.Or,
          right: expression(node.data.arguments[1].data.expression, context),
        },
      }
    },
    'Boolean.and': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument' ||
        !node.data.arguments[1] ||
        node.data.arguments[1].type !== 'argument'
      ) {
        throw new Error(
          'The first 2 arguments of `Boolean.and` need to be a value'
        )
      }

      return {
        type: 'BinaryExpression',
        data: {
          left: expression(node.data.arguments[0].data.expression, context),
          operator: JSAST.binaryOperator.And,
          right: expression(node.data.arguments[1].data.expression, context),
        },
      }
    },
    'String.concat': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument' ||
        !node.data.arguments[1] ||
        node.data.arguments[1].type !== 'argument'
      ) {
        throw new Error(
          'The first 2 arguments of `Array.at` need to be a value'
        )
      }
      // TODO:
      return undefined
    },
    'Number.range': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument' ||
        !node.data.arguments[1] ||
        node.data.arguments[1].type !== 'argument' ||
        !node.data.arguments[2] ||
        node.data.arguments[2].type !== 'argument'
      ) {
        throw new Error(
          'The first 3 arguments of `Number.range` need to be a value'
        )
      }
      // TODO:
      return undefined
    },
    'Array.at': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument' ||
        !node.data.arguments[1] ||
        node.data.arguments[1].type !== 'argument'
      ) {
        throw new Error(
          'The first 2 arguments of `Array.at` need to be a value'
        )
      }
      // TODO:
      return undefined
    },
    'Optional.value': (node, context) => {
      if (
        !node.data.arguments[0] ||
        node.data.arguments[0].type !== 'argument'
      ) {
        throw new Error(
          'The first argument of `Optional.value` needs to be a value'
        )
      }
      return expression(node.data.arguments[0].data.expression, context)
    },
    Shadow: () => {
      // polyfilled
      return undefined
    },
    TextStyle: () => {
      // polyfilled
      return undefined
    },
  },
  memberExpression: {
    'Optional.none': () => ({
      type: 'Literal',
      data: { type: 'Undefined', data: undefined },
    }),
    'FontWeight.ultraLight': () => fontWeight(100),
    'FontWeight.thin': () => fontWeight(200),
    'FontWeight.light': () => fontWeight(300),
    'FontWeight.regular': () => fontWeight(400),
    'FontWeight.medium': () => fontWeight(500),
    'FontWeight.semibold': () => fontWeight(600),
    'FontWeight.bold': () => fontWeight(700),
    'FontWeight.heavy': () => fontWeight(800),
    'FontWeight.black': () => fontWeight(900),
    'FontWeight.w100': () => fontWeight(100),
    'FontWeight.w200': () => fontWeight(200),
    'FontWeight.w300': () => fontWeight(300),
    'FontWeight.w400': () => fontWeight(400),
    'FontWeight.w500': () => fontWeight(500),
    'FontWeight.w600': () => fontWeight(600),
    'FontWeight.w700': () => fontWeight(700),
    'FontWeight.w800': () => fontWeight(800),
    'FontWeight.w900': () => fontWeight(900),
  },
}

export default function convert(
  node: LogicAST.SyntaxNode,
  helpers: Helpers
): JSAST.JSNode {
  const context: LogicGenerationContext = {
    isStatic: false,
    isTopLevel: true,
    rootNode: node,
    helpers,
    handlePreludeDeps: helpers.HandlePreludeFactory(hardcoded),
  }

  const program = makeProgram(node)

  if (!program) {
    helpers.reporter.warn(`Unhandled syntaxNode type "${node.type}"`)
    return { type: 'Empty' }
  }

  return {
    type: 'Program',
    data: program.data.block
      .filter(x => x.type !== 'placeholder')
      .map(x => statement(x, context)),
  }
}

const statement = (
  node: LogicAST.Statement,
  context: LogicGenerationContext
): JSAST.JSNode => {
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
    return { type: 'Empty' }
  }

  context.helpers.reporter.warn(`Unhandled statement type "${node.type}"`)
  return { type: 'Empty' }
}

const declaration = (
  node: LogicAST.Declaration,
  context: LogicGenerationContext
): JSAST.JSNode => {
  const potentialHandled = context.handlePreludeDeps(
    node,
    context.helpers.evaluationContext,
    context
  )
  if (potentialHandled) {
    return potentialHandled
  }
  switch (node.type) {
    case 'importDeclaration':
      return { type: 'Empty' }
    case 'namespace': {
      const newContext = { ...context, isTopLevel: false, isStatic: true }
      const variable = createVariableOrProperty(
        context.isStatic,
        false,
        node.data.name.name.toLowerCase(),
        {
          type: 'ObjectLiteral',
          data: node.data.declarations
            .filter(x => x.type !== 'placeholder')
            .map(x => declaration(x, newContext)),
        }
      )

      if (context.isTopLevel) {
        return {
          type: 'ExportNamedDeclaration',
          data: variable,
        }
      }

      return variable
    }
    case 'variable': {
      const newContext = { ...context, isTopLevel: false }
      const initialValue: JSAST.JSNode = node.data.initializer
        ? expression(node.data.initializer, newContext)
        : { type: 'Identifier', data: ['undefined'] }

      const isDynamic = traverseLogic(
        {
          type: 'declaration',
          data: {
            id: '',
            content: node,
          },
        },
        undefined,
        false,
        (result, child) => {
          if (
            child.type === 'expression' &&
            child.data.expression.type === 'identifierExpression'
          ) {
            const prefix = sharedPrefix(
              context.rootNode,
              node.data.id,
              child.data.expression.data.id
            )

            if (prefix.length === 0) {
              return result
            }

            return true
          }

          return result
        }
      )

      const variable = createVariableOrProperty(
        context.isStatic,
        isDynamic,
        node.data.name.name.toLowerCase(),
        initialValue
      )

      if (context.isTopLevel) {
        return {
          type: 'ExportNamedDeclaration',
          data: variable,
        }
      }

      return variable
    }
    case 'record':
      return { type: 'Empty' }
    case 'enumeration':
      return {
        type: 'VariableDeclaration',
        data: {
          type: 'AssignmentExpression',
          data: {
            left: { type: 'Identifier', data: [enumName(node.data.name.name)] },
            right: {
              type: 'ObjectLiteral',
              data: node.data.cases
                .map<JSAST.JSNode | undefined>(x => {
                  if (x.type === 'placeholder') {
                    return undefined
                  }
                  /* TODO: Handle enums with associated data */

                  return {
                    type: 'Property',
                    data: {
                      key: {
                        type: 'Identifier',
                        data: [enumName(x.data.name.name)],
                      },
                      value: { type: 'StringLiteral', data: x.data.name.name },
                    },
                  }
                })
                .filter(nonNullable),
            },
          },
        },
      }
    case 'placeholder':
      return { type: 'Empty' }
    default: {
      context.helpers.reporter.warn(`Unhandled declaration type "${node.type}"`)
      return { type: 'Empty' }
    }
  }
}

const expression = (
  node: LogicAST.Expression,
  context: LogicGenerationContext
): JSAST.JSNode => {
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
      const standard: JSAST.JSNode = {
        type: 'Identifier',
        data: [lowerFirst(node.data.identifier.string)],
      }
      const patternId = context.helpers.evaluationContext?.getPattern(
        node.data.identifier.id
      )

      if (!patternId) {
        return standard
      }

      const pattern = declarationPathTo(context.rootNode, patternId)

      if (!pattern.length) {
        return standard
      }

      return {
        type: 'Identifier',
        data: pattern.map(lowerFirst),
      }
    }
    case 'literalExpression':
      return literal(node.data.literal, context)
    case 'memberExpression':
      return {
        type: 'MemberExpression',
        data: {
          memberName: lowerFirst(node.data.memberName.string),
          expression: expression(node.data.expression, context),
        },
      }
    case 'functionCallExpression': {
      const validArguments = node.data.arguments.filter(
        x => x.type !== 'placeholder'
      )
      const standard: JSAST.JSNode = {
        type: 'CallExpression',
        data: {
          callee: expression(node.data.expression, context),
          arguments: node.data.arguments
            .map(x =>
              x.type === 'placeholder'
                ? undefined
                : expression(x.data.expression, context)
            )
            .filter(nonNullable),
        },
      }

      const lastIdentifier =
        node.data.expression.type === 'identifierExpression'
          ? node.data.expression.data.identifier
          : node.data.expression.type === 'memberExpression'
          ? node.data.expression.data.memberName
          : undefined

      if (!lastIdentifier) {
        return standard
      }

      /* Does the identifier point to a defined pattern? */
      const identifierPatternId = context.helpers.evaluationContext?.getPattern(
        lastIdentifier.id
      )
      /* Does the expression point to a defined pattern? (used for member expressions) */
      const expressionPatternId = context.helpers.evaluationContext?.getPattern(
        node.data.expression.data.id
      )

      const patternId = identifierPatternId || expressionPatternId

      if (!patternId || !context.helpers.evaluationContext) {
        return standard
      }

      const parent = findParentNode(
        context.helpers.evaluationContext.rootNode,
        patternId
      )

      if (!parent) {
        return standard
      }

      if (
        'type' in parent &&
        parent.type === 'declaration' &&
        parent.data.content.type === 'record'
      ) {
        const recordDefinition = parent.data.content.data.declarations
          .map<RecordParameter | undefined>(x =>
            x.type === 'variable' && x.data.initializer
              ? { name: x.data.name.name, defaultValue: x.data.initializer }
              : undefined
          )
          .filter(nonNullable)

        return {
          type: 'ObjectLiteral',
          data: recordDefinition.map(x => {
            const found = validArguments.find(
              arg =>
                arg.type !== 'placeholder' &&
                arg.data.label &&
                arg.data.label === x.name
            )

            if (found && found.type === 'argument') {
              return {
                type: 'Property',
                data: {
                  key: { type: 'Identifier', data: [x.name] },
                  value: expression(found.data.expression, context),
                },
              }
            }

            return {
              type: 'Property',
              data: {
                key: { type: 'Identifier', data: [x.name] },
                value: expression(x.defaultValue, context),
              },
            }
          }),
        }
      }

      if (
        'type' in parent &&
        parent.type === 'declaration' &&
        parent.data.content.type === 'enumeration'
      ) {
        const enumeration = findParentNode(
          context.helpers.evaluationContext.rootNode,
          parent.data.id
        )

        if (
          enumeration &&
          'type' in enumeration &&
          enumeration.type === 'enumerationCase'
        ) {
          return {
            type: 'StringLiteral',
            data: enumeration.data.name.name,
          }
        }
      }

      return standard
    }
    case 'placeholder': {
      context.helpers.reporter.warn('Placeholder expression remaining')
      return { type: 'Empty' }
    }
    default: {
      context.helpers.reporter.warn(`Unhandled expression type "${node.type}"`)
      return { type: 'Empty' }
    }
  }
}

const literal = (
  node: LogicAST.Literal,
  context: LogicGenerationContext
): JSAST.JSNode => {
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
        type: 'Literal',
        data: { type: 'Undefined', data: undefined },
      }
    }
    case 'boolean': {
      return {
        type: 'Literal',
        data: { type: 'Boolean', data: node.data.value },
      }
    }
    case 'number': {
      return {
        type: 'Literal',
        data: { type: 'Number', data: node.data.value },
      }
    }
    case 'string': {
      return {
        type: 'Literal',
        data: { type: 'String', data: node.data.value },
      }
    }
    case 'color': {
      return {
        type: 'Literal',
        data: { type: 'Color', data: node.data.value },
      }
    }
    case 'array': {
      return {
        type: 'Literal',
        data: {
          type: 'Array',
          data: node.data.value
            .filter(x => x.type !== 'placeholder')
            .map(x => expression(x, context)),
        },
      }
    }
  }
}

// and literal =
//     (context: LogicGenerationContext.t, node: LogicAst.literal)
//     : JavaScriptAst.node =>
//   switch (node) {
//   | None(_) => Identifier(["null"])
//   | Boolean({value}) => Literal(LonaValue.boolean(value))
//   | Number({value}) => Literal(LonaValue.number(value))
//   | String({value}) => StringLiteral(value)
//   | Color({value}) => StringLiteral(value)
//   | Array({value}) =>
//     ArrayLiteral(
//       value
//       |> unfoldPairs
//       |> Sequence.rejectWhere(isPlaceholderExpression)
//       |> List.map(expression(context)),
//     )
//   };
