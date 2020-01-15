import * as LogicAST from './logic-ast'
import * as LogicTraversal from './logic-traversal'

class ScopeStack<K extends string, V> {
  private scopes: { [key: string]: V }[] = [{}]

  public get(k: K): V | void {
    return this.scopes.map(x => x[k]).filter(x => !!x)[0]
  }

  public set(k: K, v: V) {
    this.scopes[0][k] = v
  }
  public push() {
    this.scopes = [{}, ...this.scopes]
  }
  public pop(): { [key: string]: V } {
    const [hd, ...rest] = this.scopes
    this.scopes = rest
    return hd
  }
  public flattened(): { [key: string]: V } {
    let result: { [key: string]: V } = {}

    this.scopes.reverse().forEach(x =>
      Object.keys(x).forEach(k => {
        result[k] = x[k]
      })
    )

    return result
  }
}

let pushNamespace = (name: string, context: ScopeContext) =>
  context.currentNamespacePath.push(name)

let popNamespace = (context: ScopeContext) => context.currentNamespacePath.pop()

let setInCurrentNamespace = (
  name: string,
  value: string,
  context: ScopeContext
) => context.namespace.set(context.currentNamespacePath.concat([name]), value)

let setGenericParameters = (
  genericParameters: LogicAST.GenericParameter[],
  context: ScopeContext
) =>
  genericParameters.forEach(genericParameter => {
    if (genericParameter.data.type === 'parameter') {
      context.patternToTypeName[genericParameter.data.data.name.data.id] =
        genericParameter.data.data.name.data.name
    }
  })

export type ScopeContext = {
  namespace: Map<string[], string>
  currentNamespacePath: string[]
  /* Values in these are never removed, even if a variable is out of scope */
  patternToName: { [key: string]: string }
  identifierToPattern: { [key: string]: string }
  patternToTypeName: { [key: string]: string }
  /* This keeps track of the current scope */
  patternNames: ScopeStack<string, string>
}

let empty = (): ScopeContext => ({
  namespace: new Map(),
  currentNamespacePath: [],
  patternToName: {},
  identifierToPattern: {},
  patternToTypeName: {},
  patternNames: new ScopeStack(),
})

let builtInTypeConstructorNames = [
  'Boolean',
  'Number',
  'String',
  'Array',
  'Color',
]

function getNodeId(node: LogicAST.SyntaxNode) {
  return 'id' in node.data ? node.data.id : node.data.data.id
}

