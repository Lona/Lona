// ⚠️ THIS FILE IS AUTO GENERATED. DO NOT MODIFY IT.

import { AST as LogicAST, flattenedMemberExpression } from './logic-ast'
import { EvaluationContext } from './logic-evaluate'

export type HardcodedMap<T> = {
  functionCallExpression: {
    'Color.setHue': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Color.setSaturation': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Color.setLightness': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Color.fromHSL': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Color.saturate': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Boolean.or': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Boolean.and': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Number.range': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'String.concat': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Array.at': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Optional.value': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'Shadow': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
    'TextStyle': (
      node: LogicAST.FunctionCallExpressionExpression,
      ...args: any[]
    ) => T | void
  }
  memberExpression: {
    'Optional.none': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.ultraLight': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.thin': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.light': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.regular': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.medium': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.semibold': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.bold': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.heavy': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.black': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w100': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w200': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w300': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w400': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w500': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w600': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w700': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w800': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
    'FontWeight.w900': (
      node: LogicAST.MemberExpressionExpression,
      ...args: any[]
    ) => T | void
  }
}

export const HandlePreludeFactory = <T>(hardcodedMap: HardcodedMap<T>) => (
  node: LogicAST.SyntaxNode,
  evaluationContext: void | EvaluationContext,
  ...args: any[]
): T | void => {
  if (!evaluationContext) {
    return
  }

  let matchedHardcodedNode: T | void

  Object.keys(hardcodedMap).forEach(
    (x: 'functionCallExpression' | 'memberExpression') => {
      if (node.type === x) {
        let memberExpression =
          'memberName' in node.data ? node : node.data.expression

        if (!evaluationContext.isFromInitialScope(memberExpression.data.id)) {
          return
        }

        const path = (flattenedMemberExpression(memberExpression) || [])
          .map(y => y.string)
          .join('.')

        if (hardcodedMap[x][path]) {
          matchedHardcodedNode = hardcodedMap[x][path](node, ...args)
        }
      }
    }
  )

  return matchedHardcodedNode
}
