const stringify = require('json-stable-stringify')
const uuid = require('uuid/v4')

const xml = require('./xml')
const mdx = require('./mdx')
const swift = require('./swift')

const {
  convertTypesJsonToXml,
  convertTypesXmlToJson,
} = require('./convert/types')
const {
  convertLogicJsonToXml,
  convertLogicXmlToJson,
} = require('./convert/logic')

// Format

const SERIALIZATION_FORMAT = {
  JSON: 'json',
  XML: 'xml',
  SOURCE: 'source',
}

function detectFormat(contents) {
  if (contents.startsWith('{') || contents.startsWith('[')) {
    return SERIALIZATION_FORMAT.JSON
  }
  if (contents.startsWith('<')) {
    return SERIALIZATION_FORMAT.XML
  }
  return SERIALIZATION_FORMAT.SOURCE
}

function normalizeFormat(contents, sourceFormat) {
  const normalized = sourceFormat || detectFormat(contents)

  if (!Object.values(SERIALIZATION_FORMAT).includes(normalized)) {
    throw new Error(
      `Invalid source serialization format specified: ${normalized}`
    )
  }

  return normalized
}

// Types

function decodeTypes(contents, format) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return JSON.parse(contents)
      case SERIALIZATION_FORMAT.XML:
        return convertTypesXmlToJson(xml.parse(contents))
      default:
        throw new Error(`Unknown decoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode logic as ${format}.`)
  }
}

function encodeTypes(ast, format) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return stringify(ast, { space: '  ' })
      case SERIALIZATION_FORMAT.XML:
        const types = convertTypesJsonToXml(ast)
        return xml.build({ name: 'root', children: types })
      default:
        throw new Error(`Unknown encoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to encode types as ${format}.`)
  }
}

function convertTypes(contents, targetFormat, options = {}) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat) return contents

  const ast = decodeTypes(contents, sourceFormat)
  return encodeTypes(ast, targetFormat)
}

// Logic

function decodeLogic(contents, format) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return JSON.parse(contents)
      case SERIALIZATION_FORMAT.XML:
        return convertLogicXmlToJson(xml.parse(contents))
      case SERIALIZATION_FORMAT.SOURCE:
        return swift.parse(contents)
      default:
        throw new Error(`Unknown decoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode logic as ${format}.`)
  }
}

function encodeLogic(ast, format) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return stringify(ast, { space: '  ' })
      case SERIALIZATION_FORMAT.XML:
        const xmlRepresentation = convertLogicJsonToXml(ast)
        return xml.build(xmlRepresentation)
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

function convertLogic(contents, targetFormat, options = {}) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat) return contents

  const ast = decodeLogic(contents, sourceFormat)
  return encodeLogic(ast, targetFormat)
}

// Document

function decodeDocument(contents, format) {
  try {
    switch (format) {
      case SERIALIZATION_FORMAT.JSON:
        return JSON.parse(contents)
      case SERIALIZATION_FORMAT.SOURCE:
        return mdx.parse(contents, convertLogic)
      default:
        throw new Error(`Unknown decoding format ${format}`)
    }
  } catch (e) {
    console.error(e)
    throw new Error(`Failed to decode document as ${format}.`)
  }
}

function encodeDocument(ast, format, options) {
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

function convertDocument(contents, targetFormat, options = {}) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  if (sourceFormat === targetFormat && !options.embeddedFormat) return contents

  const ast = decodeDocument(contents, sourceFormat)
  return encodeDocument(ast, targetFormat, options)
}

function extractProgram(contents, options = {}) {
  const sourceFormat = normalizeFormat(contents, options.sourceFormat)

  const ast = decodeDocument(contents, sourceFormat)

  const { children } = ast

  const declarations = children
    .filter(child => child.type === 'code' && child.data.lang === 'tokens')
    // Get Logic syntax node
    .map(child => child.data.parsed)
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
}
