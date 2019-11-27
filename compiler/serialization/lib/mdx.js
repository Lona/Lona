const mdx = require('@mdx-js/mdx')

const unified = require('unified')
const rehypeParse = require('rehype-parse')
const htmlParser = unified().use(rehypeParse, { fragment: true })

const flattenImageParagraphs = require('mdast-flatten-image-paragraphs')()
// const moveImagesToRoot = require('mdast-move-images-to-root')()

const convertContentModel = require('./mdast/mdastConvertContentModel')()
const flattenParagraphs = require('./mdast/flattenParagraphs')
const moveToRoot = require('./mdast/moveToRoot')

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

function removeExtras(ast) {
  return map(ast, node => {
    delete node.position
    return node
  })
}

function parseNested(ast) {
  return map(ast, node => {
    if (node.type === 'code' && node.lang === 'tokens') {
      node.parsed = JSON.parse(convertLogic(node.value, 'json'))
    }

    if (node.type === 'jsx') {
      const {
        type,
        tagName,
        properties: { className, href },
      } = htmlParser.parse(node.value).children[0]

      if (
        type === 'element' &&
        tagName === 'a' &&
        Array.isArray(className) &&
        className.includes('page')
      ) {
        return {
          type: 'page',
          value: href,
        }
      }
    }

    return node
  })
}

function parse(src, convertLogic) {
  const mdast = getOutputs(src).mdast

  const transforms = [
    flattenImageParagraphs,
    flattenParagraphs('blockquote'),
    moveToRoot('image'),
    moveToRoot('blockquote'),
    removeExtras,
    parseNested,
    moveToRoot('page'),
  ]

  const transformed = transforms.reduce((result, f) => f(result), mdast)

  const normalizedFormat = map(transformed, node => {
    const { type, ...rest } = node

    return { type, data: rest }
  })

  return normalizedFormat.data
}

// Convert our internal md format to mdast
function toMdast(node) {
  const { type, data } = node

  const { children = [] } = data

  return { type, ...data, children: children.map(toMdast) }
}

// Print a block in our internal format to a markdown string
function printNode(mdxBlockNode) {
  return toMarkdown(toMdast(mdxBlockNode))
}

function print(normalizedFormat, convertLogic, options = {}) {
  const ast = { type: 'root', children: normalizedFormat.children.map(toMdast) }

  const encodedTokensAst = map(ast, node => {
    if (node.type === 'code' && node.lang === 'tokens') {
      const embeddedFormat = options.embeddedFormat || 'xml'
      let value = convertLogic(JSON.stringify(node.parsed), embeddedFormat)
      // Prettify embedded JSON
      if (embeddedFormat === 'json') {
        value = JSON.stringify(JSON.parse(value), null, 2)
      }
      node.value = value
      delete node.parsed
    }

    return node
  })

  return toMarkdown(encodedTokensAst)
}

module.exports = {
  parse,
  print,
  printNode,
}
