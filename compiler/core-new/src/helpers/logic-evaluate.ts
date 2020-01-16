import * as LogicUnify from './logic-unify'
import * as LogicAST from './logic-ast'
import * as LogicScope from './logic-scope'

type Memory =
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

type Value = {
  type: LogicUnify.Unification
  memory: Memory
}

type Thunk = {
  label: string
  dependencies: string[]
  f: (args: Value[]) => Value
}

class EvaluationContext {
  values: { [uuid: string]: Value } = {}
  thunks: { [uuid: string]: Thunk } = {}

  add(uuid: string, thunk: Thunk) {
    this.thunks[uuid] = thunk
  }

  evaluate(uuid: string) {
    const value = this.values[uuid]
    if (value) {
      return value
    }
    const thunk = this.thunks[uuid]
    if (!thunk) {
      console.warn(`no thunk for ${uuid}`)
      return undefined
    }

    const resolvedDependencies = thunk.dependencies.map<Value>(
      this.evaluate.bind(this)
    )
    if (resolvedDependencies.some(x => !x)) {
      console.warn(
        `Failed to evaluate thunk - missing dep ${
          thunk.dependencies[resolvedDependencies.findIndex(x => !x)]
        }`
      )
      return undefined
    }

    const result = thunk.f(resolvedDependencies)
    this.values[uuid] = result
    return result
  }
}

const makeEmpty = () => new EvaluationContext()

export const evaluate = (
  node: LogicAST.SyntaxNode,
  rootNode: LogicAST.SyntaxNode,
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

  if (node.type === 'literal') {
    if (node.data.type === 'boolean') {
      const { value, id } = node.data.data
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
    }
    if (node.data.type === 'number') {
      const { value, id } = node.data.data
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
    }
    if (node.data.type === 'string') {
      const { value, id } = node.data.data
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
    }
    if (node.data.type === 'color') {
      const { value, id } = node.data.data
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
    }
    if (node.data.type === 'array') {
      const type = unificationContext.nodes[node.data.data.id]
      if (!type) {
        console.warn('Failed to unify type of array')
      } else {
        const resolvedType = LogicUnify.substitute(substitution, type)
        const dependencies = node.data.data.value
          .filter(x => x.data.type !== 'placeholder')
          .map(x => x.data.data.id)
        context.add(node.data.data.id, {
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
      }
    }
  }

  if (node.type === 'expression') {
    switch (node.data.type) {
      case 'literalExpression': {
        context.add(node.data.data.id, {
          label: 'Literal expression',
          dependencies: [node.data.data.literal.data.data.id],
          f: values => values[0],
        })
        break
      }
      case 'identifierExpression': {
        const { id, string } = node.data.data.identifier.data
        const patternId = scopeContext.identifierToPattern[id]

        if (!patternId) {
          break
        }
        context.add(id, {
          label: 'Identifier ' + string,
          dependencies: [patternId],
          f: values => values[0],
        })
        context.add(node.data.data.id, {
          label: 'IdentifierExpression ' + string,
          dependencies: [patternId],
          f: values => values[0],
        })

        break
      }
      case 'memberExpression': {
        const patternId = scopeContext.identifierToPattern[node.data.data.id]
        if (!patternId) {
          break
        }
        context.add(node.data.data.id, {
          label: 'Member expression',
          dependencies: [patternId],
          f: values => values[0],
        })

        break
      }
      case 'binaryExpression': {
        console.warn('TODO: ' + node.data.type)
        break
      }
      case 'functionCallExpression': {
        const { expression, arguments: args } = node.data.data
        let functionType = unificationContext.nodes[expression.data.data.id]
        if (!functionType) {
          console.warn('Unknown type of functionCallExpression')
          break
        }

        const resolvedType = LogicUnify.substitute(substitution, functionType)
        if (resolvedType.type !== 'function') {
          console.warn(
            'Invalid functionCallExpression type (only functions are valid)',
            resolvedType
          )
          break
        }

        const dependencies = [expression.data.data.id].concat(
          args
            .map(arg => {
              if (
                arg.data.type === 'placeholder' ||
                (arg.data.data.expression.data.type ===
                  'identifierExpression' &&
                  arg.data.data.expression.data.data.identifier.data
                    .isPlaceholder)
              ) {
                return undefined
              }
              return arg.data.data.expression.data.data.id
            })
            .filter(x => !!x)
        )

        context.add(node.data.data.id, {
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
                    x.data.type === 'argument' &&
                    !!x.data.data.label &&
                    x.data.data.label === key
                )
                let argumentValue: Value | void

                if (arg && arg.data.type === 'argument') {
                  const { expression } = arg.data.data
                  if (
                    expression.data.type !== 'identifierExpression' ||
                    !expression.data.data.identifier.data.isPlaceholder
                  ) {
                    const dependencyIndex = dependencies.indexOf(
                      expression.data.data.id
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
    }
  }

  if (node.type === 'declaration') {
    if (node.data.type === 'variable' && node.data.data.initializer) {
      context.add(node.data.data.name.data.id, {
        label: 'Variable initializer for ' + node.data.data.name.data.name,
        dependencies: [node.data.data.initializer.data.data.id],
        f: values => values[0],
      })
    }
    if (node.data.type === 'function') {
      const { name } = node.data.data
      const type = unificationContext.patternTypes[name.data.id]
      const fullPath = LogicAST.declarationPathTo(rootNode, node.data.data.id)

      if (!type) {
        console.warn('Unknown function type')
      } else {
        context.add(name.data.id, {
          label: 'Function declaration for ' + name.data.name,
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
      }
    }
    if (node.data.type === 'record') {
      const { name, declarations } = node.data.data
      const type = unificationContext.patternTypes[name.data.id]
      if (!type) {
        console.warn('Unknown record type')
      } else {
        const resolvedType = LogicUnify.substitute(substitution, type)
        const dependencies = declarations
          .map(x =>
            x.data.type === 'variable' && x.data.data.initializer
              ? x.data.data.initializer.data.data.id
              : undefined
          )
          .filter(x => !!x)

        context.add(name.data.id, {
          label: 'Record declaration for ' + name.data.name,
          dependencies,
          f: values => {
            const parameterTypes: {
              [key: string]: [LogicUnify.Unification, Value | void]
            } = {}
            let index = 0

            declarations.forEach(declaration => {
              if (declaration.data.type !== 'variable') {
                return
              }
              const parameterType =
                unificationContext.patternTypes[
                  declaration.data.data.name.data.id
                ]
              if (!parameterType) {
                return
              }

              let initialValue: Value | void
              if (declaration.data.data.initializer) {
                initialValue = values[index]
                index += 1
              }

              parameterTypes[declaration.data.data.name.data.name] = [
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
    }
    if (node.data.type === 'enumeration') {
      const type = unificationContext.patternTypes[node.data.data.name.data.id]

      if (!type) {
        console.warn('unknown enumberation type')
      } else {
        node.data.data.cases.forEach(enumCase => {
          if (enumCase.data.type !== 'enumerationCase') {
            return
          }
          const resolvedConsType = LogicUnify.substitute(substitution, type)
          const { name } = enumCase.data.data
          context.add(name.data.id, {
            label: 'Enum case declaration for ' + name.data.name,
            dependencies: [],
            f: _ => ({
              type: resolvedConsType,
              memory: {
                type: 'function',
                value: {
                  type: 'enumInit',
                  value: name.data.name,
                },
              },
            }),
          })
        })
      }
    }
  }

  return context
}
