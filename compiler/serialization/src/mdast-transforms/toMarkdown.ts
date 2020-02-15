import { indentBlockWithFirstLinePrefix } from '../formatting'
import * as MDAST from '../types/mdx-ast'

function assertNever(x: never): never {
  throw new Error('Unknown mdx node: ' + x['type'])
}

function childrenValue(node: MDAST.Parent, joinWith = ''): string {
  return node.children.map(toMarkdown).join(joinWith)
}

const ALIGN = {
  left: ':--',
  center: ':-:',
  right: '--:',
}

export default function toMarkdown(node: MDAST.Content | MDAST.Root): string {
  switch (node.type) {
    // Block Nodes

    case 'root': {
      return childrenValue(node, '\n\n')
    }
    case 'heading': {
      const prefix = '#'.repeat(node.depth) + ' '
      return prefix + childrenValue(node)
    }
    case 'paragraph': {
      return childrenValue(node)
    }
    case 'listItem': {
      return `- ${
        typeof node.checked !== 'undefined'
          ? `[${node.checked ? 'x' : ''}] `
          : ''
      }${childrenValue(node)}`
    }
    case 'list': {
      const { spread, ordered } = node

      const contents = node.children
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
      return childrenValue(node)
        .split('\n')
        .map(line => '> ' + line)
        .join('\n')
    }
    case 'thematicBreak': {
      return '---'
    }
    case 'code': {
      return `\`\`\`${node.lang}
${node.value}
\`\`\``
    }
    case 'table': {
      const children = node.children.map(toMarkdown)
      children.splice(
        1,
        0,
        `| ${node.children[0].children
          .map((_, i) => ALIGN[node.align ? node.align[i] || 'left' : 'left'])
          .join(' | ')} |`
      )
      return children.join('\n')
    }
    case 'tableRow': {
      return `| ${node.children.map(toMarkdown).join(' | ')} |`
    }
    case 'tableCell': {
      return childrenValue(node)
    }
    case 'html': {
      return node.value
    }
    case 'yaml': {
      return `---
${node.value}
---`
    }
    case 'definition': {
      return `[${node.identifier}]: ${node.url}`
    }
    case 'footnoteDefinition': {
      return `[^${node.identifier}]: ${childrenValue(node)}`
    }

    // Inline Block Nodes

    case 'text': {
      return node.value
    }
    case 'image': {
      return `![${node.alt}](${node.url})`
    }
    case 'link': {
      if (node.page) {
        return `<a class="page" href="${node.url}">${childrenValue(node)}</a>`
      }
      return `[${childrenValue(node)}](${node.url})`
    }
    case 'strong': {
      return `**${childrenValue(node)}**`
    }
    case 'emphasis': {
      return `_${childrenValue(node)}_`
    }
    case 'delete': {
      return `~${childrenValue(node)}~`
    }
    case 'inlineCode': {
      return `\`${node.value}\``
    }
    case 'break': {
      return '  \n'
    }
    case 'imageReference': {
      return `![${node.alt}][${node.identifier}]`
    }
    case 'footnote': {
      return `[^${childrenValue(node)}]`
    }
    case 'footnoteReference': {
      return `[^${node.identifier}]`
    }
    case 'linkReference': {
      return `[${childrenValue(node)}][${node.identifier}]`
    }

    // JSX
    case 'jsx':
    case 'export':
    case 'import': {
      return node.value
    }
    default:
      assertNever(node)
  }
}
