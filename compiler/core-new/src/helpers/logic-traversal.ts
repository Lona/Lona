import * as LogicAST from './logic-ast'

enum TraversalOrder {
  PreOrder = 'PreOrder',
  PostOrder = 'PostOrder',
}

export type TraversalConfig = {
  order: TraversalOrder
  ignoreChildren: boolean
  stopTraversal: boolean
  needsRevisitAfterTraversingChildren: boolean
  _isRevisit: boolean
}

export let emptyConfig = (): TraversalConfig => ({
  order: TraversalOrder.PreOrder,
  ignoreChildren: false,
  stopTraversal: false,
  needsRevisitAfterTraversingChildren: false,
  _isRevisit: false,
})

function reduceChildren<T>(
  node: LogicAST.AST.SyntaxNode,
  config: TraversalConfig,
  initialResult: T,
  f: (x: T, node: LogicAST.AST.SyntaxNode, config: TraversalConfig) => T
): T {
  return LogicAST.subNodes(node).reduce<T>((prev, x) => {
    if (config.stopTraversal) {
      return prev
    }
    return reduce(x, config, prev, f)
  }, initialResult)
}

export const reduce = function<T>(
  node: LogicAST.AST.SyntaxNode,
  config: TraversalConfig,
  initialResult: T,
  f: (x: T, node: LogicAST.AST.SyntaxNode, config: TraversalConfig) => T
) {
  if (config.stopTraversal) {
    return initialResult
  }

  if (config.order === TraversalOrder.PostOrder) {
    const result = reduceChildren(node, config, initialResult, f)

    if (config.stopTraversal) {
      return result
    }

    return f(result, node, config)
  } else {
    let result = f(initialResult, node, config)

    const shouldRevisit = config.needsRevisitAfterTraversingChildren

    if (config.ignoreChildren) {
      config.ignoreChildren = false
    } else {
      result = reduceChildren(node, config, result, f)
    }

    if (!config.stopTraversal && shouldRevisit) {
      config._isRevisit = true
      result = f(result, node, config)
      config._isRevisit = false
      config.ignoreChildren = false
    }

    return result
  }
}
