const mdx = require('@mdx-js/mdx')

const flattenImageParagraphs = require('mdast-flatten-image-paragraphs')()
const moveImagesToRoot = require('mdast-move-images-to-root')()

const toMarkdown = require('./mdastUtilToMarkdown')

const getOutputs = src => {
  let mdast = {}
  let hast = {}

  let jsx = mdx.sync(src, {
    skipExport: true,
    remarkPlugins: [
      () => ast => {
        mdast = ast
        return ast
      },
    ],
    rehypePlugins: [
      () => ast => {
        hast = ast
        return ast
      },
    ],
  })

  return { jsx, mdast, hast }
}

// Map mdast tree
function map(node, f) {
  const { children = [] } = node
  return f({
    ...node,
    children: children.map(child => map(child, f)),
  })
}

function parse(src, convertLogic) {
  const mdast = getOutputs(src).mdast

  const flattened = moveImagesToRoot(flattenImageParagraphs(mdast))

  const withoutExtras = map(flattened, node => {
    delete node.position
    return node
  })

  const parsed = map(withoutExtras, node => {
    if (node.type === 'code' && node.lang === 'tokens') {
      node.parsed = JSON.parse(
        convertLogic(node.value, 'json', { sourceFormat: 'xml' })
      )
    }

    return node
  })

  const normalizedFormat = map(parsed, node => {
    const { type, ...rest } = node

    return { type, data: rest }
  })

  return normalizedFormat.data
}

function print(normalizedFormat, convertLogic) {
  function toAst(node) {
    const { type, data } = node

    const { children = [] } = data

    return { type, ...data, children: children.map(toAst) }
  }

  const ast = { type: 'root', children: normalizedFormat.children.map(toAst) }

  const encodedTokensAst = map(ast, node => {
    if (node.type === 'code' && node.lang === 'tokens') {
      node.value = convertLogic(JSON.stringify(node.parsed), 'xml', {
        sourceFormat: 'json',
      })
      delete node.parsed
    }

    return node
  })

  return toMarkdown(encodedTokensAst)
}

module.exports = {
  parse,
  print,
}
