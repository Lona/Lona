import * as AST from './types/logic-ast'

import * as json from './convert/json/logic'
import * as xml from './convert/xml/logic'
import * as swift from './convert/swift/logic'

import { normalizeFormat, SERIALIZATION_FORMAT } from './lona-format'

export function decodeLogic(contents: string, format?: SERIALIZATION_FORMAT) {
  const sourceFormat = normalizeFormat(contents, format)
  try {
    switch (sourceFormat) {
      case SERIALIZATION_FORMAT.JSON:
        return json.parse(contents)
      case SERIALIZATION_FORMAT.XML:
        return xml.parse(contents)
      case SERIALIZATION_FORMAT.SOURCE:
        return swift.parse(contents)
      default:
        throw new Error(`Unknown decoding format ${sourceFormat}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode logic as ${sourceFormat}.`)
  }
}

export function encodeLogic(ast: AST.SyntaxNode, format: SERIALIZATION_FORMAT) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return json.print(ast)
      case SERIALIZATION_FORMAT.XML:
        return xml.print(ast)
      case SERIALIZATION_FORMAT.SOURCE:
        return swift.print(ast)
      default:
        throw new Error(`Unknown encoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to encode logic as ${format}.`)
  }
}

export function convertLogic(
  contents: string,
  targetFormat: SERIALIZATION_FORMAT,
  options: { sourceFormat?: SERIALIZATION_FORMAT } = {}
) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat) return contents

  const ast = decodeLogic(contents, sourceFormat)
  return encodeLogic(ast, targetFormat)
}
