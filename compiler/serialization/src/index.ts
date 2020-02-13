import stringify from 'json-stable-stringify'
import uuid from 'uuid/v4'

import * as mdx from './mdx'

import {
  SERIALIZATION_FORMAT,
  normalizeFormat,
  detectFormat,
} from './lona-format'
import { convertLogic, decodeLogic, encodeLogic } from './lona-logic'
import { convertTypes, decodeTypes, encodeTypes } from './lona-types'

import * as MDXAST from './types/lona-ast'
import * as LogicAST from './types/logic-ast'

// Document

function decodeDocument(
  contents: string,
  format?: SERIALIZATION_FORMAT
): { children: MDXAST.Content[] } {
  const sourceFormat = normalizeFormat(contents, format)
  try {
    switch (sourceFormat) {
      case SERIALIZATION_FORMAT.JSON:
        return JSON.parse(contents)
      case SERIALIZATION_FORMAT.SOURCE:
        return mdx.parse(contents, convertLogic)
      default:
        throw new Error(`Unknown decoding format ${sourceFormat}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode document as ${sourceFormat}.`)
  }
}

function encodeDocument(
  ast: { children: MDXAST.Content[] },
  format: SERIALIZATION_FORMAT,
  options: {} = {}
) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return stringify(ast, { space: '  ' })
      case SERIALIZATION_FORMAT.SOURCE:
        return mdx.print(ast, convertLogic, options)
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

function extractProgramFromAST(ast: { children: MDXAST.Content[] }) {
  const { children } = ast

  const declarations = children
    .filter(child => child.type === 'code' && child.data.lang === 'tokens')
    // Get Logic syntax node
    .map((child: MDXAST.LonaTokens) => child.data.parsed)
    // Get declarations
    .map(node => node.data.declarations)

  const flattened: LogicAST.Declaration[] = [].concat(...declarations)

  const topLevelDeclarations: LogicAST.TopLevelDeclarations = {
    data: {
      declarations: flattened,
      id: uuid().toUpperCase(),
    },
    type: 'topLevelDeclarations',
  }

  return topLevelDeclarations
}

function extractProgram(
  contents: string,
  options: { sourceFormat?: SERIALIZATION_FORMAT } = {}
) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  const ast = decodeDocument(contents, sourceFormat)

  const program = extractProgramFromAST(ast)

  return stringify(program, { space: '  ' })
}

const printMdxNode = mdx.printNode

export {
  MDXAST,
  LogicAST,
  SERIALIZATION_FORMAT,
  convertTypes,
  convertLogic,
  convertDocument,
  decodeTypes,
  decodeLogic,
  decodeDocument,
  encodeTypes,
  encodeLogic,
  encodeDocument,
  extractProgram,
  detectFormat,
  printMdxNode,
  extractProgramFromAST,
}
