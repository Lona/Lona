import stringify from 'json-stable-stringify'
import * as AST from '../../types/types-ast'

export function print(ast: AST.Root) {
  return stringify(ast, { space: '  ' })
}

export function parse(contents: string): AST.Root {
  return JSON.parse(contents)
}
