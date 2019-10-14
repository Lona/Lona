const visit = require('unist-util-visit')

function flattenParagraphs(targetType) {
  return ast => {
    visit(ast, targetType, node => {
      if (node.children.length === 1 && node.children[0].type === 'paragraph') {
        node.children = node.children[0].children
      }
      return node
    })
    return ast
  }
}

module.exports = flattenParagraphs
