const { indentBlock, indentBlockWithFirstLinePrefix } = require('./formatting')

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
    case 'listItem': {
      const { ordered, index } = node

      if (ordered) {
        return children
          .map(toMarkdown)
          .map((md, index) => `${index + 1}. ${md}`)
      } else {
        return `- ${childrenValue()}`
      }
    }
    case 'list': {
      const { spread, ordered } = node

      const contents = children
        .map((listItem, index) => {
          const listItemContent = listItem.children.map(toMarkdown).join('\n\n')
          return indentBlockWithFirstLinePrefix(
            listItemContent,
            ordered ? `${index + 1}. ` : `- `
          )
        })
        .join('\n')

      if (spread) {
        return '\n' + contents + '\n'
      } else {
        return contents
      }
    }
    case 'blockquote': {
      return childrenValue()
        .split('\n')
        .map(line => '> ' + line)
        .join('\n')
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
    case 'break': {
      return '  \n'
    }
    default:
      throw new Error(`Unknown mdx node ${type}`)
  }
}
