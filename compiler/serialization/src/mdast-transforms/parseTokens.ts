import visit from 'unist-util-visit'

import { MDAST } from 'mdx-ast'
import { SERIALIZATION_FORMAT } from '../lona-format'

export default function parseTokens(
  convertTokens: (
    contents: string,
    targetFormat: SERIALIZATION_FORMAT
  ) => string
) {
  return (ast: MDAST.Root) => {
    visit(ast, 'code', (node: MDAST.Code) => {
      if (node.lang === 'tokens') {
        node.parsed = JSON.parse(
          convertTokens(node.value, SERIALIZATION_FORMAT.JSON)
        )
      }
      return node
    })
    return ast
  }
}
