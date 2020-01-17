import * as LogicAST from './logic-ast'
import * as LogicTraversal from './logic-traversal'
import { ShallowMap } from '../utils/shallow-map'

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
  namespace: ShallowMap<string[], string>
  currentNamespacePath: string[]
  /* Values in these are never removed, even if a variable is out of scope */
  patternToName: { [key: string]: string }
  identifierToPattern: { [key: string]: string }
  patternToTypeName: { [key: string]: string }
  /* This keeps track of the current scope */
  patternNames: ScopeStack<string, string>
}

let empty = (): ScopeContext => ({
  namespace: new ShallowMap(),
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

export const build = (
  rootNode: LogicAST.AST.SyntaxNode,

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
    config.needsRevisitAfterTraversingChildren = true

    if (LogicAST.isTypeAnnotation(node) && !config._isRevisit) {
      config.ignoreChildren = true
      config.needsRevisitAfterTraversingChildren = false
    }

    if (node.type === 'memberExpression' && !config._isRevisit) {
      config.ignoreChildren = true
      const identifiers = LogicAST.flattenedMemberExpression(node)
      if (identifiers) {
        const keyPath = identifiers.map(x => x.string)
        const patternId = context.namespace.get(keyPath)
        if (patternId) {
          context.identifierToPattern[node.data.id] = patternId
        }
      }
    }

    if (node.type === 'variable' && config._isRevisit) {
      const { id: variableId, name: variableName } = node.data.name
      context.patternNames.set(variableName, variableId)
      context.patternToName[variableName] = variableId
    }
    if (node.type === 'function') {
      if (config._isRevisit) {
        context.patternNames.pop()
      } else {
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
      }
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
    }
    if (node.type === 'enumeration') {
      if (!config._isRevisit) {
        pushNamespace(node.data.name.name, context)

        setGenericParameters(node.data.genericParameters, context)
      } else {
        popNamespace(context)
      }
    }
    if (node.type === 'namespace') {
      if (!config._isRevisit) {
        context.patternNames.push()
        pushNamespace(node.data.name.name, context)
      } else {
        context.patternNames.pop()
        popNamespace(context)
      }
    }

    const identifier = LogicAST.getIdentifier(node)
    if (identifier && !config.ignoreChildren && !config._isRevisit) {
      if (!identifier.isPlaceholder) {
        let lookup = context.patternNames.get(identifier.string)
        if (!lookup) {
          lookup = context.namespace.get([identifier.string])
        }
        if (!lookup) {
          lookup = context.namespace.get(
            context.currentNamespacePath.concat([identifier.string])
          )
        }

        if (lookup) {
          context.identifierToPattern[identifier.id] = lookup
        } else {
          console.error(
            'Failed to find pattern for identifier:',
            identifier.string,
            node
          )
        }
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
