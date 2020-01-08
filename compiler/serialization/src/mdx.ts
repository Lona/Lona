import mdx from '@mdx-js/mdx'

import FlattenImageParagraphs from 'mdast-flatten-image-paragraphs'
import flattenParagraphs from './mdast/flattenParagraphs'
import moveToRoot from './mdast/moveToRoot'
import toMarkdown from './mdast/toMarkdown'

import { SERIALIZATION_FORMAT } from './lona-format'

import { MDAST } from 'mdx-ast'
import { AST } from 'lona-ast'

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
  ]

  const flattened: MDAST.Root = transforms.reduce(
    (result, f) => f(result),
    mdast
  )

  const withoutExtras = map(flattened, node => {
    delete node.position
    return node
  })

  const parsed = map(withoutExtras, node => {
    if (
      node.type === 'code' &&
      node.lang === 'tokens' &&
      typeof node.value == 'string'
    ) {
      node.parsed = JSON.parse(
        convertTokens(node.value, SERIALIZATION_FORMAT.JSON)
      )
    }

    return node
  })

  const normalizedFormat: AST.Root = map(parsed, node => {
    const { type, ...rest } = node

    return { type, data: rest }
  })

  return normalizedFormat.data
}

// Convert our internal md format to mdast
function toMdast(node: AST.Content): MDAST.Content {
  const { type, data } = node

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
