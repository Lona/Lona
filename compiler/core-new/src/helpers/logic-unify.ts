import intersection from 'lodash.intersection'
import * as LogicAST from './logic-ast'
import * as LogicScope from './logic-scope'
import * as LogicTraversal from './logic-traversal'

type FunctionArgument = {
  label?: string
  type: Unification
}

type Variable = {
  type: 'variable'
  value: string
}

type Constant = {
  type: 'constant'
  name: string
  parameters: Unification[]
}

type Generic = {
  type: 'generic'
  name: string
}

type Function = {
  type: 'function'
  arguments: FunctionArgument[]
  returnType: Unification
}

export type Unification = Variable | Constant | Generic | Function

/* Builtins */
export const unit: Constant = {
  type: 'constant',
  name: 'Void',
  parameters: [],
}
export const bool: Constant = {
  type: 'constant',
  name: 'Boolean',
  parameters: [],
}
export const number: Constant = {
  type: 'constant',
  name: 'Number',
  parameters: [],
}
export const string: Constant = {
  type: 'constant',
  name: 'String',
  parameters: [],
}
export const color: Constant = {
  type: 'constant',
  name: 'Color',
  parameters: [],
}
export const shadow: Constant = {
  type: 'constant',
  name: 'Shadow',
  parameters: [],
}
export const textStyle: Constant = {
  type: 'constant',
  name: 'TextStyle',
  parameters: [],
}
export const optional = (type: Unification): Constant => ({
  type: 'constant',
  name: 'Optional',
  parameters: [type],
})
export const array = (typeUnification: Unification): Constant => ({
  type: 'constant',
  name: 'Array',
  parameters: [typeUnification],
})

type Contraint = {
  head: Unification
  tail: Unification
}

class LogicNameGenerator {
  private prefix: string
  private currentIndex = 0
  constructor(prefix: string = '') {
    this.prefix = prefix
  }
  next() {
    this.currentIndex += 1
    let name = this.currentIndex.toString(36)
    return `${this.prefix}${name}`
  }
}

export type UnificationContext = {
  constraints: Contraint[]
  nodes: { [key: string]: Unification }
  patternTypes: { [key: string]: Unification }
  typeNameGenerator: LogicNameGenerator
}

function unificationType(
  genericsInScope: [string, string][],
  getName: () => string,
  typeAnnotation: LogicAST.AST.TypeAnnotation
): Unification {
  if (typeAnnotation.type === 'typeIdentifier') {
    const { string, isPlaceholder } = typeAnnotation.data.identifier
    if (isPlaceholder) {
      return {
        type: 'variable',
        value: getName(),
      }
    }
    const generic = genericsInScope.find(g => g[0] === string)
    if (generic) {
      return {
        type: 'generic',
        name: generic[1],
      }
    }
    const parameters = typeAnnotation.data.genericArguments.map(arg =>
      unificationType(genericsInScope, getName, arg)
    )
    return {
      type: 'constant',
      name: string,
      parameters,
    }
  }
  if (typeAnnotation.type === 'placeholder') {
    return {
      type: 'variable',
      value: getName(),
    }
  }
  return {
    type: 'variable',
    value: 'Function type error',
  }
}

export function substitute(
  substitution: Map<Unification, Unification>,
  type: Unification
): Unification {
  let resolvedType = substitution.get(type) ? substitution.get(type) : type

  if (resolvedType.type === 'variable' || resolvedType.type === 'generic') {
    return resolvedType
  }

  if (resolvedType.type === 'constant') {
    return {
      type: 'constant',
      name: resolvedType.name,
      parameters: resolvedType.parameters.map(x => substitute(substitution, x)),
    }
  }

  if (resolvedType.type === 'function') {
    return {
      type: 'function',
      returnType: substitute(substitution, resolvedType.returnType),
      arguments: resolvedType.arguments.map(arg => ({
        label: arg.label,
        type: substitute(substitution, arg.type),
      })),
    }
  }
}

function genericNames(type: Unification): string[] {
  if (type.type === 'variable') {
    return []
  }
  if (type.type === 'constant') {
    return type.parameters
      .map(genericNames)
      .reduce((prev, x) => prev.concat(x), [])
  }
  if (type.type === 'generic') {
    return [type.name]
  }
  if (type.type === 'function') {
    return type.arguments
      .map(x => x.type)
      .concat(type.returnType)
      .map(genericNames)
      .reduce((prev, x) => prev.concat(x), [])
  }
}

