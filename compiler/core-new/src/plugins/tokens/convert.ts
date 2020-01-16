import * as serialization from '@lona/serialization'
import { Helpers } from '../../helpers'
import { Token } from './tokens-ast'
import * as TokenValue from './token-value'

const convertDeclaration = (
  declaration: serialization.LogicAST.Declaration,
  helpers: Helpers
): Token | void => {
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
  if (node.type === 'program') {
    declarations = node.data.block
      .map(x => (x.type === 'declaration' ? x.data.content : undefined))
      .filter(x => !!x)
  } else if (node.type === 'topLevelDeclarations') {
    declarations = node.data.declarations.filter(x => x.type !== 'placeholder')
  } else {
    helpers.reporter.warn('Unhandled top-level syntaxNode type')
    return []
  }

  // @ts-ignore
  return declarations.map(x => convertDeclaration(x, helpers)).filter(x => !!x)
}
