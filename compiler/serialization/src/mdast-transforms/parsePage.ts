import visit from 'unist-util-visit'
import unified from 'unified'
import rehypeParse from 'rehype-parse'

import * as MDAST from '../types/mdx-ast'

const htmlParser = unified().use(rehypeParse, { fragment: true })

export default function parsePage() {
  return (ast: MDAST.Root) => {
    visit(ast, 'jsx', (node: MDAST.JSX) => {
      const {
        type,
        tagName,
        properties: { className, href },
        children = [],
      } = htmlParser.parse(node.value).children[0]

      if (
        type === 'element' &&
        tagName === 'a' &&
        Array.isArray(className) &&
        className.includes('page')
      ) {
        // @ts-ignore
        node.type = 'page'
        node.url = href
        node.value = (children[0] && children[0].value) || href
      }

      return node
    })
    return ast
  }
}
