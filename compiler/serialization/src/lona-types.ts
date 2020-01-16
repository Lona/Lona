import * as json from './convert/json/types'
import * as xml from './convert/xml/types'

import { normalizeFormat, SERIALIZATION_FORMAT } from './lona-format'

export function decodeTypes(contents: string, format?: SERIALIZATION_FORMAT) {
  const sourceFormat = normalizeFormat(contents, format)
  try {
    switch (sourceFormat) {
      case SERIALIZATION_FORMAT.JSON:
        return json.parse(contents)
      case SERIALIZATION_FORMAT.XML:
        return xml.parse(contents)
      default:
        throw new Error(`Unknown decoding format ${sourceFormat}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode types as ${sourceFormat}.`)
  }
}

export function encodeTypes(ast: Object, format: SERIALIZATION_FORMAT) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return json.print(ast)
      case SERIALIZATION_FORMAT.XML:
        return xml.print(ast)
      default:
        throw new Error(`Unknown encoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to encode types as ${format}.`)
  }
}

export function convertTypes(
  contents: string,
  targetFormat: SERIALIZATION_FORMAT,
  options: { sourceFormat?: SERIALIZATION_FORMAT } = {}
) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat) return contents

  const ast = decodeTypes(contents, sourceFormat)
  return encodeTypes(ast, targetFormat)
}
