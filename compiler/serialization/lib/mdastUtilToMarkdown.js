module.exports = function toMarkdown(node) {
  const { children = [], type } = node

  function childrenValue(joinWith = '') {
    return children.map(toMarkdown).join(joinWith)
  }

  switch (type) {
    // Block Nodes

    case 'root': {
      return childrenValue('\n\n')
    }
    case 'heading': {
      const prefix = '#'.repeat(node.depth) + ' '
      return prefix + childrenValue()
    }
    case 'paragraph': {
      return childrenValue()
    }
    case 'thematicBreak': {
      return '---'
    }
    case 'code': {
      return `\`\`\`tokens
${node.value}
\`\`\``
    }

    // Inline Block Nodes

    case 'text': {
      return node.value
    }
    case 'image': {
      return `![${node.alt}](${node.url})`
    }
    case 'link': {
      return `[${childrenValue()}](${node.url})`
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
