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
  genericParameters: LogicAST.AST.GenericParameter[],
  context: ScopeContext
) =>
  genericParameters.forEach(genericParameter => {
    if (genericParameter.type === 'parameter') {
      context.patternToTypeName[genericParameter.data.name.id] =
        genericParameter.data.name.name
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

function getNodeId(node: LogicAST.AST.SyntaxNode) {
  return 'id' in node ? node.id : node.data.id
}

export const build = (
  rootNode: LogicAST.AST.SyntaxNode,
  targetId?: string,
  initialContext: ScopeContext = empty()
): ScopeContext => {
  const config = LogicTraversal.emptyConfig()

  function namespaceDeclarations(
    context: ScopeContext,
    node: LogicAST.AST.SyntaxNode,
    config: LogicTraversal.TraversalConfig
  ) {
    config.needsRevisitAfterTraversingChildren = true

    if (node.type === 'variable' && config._isRevisit) {
      setInCurrentNamespace(node.data.name.name, node.data.name.id, context)
    }
    if (node.type === 'function' && config._isRevisit) {
      setInCurrentNamespace(node.data.name.name, node.data.name.id, context)
    }
    if (node.type === 'record') {
      if (!config._isRevisit) {
        /* Avoid introducing member variables into the namespace */
        config.ignoreChildren = true
      } else {
        const patternName = node.data.name.name
        /* Built-ins should be constructed using literals */
        if (builtInTypeConstructorNames.indexOf(patternName) === -1) {
          /* Create constructor function */
          setInCurrentNamespace(patternName, node.data.name.id, context)
        }
      }
    }

    if (node.type === 'enumeration' && config._isRevisit) {
      const patternName = node.data.name.name
      pushNamespace(patternName, context)

      /* Add initializers for each case into the namespace */
      node.data.cases.forEach(enumCase => {
        if (enumCase.type === 'enumerationCase') {
          setInCurrentNamespace(
            enumCase.data.name.name,
            enumCase.data.name.id,
            context
          )
        }
      })

      popNamespace(context)
    }
    if (node.type === 'namespace') {
      if (config._isRevisit) {
        popNamespace(context)
      } else {
        pushNamespace(node.data.name.name, context)
      }
    }

    return context
  }

  let walk = (
    context: ScopeContext,
    node: LogicAST.AST.SyntaxNode,
    config: LogicTraversal.TraversalConfig
  ) => {
    if (getNodeId(node) == targetId) {
      config.stopTraversal = true
      return context
    }

    config.needsRevisitAfterTraversingChildren = true

    if (LogicAST.isTypeAnnotation(node) && !config._isRevisit) {
      config.ignoreChildren = true
      config.needsRevisitAfterTraversingChildren = false
      return context
    }

    if (node.type === 'identifier' && config._isRevisit) {
      if (node.isPlaceholder) {
        return context
      }
      let lookup = context.patternNames[node.string]
      if (!lookup) {
        lookup = context.namespace.get([node.string])
      }
      if (!lookup) {
        lookup = context.namespace.get(
          context.currentNamespacePath.concat([node.string])
        )
      }

      if (lookup) {
        context.identifierToPattern[node.id] = lookup
      } else {
        console.warn('Failed to find pattern for identifier:', node.string)
      }
      return context
    }

    if (node.type === 'memberExpression' && !config._isRevisit) {
      config.ignoreChildren = true
      const identifiers = LogicAST.flattenedMemberExpression(node)
      if (!identifiers) {
        return context
      }

      const keyPath = identifiers.map(x => x.string)
      const patternId = context.namespace.get(keyPath)
      if (patternId) {
        context.identifierToPattern[node.data.id] = patternId
      }
      return context
    }

    if (node.type === 'variable' && config._isRevisit) {
      const { id: variableId, name: variableName } = node.data.name
      context.patternNames.set(variableId, variableName)
      context.patternToName[variableName] = variableId
      return context
    }
    if (node.type === 'function') {
      if (config._isRevisit) {
        context.patternNames.pop()
        return context
      }

      const { id: functionId, name: functionName } = node.data.name
      context.patternToName[functionId] = functionName
      context.patternNames.set(functionName, functionId)
      context.patternNames.push()

      node.data.parameters.forEach(parameter => {
        if (parameter.type === 'parameter') {
          const {
            id: parameterId,
            name: parameterName,
          } = parameter.data.localName
          context.patternToName[parameterId] = parameterName
          context.patternNames.set(parameterName, parameterId)
        }
      })

      setGenericParameters(node.data.genericParameters, context)

      return context
    }
    if (node.type === 'record') {
      const { id: recordId, name: recordName } = node.data.name
      if (!config._isRevisit) {
        context.patternToTypeName[recordId] = recordName
        setGenericParameters(node.data.genericParameters, context)

        node.data.declarations.forEach(declaration => {
          if (declaration.type === 'variable' && declaration.data.initializer) {
            LogicTraversal.reduce(
              declaration.data.initializer,
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
    if (node.type === 'enumeration') {
      if (!config._isRevisit) {
        pushNamespace(node.data.name.name, context)

        setGenericParameters(node.data.genericParameters, context)
      } else {
        popNamespace(context)
      }
      return context
    }
    if (node.type === 'namespace') {
      if (!config._isRevisit) {
        context.patternNames.push()
        pushNamespace(name, context)
      } else {
        context.patternNames.pop()
        popNamespace(context)
      }
      return context
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
