import mdx from '@mdx-js/mdx'

import FlattenImageParagraphs from 'mdast-flatten-image-paragraphs'
import flattenParagraphs from './mdast-transforms/flattenParagraphs'
import moveToRoot from './mdast-transforms/moveToRoot'
import toMarkdown from './mdast-transforms/toMarkdown'
import parsePage from './mdast-transforms/parsePage'
import parseTokens from './mdast-transforms/parseTokens'

import { SERIALIZATION_FORMAT } from './lona-format'

import * as MDAST from './types/mdx-ast'
import * as AST from './types/lona-ast'

const flattenImageParagraphs = FlattenImageParagraphs()

const getOutputs = (src: string) => {
  let mdast: MDAST.Root
  let hast: any = {}

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
function map<U>(node: any, f: (node: any) => any): U {
  if (node['children'] && Array.isArray(node['children'])) {
    const mappedChildren = node['children'].map(child => map(child, f))
    return f({ ...node, children: mappedChildren })
  }

  return f(node)
}

function removeExtras(ast: MDAST.Root) {
  return map(ast, node => {
    delete node.position
    return node
  })
}

export function parse(
  src: string,
  convertTokens: (
    contents: string,
    targetFormat: SERIALIZATION_FORMAT
  ) => string
) {
  const mdast = getOutputs(src).mdast

  const transforms = [
    flattenImageParagraphs,
    flattenParagraphs('blockquote'),
    moveToRoot('image'),
    moveToRoot('blockquote'),
    removeExtras,
    parsePage(),
    parseTokens(convertTokens),
    moveToRoot('page'),
  ]

  const transformed: MDAST.Root = transforms.reduce(
    (result, f) => f(result),
    mdast
  )

  const normalizedFormat: AST.Root = map(transformed, node => {
    const { type, ...rest } = node

    return { type, data: rest }
  })

  return normalizedFormat.data
}

// Convert our internal md format to mdast
function toMdast(node: AST.Content): MDAST.Content {
  const { type, data } = node

  if (node.type === 'page') {
    return {
      type: 'link',
      url: node.data.url,
      children: [
        {
          type: 'text',
          value: node.data.value,
        },
      ],
      page: true,
    }
  }

  if (data['children'] && Array.isArray(data['children'])) {
    // @ts-ignore
    return { type, ...data, children: data['children'].map(toMdast) }
  }

  // @ts-ignore
  return { type, ...data }
}

// Print a block in our internal format to a markdown string
export function printNode(mdxBlockNode: AST.Content) {
  return toMarkdown(toMdast(mdxBlockNode))
}

export function print(
  normalizedFormat: { children: AST.Content[] },
  convertTokens: (
    contents: string,
    targetFormat: SERIALIZATION_FORMAT
  ) => string,
  options: { embeddedFormat?: SERIALIZATION_FORMAT } = {}
) {
  const ast = { type: 'root', children: normalizedFormat.children.map(toMdast) }

  const encodedTokensAst = map<MDAST.Root>(ast, node => {
    if (node.type === 'code' && node.lang === 'tokens') {
      const embeddedFormat = options.embeddedFormat || SERIALIZATION_FORMAT.XML
      let value = convertTokens(JSON.stringify(node.parsed), embeddedFormat)
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
