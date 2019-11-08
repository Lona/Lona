const flatMap = require('unist-util-flatmap')

// type PhrasingContent = StaticPhrasingContent | Link | LinkReference
// type StaticPhrasingContent =
//   Text | Emphasis | Strong | Delete | HTML | InlineCode | Break | Image |
//   ImageReference | Footnote | FootnoteReference

const inlineTypes = [
  'text',
  'emphasis',
  'strong',
  'inlineCode',
  'break',
  'link',
]

const blockParentTypes = ['blockquote']

const isInlineNode = node => inlineTypes.includes(node.type)

const isBlockNode = node => !isInlineNode(node)

const isBlockParent = node => blockParentTypes.includes(node.type)

function convertContentModel() {
  return ast => {
    return flatMap(ast, node => {
      if (
        isBlockParent(node) &&
        node.children.some(child => child.type === 'paragraph')
      ) {
        return node.children.map(child => {
          if (child.type !== 'paragraph') return child

          return {
            type: node.type,
            children: [child],
            position: child.position,
          }
        })
      }
      return [node]
    })
  }
}

module.exports = convertContentModel
