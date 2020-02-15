import flatMap from 'unist-util-flatmap'

import * as MDAST from '../types/mdx-ast'

export default function moveToRoot(targetType: MDAST.Content['type'] | 'page') {
  return (ast: MDAST.Root) => {
    return flatMap(ast, (node: MDAST.Root | MDAST.Content) => {
      if (node.type === 'root') return [node]
      if (!node.children || !Array.isArray(node.children)) return [node]
      if (node.children.every(child => child.type !== targetType)) return [node]
      const out = []
      let latestContiguous = Object.assign({}, node, { children: [] as any[] })
      for (let child of node.children) {
        if (child.type !== targetType) {
          latestContiguous.children.push(child)
        } else {
          if (latestContiguous.children.length > 0) {
            out.push(latestContiguous)
          }
          out.push(child)
          latestContiguous = Object.assign({}, node, { children: [] })
        }
      }
      if (latestContiguous.children.length > 0) {
        out.push(latestContiguous)
      }
      return out
    })
  }
}