function replaceGenericsWithVars(getName: () => string, type: Unification) {
  let substitution = new Map<Unification, Unification>()
  genericNames(type).forEach(name =>
    substitution.set(
      { type: 'generic', name },
      { type: 'variable', value: getName() }
    )
  )

  return substitute(substitution, type)
}

function specificIdentifierType(
  scopeContext: LogicScope.ScopeContext,
  unificationContext: UnificationContext,
  id: string
): Unification {
  const patternId = scopeContext.identifierToPattern[id]

  if (!patternId) {
    return {
      type: 'variable',
      value: unificationContext.typeNameGenerator.next(),
    }
  }

  const scopedType = unificationContext.patternTypes[patternId]

  if (!scopedType) {
    return {
      type: 'variable',
      value: unificationContext.typeNameGenerator.next(),
    }
  }

  return replaceGenericsWithVars(
    unificationContext.typeNameGenerator.next.bind(unificationContext),
    scopedType
  )
}

const makeEmptyContext = (): UnificationContext => ({
  constraints: [],
  nodes: {},
  patternTypes: {},
  typeNameGenerator: new LogicNameGenerator('?'),
})

export const makeUnificationContext = (
  rootNode: LogicAST.AST.SyntaxNode,
  scopeContext: LogicScope.ScopeContext,
  initialContext: UnificationContext = makeEmptyContext()
): UnificationContext => {
  let build = (
    result: UnificationContext,
    node: LogicAST.AST.SyntaxNode,
    config: LogicTraversal.TraversalConfig
  ): UnificationContext => {
    config.needsRevisitAfterTraversingChildren = true

    if (node.type === 'branch' && config._isRevisit) {
      result.nodes[node.data.condition.data.id] = bool
    }

    if (node.type === 'record' && !config._isRevisit) {
      const genericNames = node.data.genericParameters
        .map(param =>
          param.type === 'parameter' ? param.data.name.name : undefined
        )
        .filter(x => !!x)
      const genericsInScope = genericNames.map(x => [
        x,
        result.typeNameGenerator.next(),
      ])
      const universalTypes = genericNames.map<Unification>((x, i) => ({
        type: 'generic',
        name: genericsInScope[i][1],
      }))

      let parameterTypes: FunctionArgument[] = []

      node.data.declarations.forEach(declaration => {
        if (declaration.type !== 'variable' || !declaration.data.annotation) {
          return
        }
        const { annotation, name } = declaration.data
        const annotationType = unificationType(
          [],
          result.typeNameGenerator.next.bind(result),
          annotation
        )
        parameterTypes.unshift({
          label: name.name,
          type: annotationType,
        })

        result.nodes[name.id] = annotationType
        result.patternTypes[name.id] = annotationType
      })

      const returnType: Unification = {
        type: 'constant',
        name: node.data.name.name,
        parameters: universalTypes,
      }
      let functionType: Unification = {
        type: 'function',
        arguments: parameterTypes,
        returnType,
      }

      result.nodes[node.data.name.id] = functionType
      result.patternTypes[node.data.name.id] = functionType
    }

    if (node.type === 'enumeration' && !config._isRevisit) {
      const genericNames = node.data.genericParameters
        .map(param =>
          param.type === 'parameter' ? param.data.name.name : undefined
        )
        .filter(x => !!x)
      const genericsInScope: [string, string][] = genericNames.map(x => [
        x,
        result.typeNameGenerator.next(),
      ])
      const universalTypes = genericNames.map<Unification>((x, i) => ({
        type: 'generic',
        name: genericsInScope[i][1],
      }))

      const returnType: Unification = {
        type: 'constant',
        name: node.data.name.name,
        parameters: universalTypes,
      }

      node.data.cases.forEach(enumCase => {
        if (enumCase.type === 'placeholder') {
          return
        }
        const parameterTypes = enumCase.data.associatedValueTypes
          .map(annotation => {
            if (annotation.type === 'placeholder') {
              return
            }
            return {
              label: undefined,
              type: unificationType(
                genericsInScope,
                result.typeNameGenerator.next.bind(result),
                annotation
              ),
            }
          })
          .filter(x => !!x)
        let functionType: Unification = {
          type: 'function',
          arguments: parameterTypes,
          returnType,
        }

        result.nodes[enumCase.data.name.id] = functionType
        result.patternTypes[enumCase.data.name.id] = functionType
      })

      /* Not used for unification, but used for convenience in evaluation */
      result.nodes[node.data.name.id] = returnType
      result.patternTypes[node.data.name.id] = returnType
    }

    if (node.type === 'function' && !config._isRevisit) {
      const genericNames = node.data.genericParameters
        .map(param =>
          param.type === 'parameter' ? param.data.name.name : undefined
        )
        .filter(x => !!x)
      const genericsInScope: [string, string][] = genericNames.map(x => [
        x,
        result.typeNameGenerator.next(),
      ])

      let parameterTypes: FunctionArgument[] = []

      node.data.parameters.forEach(param => {
        if (param.type === 'placeholder') {
          return
        }
        const { name, id } = param.data.localName
        let annotationType = unificationType(
          [],
          result.typeNameGenerator.next.bind(result),
          param.data.annotation
        )
        parameterTypes.unshift({ label: name, type: annotationType })

        result.nodes[id] = annotationType
        result.patternTypes[id] = annotationType
      })

      let returnType = unificationType(
        genericsInScope,
        result.typeNameGenerator.next.bind(result),
        node.data.returnType
      )
      let functionType: Unification = {
        type: 'function',
        arguments: parameterTypes,
        returnType,
      }

      result.nodes[node.data.name.id] = functionType
      result.patternTypes[node.data.name.id] = functionType
    }

    if (node.type === 'variable' && config._isRevisit) {
      if (
        !node.data.initializer ||
        !node.data.annotation ||
        node.data.annotation.type === 'placeholder'
      ) {
        config.ignoreChildren = true
      } else {
        const annotationType = unificationType(
          [],
          result.typeNameGenerator.next.bind(result),
          node.data.annotation
        )
        const initializerId = node.data.initializer.data.id
        const initializerType = result.nodes[initializerId]

        if (initializerType) {
          result.constraints.push({
            head: annotationType,
            tail: initializerType,
          })
        } else {
          console.error(
            `WARNING: No initializer type for ${node.data.name.name} (${initializerId})`
          )
        }

        result.patternTypes[node.data.name.id] = annotationType
      }
    }

    if (node.type === 'placeholder' && config._isRevisit) {
      result.nodes[node.data.id] = {
        type: 'variable',
        value: result.typeNameGenerator.next(),
      }
    }
    if (node.type === 'identifierExpression' && config._isRevisit) {
      let type = specificIdentifierType(
        scopeContext,
        result,
        node.data.identifier.id
      )

      result.nodes[node.data.id] = type
      result.nodes[node.data.identifier.id] = type
    }
    if (node.type === 'functionCallExpression' && config._isRevisit) {
      const calleeType = result.nodes[node.data.expression.data.id]

      /* Unify against these to enforce a function type */

      const placeholderReturnType: Unification = {
        type: 'variable',
        value: result.typeNameGenerator.next(),
      }

      const placeholderArgTypes = node.data.arguments
        .map<FunctionArgument>(arg => {
          if (arg.type === 'placeholder') {
            return
          }
          return {
            label: arg.data.label,
            type: {
              type: 'variable',
              value: result.typeNameGenerator.next(),
            },
          }
        })
        .filter(x => !!x)

      const placeholderFunctionType: Unification = {
        type: 'function',
        arguments: placeholderArgTypes,
        returnType: placeholderReturnType,
      }

      result.constraints.push({
        head: calleeType,
        tail: placeholderFunctionType,
      })

      result.nodes[node.data.id] = placeholderReturnType

      let argumentValues = node.data.arguments
        .map<LogicAST.AST.Expression>(arg =>
          arg.type === 'placeholder' ? undefined : arg.data.expression
        )
        .filter(x => !!x)

      const constraints = placeholderArgTypes.map((argType, i) => ({
        head: argType.type,
        tail: result.nodes[argumentValues[i].data.id],
      }))

      result.constraints = result.constraints.concat(constraints)
    }
    if (node.type === 'memberExpression') {
      if (!config._isRevisit) {
        config.ignoreChildren = true
      } else {
        let type = specificIdentifierType(scopeContext, result, node.data.id)

        result.nodes[node.data.id] = type
      }
    }
    if (node.type === 'literalExpression' && config._isRevisit) {
      result.nodes[node.data.id] = result.nodes[node.data.literal.data.id]
    }

    /* TODO: Binary expression */

    if (node.type === 'boolean' && config._isRevisit) {
      result.nodes[node.data.id] = bool
    }
    if (node.type === 'number' && config._isRevisit) {
      result.nodes[node.data.id] = number
    }
    if (node.type === 'string' && config._isRevisit) {
      result.nodes[node.data.id] = string
    }
    if (node.type === 'color' && config._isRevisit) {
      result.nodes[node.data.id] = color
    }
    if (node.type === 'array' && config._isRevisit) {
      const elementType: Unification = {
        type: 'variable',
        value: result.typeNameGenerator.next(),
      }
      result.nodes[node.data.id] = elementType

      const constraints = node.data.value.map(expression => ({
        head: elementType,
        tail: result.nodes[expression.data.id] || {
          type: 'variable',
          value: result.typeNameGenerator.next(),
        },
      }))

      result.constraints = result.constraints.concat(constraints)
    }

    return result
  }

  return LogicTraversal.reduce(
    rootNode,
    LogicTraversal.emptyConfig(),
    initialContext,
    build
  )
}

