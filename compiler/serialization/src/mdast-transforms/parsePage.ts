import visit from 'unist-util-visit'
import unified from 'unified'
import rehypeParse from 'rehype-parse'

import { MDAST } from 'mdx-ast'

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
        return {
          type: 'page',
          url: href,
          value: (children[0] && children[0].value) || href,
        }
      }

      return node
    })
    return ast
  }
}
