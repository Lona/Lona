import visit from 'unist-util-visit'

import * as MDAST from '../types/mdx-ast'

export default function flattenParagraphs(
  targetType: MDAST.BlockContent['type']
) {
  return (ast: MDAST.Root) => {
    visit(ast, targetType, (node: MDAST.Parent) => {
      if (node.children.length === 1 && node.children[0].type === 'paragraph') {
        node.children = node.children[0].children
      }
      return node
    })
    return ast
  }
}