export const unify = (
  constraints: Contraint[],
  substitution: Map<Unification, Unification> = new Map()
): Map<Unification, Unification> => {
  while (constraints.length > 0) {
    const constraint = constraints.shift()
    let { head, tail } = constraint

    if (head == tail) {
      continue
    }

    if (head.type === 'function' && tail.type === 'function') {
      const headArguments = head.arguments
      const tailArguments = tail.arguments
      const headContainsLabels = headArguments.some(x => !!x.label)
      const tailContainsLabels = tailArguments.some(x => !!x.label)

      if (
        (headContainsLabels && !tailContainsLabels && tailArguments.length) ||
        (tailContainsLabels && !headContainsLabels && headArguments.length)
      ) {
        throw new Error(
          `[UnificationError] [GenericArgumentsLabelMismatch] ${headArguments} ${tailArguments}`
        )
      }

      if (!headContainsLabels && !tailContainsLabels) {
        if (headArguments.length !== tailArguments.length) {
          throw new Error(
            `[UnificationError] [GenericArgumentsCountMismatch] ${head} ${tail}`
          )
        }

        headArguments.forEach((a, i) => {
          constraints.push({ head: a.type, tail: tailArguments[i].type })
        })
      } else {
        const headLabels = headArguments.map(arg => arg.label).filter(x => !!x)
        const tailLabels = tailArguments.map(arg => arg.label).filter(x => !!x)

        let common = intersection(headLabels, tailLabels)

        common.forEach(label => {
          const headArgumentType = headArguments.find(
            arg => arg.label === label
          ).type
          const tailArgumentType = tailArguments.find(
            arg => arg.label === label
          ).type
          constraints.push({ head: headArgumentType, tail: tailArgumentType })
        })
      }

      constraints.push({ head: head.returnType, tail: tail.returnType })
    } else if (head.type === 'constant' && tail.type === 'constant') {
      if (head.name !== tail.name) {
        throw new Error(`[UnificationError] [NameMismatch] ${head} ${tail}`)
      }
      const headParameters = head.parameters
      const tailParameters = tail.parameters
      if (headParameters.length !== tailParameters.length) {
        throw new Error(
          `[UnificationError] [GenericArgumentsCountMismatch] ${head} ${tail}`
        )
      }
      headParameters.forEach((a, i) => {
        constraints.push({ head: a, tail: tailParameters[i] })
      })
    } else if (head.type === 'generic' || tail.type === 'generic') {
      console.error('tried to unify generics (problem?)', head, tail)
    } else if (head.type === 'variable') {
      substitution.set(head, tail)
    } else if (tail.type === 'variable') {
      substitution.set(tail, head)
    } else if (
      (head.type === 'constant' && tail.type === 'function') ||
      (head.type === 'function' && tail.type === 'constant')
    ) {
      throw new Error(`[UnificationError] [KindMismatch] ${head} ${tail}`)
    }

    constraints = constraints.map(c => {
      const head = substitution.get(c.head)
      const tail = substitution.get(c.tail)

      if (head && tail) {
        return { head, tail }
      }
      if (head) {
        return {
          head,
          tail: c.tail,
        }
      }
      if (tail) {
        return {
          head: c.head,
          tail,
        }
      }
      return c
    })
  }

  return substitution
}
