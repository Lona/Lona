import * as serialization from '@lona/serialization'
import { Helpers } from '../../helpers'
import { Token } from '../../types/tokens-ast'
import * as TokenValue from './token-value'
import { nonNullable } from '../../utils'

export const convertDeclaration = (
  declaration: serialization.LogicAST.Declaration,
  helpers: Helpers
): Token | undefined => {
  if (!helpers.evaluationContext) {
    return undefined
  }
  if (declaration.type !== 'variable' || !declaration.data.initializer) {
    return undefined
  }
  const logicValue = helpers.evaluationContext.evaluate(
    declaration.data.initializer.data.id
  )
  const tokenValue = TokenValue.create(logicValue)

  if (!tokenValue) {
    return undefined
  }

  return { qualifiedName: [declaration.data.name.name], value: tokenValue }
}

export const convert = (
  node: serialization.LogicAST.SyntaxNode,
  helpers: Helpers
): Token[] => {
  let declarations: serialization.LogicAST.Declaration[]
  if ('type' in node && node.type === 'program') {
    declarations = node.data.block
      .map(x => (x.type === 'declaration' ? x.data.content : undefined))
      .filter(nonNullable)
  } else if ('type' in node && node.type === 'topLevelDeclarations') {
    declarations = node.data.declarations
  } else {
    helpers.reporter.warn('Unhandled top-level syntaxNode type')
    return []
  }

  return declarations
    .map(x => convertDeclaration(x, helpers))
    .filter(nonNullable)
}
