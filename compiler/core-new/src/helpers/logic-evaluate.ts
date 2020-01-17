import * as LogicUnify from './logic-unify'
import * as LogicAST from './logic-ast'
import * as LogicScope from './logic-scope'

export type Memory =
  | { type: 'unit' }
  | { type: 'bool'; value: boolean }
  | { type: 'number'; value: number }
  | { type: 'string'; value: string }
  | { type: 'array'; value: Value[] }
  | { type: 'enum'; value: string; data: Value[] }
  | { type: 'record'; value: { [key: string]: Value } }
  | {
      type: 'function'
      value:
        | { type: 'path'; value: string[] }
        | {
            type: 'recordInit'
            value: { [key: string]: [LogicUnify.Unification, Value | void] }
          }
        | { type: 'enumInit'; value: string }
    }

export type Value = {
  type: LogicUnify.Unification
  memory: Memory
}

type Thunk = {
  label: string
  dependencies: string[]
  f: (args: Value[]) => Value
}

export class EvaluationContext {
  values: { [uuid: string]: Value } = {}
  thunks: { [uuid: string]: Thunk } = {}

  add(uuid: string, thunk: Thunk) {
    this.thunks[uuid] = thunk
  }

  evaluate(uuid: string): Value | void {
    const value = this.values[uuid]
    if (value) {
      return value
    }
    const thunk = this.thunks[uuid]
    if (!thunk) {
      console.error(`no thunk for ${uuid}`)
      return undefined
    }

    const resolvedDependencies = thunk.dependencies.map(x => this.evaluate(x))
    if (resolvedDependencies.some(x => !x)) {
      console.error(
        `Failed to evaluate thunk ${uuid} - missing dep ${
          thunk.dependencies[resolvedDependencies.findIndex(x => !x)]
        }`
      )
      return undefined
    }

    const result = thunk.f(resolvedDependencies as Value[])
    this.values[uuid] = result
    return result
  }
}

const makeEmpty = () => new EvaluationContext()

