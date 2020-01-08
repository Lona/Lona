import stringify from 'json-stable-stringify'
import uuid from 'uuid/v4'

import * as mdx from './mdx'

import {
  SERIALIZATION_FORMAT,
  normalizeFormat,
  detectFormat,
} from './lona-format'
import { convertTokens, decodeTokens, encodeTokens } from './lona-tokens'
import { convertTypes, decodeTypes, encodeTypes } from './lona-types'

import { AST } from 'lona-ast'

// Document

function decodeDocument(
  contents: string,
  format: SERIALIZATION_FORMAT
): { children: AST.Content[] } {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return JSON.parse(contents)
      case SERIALIZATION_FORMAT.SOURCE:
        return mdx.parse(contents, convertTokens)
      default:
        throw new Error(`Unknown decoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode document as ${format}.`)
  }
}

function encodeDocument(
  ast: { children: AST.Content[] },
  format: SERIALIZATION_FORMAT,
  options: {} = {}
) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return stringify(ast, { space: '  ' })
      case SERIALIZATION_FORMAT.SOURCE:
        return mdx.print(ast, convertTokens, options)
      default:
        throw new Error(`Unknown encoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to encode document as ${format}.\n${e}`)
  }
}

function convertDocument(
  contents: string,
  targetFormat: SERIALIZATION_FORMAT,
  options: {
    sourceFormat?: SERIALIZATION_FORMAT
    embeddedFormat?: boolean
  } = {}
) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat && !options.embeddedFormat) return contents

  const ast = decodeDocument(contents, sourceFormat)
  return encodeDocument(ast, targetFormat, options)
}

function extractProgram(
  contents: string,
  options: { sourceFormat?: SERIALIZATION_FORMAT } = {}
) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  const ast = decodeDocument(contents, sourceFormat)

  const { children } = ast

  const declarations = children
    .filter(child => child.type === 'code' && child.data.lang === 'tokens')
    // Get Logic syntax node
    .map((child: AST.LonaTokens) => child.data.parsed)
    // Get declarations
    .map(node => node.data.declarations)

  const flattened = [].concat(...declarations)

  const topLevelDeclarations = {
    data: {
      declarations: flattened,
      id: uuid().toUpperCase(),
    },
    type: 'topLevelDeclarations',
  }

  return stringify(topLevelDeclarations, { space: '  ' })
}

module.exports = {
  SERIALIZATION_FORMAT,
  convertTypes,
  convertLogic: convertTokens,
  convertDocument,
  decodeTypes,
  decodeLogic: decodeTokens,
  decodeDocument,
  encodeTypes,
  encodeLogic: encodeTokens,
  encodeDocument,
  extractProgram,
  detectFormat,
  printMdxNode: mdx.printNode,
}