export const build = (
  rootNode: LogicAST.SyntaxNode,
  targetId?: string,
  initialContext: ScopeContext = empty()
): ScopeContext => {
  const config = LogicTraversal.emptyConfig()

  function namespaceDeclarations(
    context: ScopeContext,
    node: LogicAST.SyntaxNode,
    config: LogicTraversal.TraversalConfig
  ) {
    config.needsRevisitAfterTraversingChildren = true

    if (node.type === 'declaration') {
      if (node.data.type === 'variable' && config._isRevisit) {
        setInCurrentNamespace(
          node.data.data.name.data.name,
          node.data.data.name.data.id,
          context
        )
      }
      if (node.data.type === 'function' && config._isRevisit) {
        setInCurrentNamespace(
          node.data.data.name.data.name,
          node.data.data.name.data.id,
          context
        )
      }
      if (node.data.type === 'record') {
        if (!config._isRevisit) {
          /* Avoid introducing member variables into the namespace */
          config.ignoreChildren = true
        } else {
          const patternName = node.data.data.name.data.name
          /* Built-ins should be constructed using literals */
          if (builtInTypeConstructorNames.indexOf(patternName) === -1) {
            /* Create constructor function */
            setInCurrentNamespace(
              patternName,
              node.data.data.name.data.id,
              context
            )
          }
        }
      }
      if (node.data.type === 'enumeration' && config._isRevisit) {
        const patternName = node.data.data.name.data.name
        pushNamespace(patternName, context)

        /* Add initializers for each case into the namespace */
        node.data.data.cases.forEach(enumCase => {
          if (enumCase.data.type === 'enumerationCase') {
            setInCurrentNamespace(
              enumCase.data.data.name.data.name,
              enumCase.data.data.name.data.id,
              context
            )
          }
        })

        popNamespace(context)
      }
      if (node.data.type === 'namespace') {
        if (config._isRevisit) {
          popNamespace(context)
        } else {
          pushNamespace(node.data.data.name.data.name, context)
        }
      }
    }

    return context
  }

  let walk = (
    context: ScopeContext,
    node: LogicAST.SyntaxNode,
    config: LogicTraversal.TraversalConfig
  ) => {
    if (getNodeId(node) == targetId) {
      config.stopTraversal = true
      return context
    }

    config.needsRevisitAfterTraversingChildren = true

    if (node.type === 'typeAnnotation' && !config._isRevisit) {
      config.ignoreChildren = true
      config.needsRevisitAfterTraversingChildren = false
      return context
    }

    if (node.type === 'identifier' && config._isRevisit) {
      if (node.data.isPlaceholder) {
        return context
      }
      let lookup = context.patternNames[node.data.string]
      if (!lookup) {
        lookup = context.namespace.get([node.data.string])
      }
      if (!lookup) {
        lookup = context.namespace.get(
          context.currentNamespacePath.concat([node.data.string])
        )
      }

      if (lookup) {
        context.identifierToPattern[node.data.id] = lookup
      } else {
        console.warn('Failed to find pattern for identifier:', node.data.string)
      }
      return context
    }

    if (
      node.type === 'expression' &&
      node.data.type === 'memberExpression' &&
      !config._isRevisit
    ) {
      config.ignoreChildren = true
      const identifiers = LogicAST.flattenedMemberExpression(node)
      if (!identifiers) {
        return context
      }

      const keyPath = identifiers.map(x => x.data.string)
      const patternId = context.namespace.get(keyPath)
      if (patternId) {
        context.identifierToPattern[node.data.data.id] = patternId
      }
      return context
    }

    if (node.type === 'declaration') {
      if (node.data.type === 'variable' && config._isRevisit) {
        const { id: variableId, name: variableName } = node.data.data.name.data
        context.patternNames.set(variableId, variableName)
        context.patternToName[variableName] = variableId
        return context
      }
      if (node.data.type === 'function') {
        if (config._isRevisit) {
          context.patternNames.pop()
          return context
        }

        const { id: functionId, name: functionName } = node.data.data.name.data
        context.patternToName[functionId] = functionName
        context.patternNames.set(functionName, functionId)
        context.patternNames.push()

        node.data.data.parameters.forEach(parameter => {
          if (parameter.data.type === 'parameter') {
            const {
              id: parameterId,
              name: parameterName,
            } = parameter.data.data.localName.data
            context.patternToName[parameterId] = parameterName
            context.patternNames.set(parameterName, parameterId)
          }
        })

        setGenericParameters(node.data.data.genericParameters, context)

        return context
      }
      if (node.data.type === 'record') {
        const { id: recordId, name: recordName } = node.data.data.name.data
        if (!config._isRevisit) {
          context.patternToTypeName[recordId] = recordName
          setGenericParameters(node.data.data.genericParameters, context)

          node.data.data.declarations.forEach(declaration => {
            if (
              declaration.data.type === 'variable' &&
              declaration.data.data.initializer
            ) {
              LogicTraversal.reduce(
                declaration.data.data.initializer,
                config,
                context,
                walk
              )
            }
          })

          config.ignoreChildren = true
        } else {
          if (builtInTypeConstructorNames.indexOf(recordName) === -1) {
            context.patternToName[recordId] = recordName
            context.patternNames.set(recordName, recordId)
          }
        }
        return context
      }
      if (node.data.type === 'enumeration') {
        if (!config._isRevisit) {
          pushNamespace(node.data.data.name.data.name, context)

          setGenericParameters(node.data.data.genericParameters, context)
        } else {
          popNamespace(context)
        }
        return context
      }
      if (node.data.type === 'namespace') {
        if (!config._isRevisit) {
          context.patternNames.push()
          pushNamespace(name, context)
        } else {
          context.patternNames.pop()
          popNamespace(context)
        }
        return context
      }
    }
    return context
  }

  const contextWithNamespaceDeclarations = LogicTraversal.reduce(
    rootNode,
    config,
    initialContext,
    namespaceDeclarations
  )

  return LogicTraversal.reduce(
    rootNode,
    config,
    contextWithNamespaceDeclarations,
    walk
  )
}
