const flatMap = require('unist-util-flatmap')

function moveToRoot(targetType) {
  return ast => {
    return flatMap(ast, node => {
      if (node.type === 'root') return [node]
      if (!node.children) return [node]
      if (node.children.every(child => child.type !== targetType)) return [node]
      const out = []
      let latestContiguous = Object.assign({}, node, { children: [] })
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

module.exports = moveToRoot
