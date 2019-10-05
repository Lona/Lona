module.exports = function toMarkdown(node) {
  const { children = [], type } = node

  function childrenValue(joinWith = '') {
    return children.map(toMarkdown).join(joinWith)
  }

  switch (type) {
    case 'root': {
      return childrenValue('\n\n')
    }
    case 'text': {
      return node.value
    }
    case 'heading': {
      const prefix = '#'.repeat(node.depth) + ' '
      return prefix + childrenValue()
    }
    case 'paragraph': {
      return childrenValue()
    }
    case 'code': {
      return `\`\`\`tokens
${node.value}
\`\`\``
    }
    case 'strong': {
      return `**${childrenValue()}**`
    }
    case 'emphasis': {
      return `_${childrenValue()}_`
    }
    case 'inlineCode': {
      return `\`${node.value}\``
    }
    default:
      throw new Error(`Unknown mdx node ${type}`)
  }
}