export const evaluate = (
  node: LogicAST.AST.SyntaxNode,
  rootNode: LogicAST.AST.SyntaxNode,
  scopeContext: LogicScope.ScopeContext,
  unificationContext: LogicUnify.UnificationContext,
  substitution: Map<LogicUnify.Unification, LogicUnify.Unification>,
  context_: EvaluationContext = makeEmpty()
): EvaluationContext | void => {
  const context = LogicAST.subNodes(node).reduce((prev, subNode) => {
    if (!prev) {
      return undefined
    }
    return evaluate(
      subNode,
      rootNode,
      scopeContext,
      unificationContext,
      substitution,
      prev
    )
  }, context_)

  if (!context) {
    return undefined
  }

  /* TODO: handle statements */

  switch (node.type) {
    case 'boolean': {
      const { value, id } = node.data
      context.add(id, {
        label: 'Boolean Literal',
        dependencies: [],
        f: () => ({
          type: LogicUnify.bool,
          memory: {
            type: 'bool',
            value,
          },
        }),
      })
      break
    }
    case 'number': {
      const { value, id } = node.data
      context.add(id, {
        label: 'Number Literal',
        dependencies: [],
        f: () => ({
          type: LogicUnify.number,
          memory: {
            type: 'number',
            value,
          },
        }),
      })
      break
    }
    case 'string': {
      const { value, id } = node.data
      context.add(id, {
        label: 'String Literal',
        dependencies: [],
        f: () => ({
          type: LogicUnify.string,
          memory: {
            type: 'string',
            value,
          },
        }),
      })
      break
    }
    case 'color': {
      const { value, id } = node.data
      context.add(id, {
        label: 'Color Literal',
        dependencies: [],
        f: () => ({
          type: LogicUnify.color,
          memory: {
            type: 'record',
            value: {
              value: {
                type: LogicUnify.string,
                memory: {
                  type: 'string',
                  value,
                },
              },
            },
          },
        }),
      })
      break
    }
    case 'array': {
      const type = unificationContext.nodes[node.data.id]
      if (!type) {
        console.error('Failed to unify type of array')
        break
      }
      const resolvedType = LogicUnify.substitute(substitution, type)
      const dependencies = node.data.value
        .filter(x => x.type !== 'placeholder')
        .map(x => x.data.id)
      context.add(node.data.id, {
        label: 'Array Literal',
        dependencies,
        f: values => ({
          type: resolvedType,
          memory: {
            type: 'array',
            value: values,
          },
        }),
      })
      break
    }
    case 'literalExpression': {
      context.add(node.data.id, {
        label: 'Literal expression',
        dependencies: [node.data.literal.data.id],
        f: values => values[0],
      })
      break
    }
    case 'identifierExpression': {
      const { id, string } = node.data.identifier
      const patternId = scopeContext.identifierToPattern[id]

      if (!patternId) {
        break
      }
      context.add(id, {
        label: 'Identifier ' + string,
        dependencies: [patternId],
        f: values => values[0],
      })
      context.add(node.data.id, {
        label: 'IdentifierExpression ' + string,
        dependencies: [patternId],
        f: values => values[0],
      })

      break
    }
    case 'memberExpression': {
      const patternId = scopeContext.identifierToPattern[node.data.id]
      if (!patternId) {
        break
      }
      context.add(node.data.id, {
        label: 'Member expression',
        dependencies: [patternId],
        f: values => values[0],
      })

      break
    }
    case 'binaryExpression': {
      console.error('TODO: ' + node.type)
      break
    }
    case 'functionCallExpression': {
      const { expression, arguments: args } = node.data
      let functionType = unificationContext.nodes[expression.data.id]
      if (!functionType) {
        console.error('Unknown type of functionCallExpression')
        break
      }

      const resolvedType = LogicUnify.substitute(substitution, functionType)
      if (resolvedType.type !== 'function') {
        console.error(
          'Invalid functionCallExpression type (only functions are valid)',
          resolvedType
        )
        break
      }

      const dependencies = [expression.data.id].concat(
        args
          .map(arg => {
            if (
              arg.type === 'placeholder' ||
              arg.data.expression.type === 'placeholder' ||
              (arg.data.expression.type === 'identifierExpression' &&
                arg.data.expression.data.identifier.isPlaceholder)
            ) {
              return undefined
            }
            return arg.data.expression.data.id
          })
          .filter(x => !!x)
      )

      context.add(node.data.id, {
        label: 'FunctionCallExpression',
        dependencies,
        f: values => {
          const [functionValue, ...functionArgs] = values
          if (
            functionValue.memory.type !== 'function' ||
            functionValue.memory.value.type === 'path'
          ) {
            return { type: LogicUnify.unit, memory: { type: 'unit' } }
          }

          if (functionValue.memory.value.type === 'enumInit') {
            return {
              type: resolvedType.returnType,
              memory: {
                type: 'enum',
                value: functionValue.memory.value.value,
                data: functionArgs,
              },
            }
          }

          if (functionValue.memory.value.type === 'recordInit') {
            const members: [string, Value | void][] = Object.entries(
              functionValue.memory.value.value
            ).map(([key, value]) => {
              const arg = args.find(
                x =>
                  x.type === 'argument' &&
                  !!x.data.label &&
                  x.data.label === key
              )
              let argumentValue: Value | void

              if (arg && arg.type === 'argument') {
                const { expression } = arg.data
                if (
                  expression.type !== 'identifierExpression' ||
                  !expression.data.identifier.isPlaceholder
                ) {
                  const dependencyIndex = dependencies.indexOf(
                    expression.data.id
                  )

                  if (dependencyIndex !== -1) {
                    argumentValue = values[dependencyIndex]
                  }
                }
              }

              if (argumentValue) {
                return [key, argumentValue]
              }
              return [key, value[1]]
            })

            return {
              type: resolvedType.returnType,
              memory: {
                type: 'record',
                value: members.reduce((prev, m) => {
                  if (!m[1]) {
                    return prev
                  }
                  prev[m[0]] = m[1]
                  return prev
                }, {}),
              },
            }
          }
        },
      })
      break
    }
    case 'variable': {
      if (node.data.initializer) {
        context.add(node.data.name.id, {
          label: 'Variable initializer for ' + node.data.name.name,
          dependencies: [node.data.initializer.data.id],
          f: values => values[0],
        })
      }
      break
    }
    case 'function': {
      const { name } = node.data
      const type = unificationContext.patternTypes[name.id]
      const fullPath = LogicAST.declarationPathTo(rootNode, node.data.id)

      if (!type) {
        console.error('Unknown function type')
        break
      }
      context.add(name.id, {
        label: 'Function declaration for ' + name.name,
        dependencies: [],
        f: _ => ({
          type,
          memory: {
            type: 'function',
            value: {
              type: 'path',
              value: fullPath,
            },
          },
        }),
      })

      break
    }
    case 'record': {
      const { name, declarations } = node.data
      const type = unificationContext.patternTypes[name.id]
      if (!type) {
        console.error('Unknown record type')
      } else {
        const resolvedType = LogicUnify.substitute(substitution, type)
        const dependencies = declarations
          .map(x =>
            x.type === 'variable' && x.data.initializer
              ? x.data.initializer.data.id
              : undefined
          )
          .filter(x => !!x)

        context.add(name.id, {
          label: 'Record declaration for ' + name.name,
          dependencies,
          f: values => {
            const parameterTypes: {
              [key: string]: [LogicUnify.Unification, Value | void]
            } = {}
            let index = 0

            declarations.forEach(declaration => {
              if (declaration.type !== 'variable') {
                return
              }
              const parameterType =
                unificationContext.patternTypes[declaration.data.name.id]
              if (!parameterType) {
                return
              }

              let initialValue: Value | void
              if (declaration.data.initializer) {
                initialValue = values[index]
                index += 1
              }

              parameterTypes[declaration.data.name.name] = [
                parameterType,
                initialValue,
              ]
            })

            return {
              type: resolvedType,
              memory: {
                type: 'function',
                value: {
                  type: 'recordInit',
                  value: parameterTypes,
                },
              },
            }
          },
        })
      }
      break
    }
    case 'enumeration': {
      const type = unificationContext.patternTypes[node.data.name.id]

      if (!type) {
        console.error('unknown enumberation type')
        break
      }
      node.data.cases.forEach(enumCase => {
        if (enumCase.type !== 'enumerationCase') {
          return
        }
        const resolvedConsType = LogicUnify.substitute(substitution, type)
        const { name } = enumCase.data
        context.add(name.id, {
          label: 'Enum case declaration for ' + name.name,
          dependencies: [],
          f: _ => ({
            type: resolvedConsType,
            memory: {
              type: 'function',
              value: {
                type: 'enumInit',
                value: name.name,
              },
            },
          }),
        })
      })

      break
    }
  }

  return context
}
