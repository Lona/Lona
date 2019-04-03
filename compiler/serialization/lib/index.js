const xml = require('./xml')
const {
  convertTypesJsonToXml,
  convertTypesXmlToJson,
} = require('./convert/types')

const ENCODING_FORMAT = {
  JSON: 'json',
  XML: 'xml',
}

function detectEncodingFormat(contents) {
  if (contents.startsWith('{') || contents.startsWith('[')) {
    return ENCODING_FORMAT.JSON
  }
  if (contents.startsWith('<')) {
    return ENCODING_FORMAT.XML
  }

  return null
}

function convertTypes(contents, targetEncodingFormat, options = {}) {
  const sourceEncodingFormat =
    options.sourceEncodingFormat || detectEncodingFormat(contents)

  if (!sourceEncodingFormat) {
    throw new Error(
      `Unable to detect source encoding format, and none was specified`
    )
  }

  if (!Object.values(ENCODING_FORMAT).includes(sourceEncodingFormat)) {
    throw new Error(
      `Invalid source encoding format specified: ${sourceEncodingFormat}`
    )
  }

  if (!Object.values(ENCODING_FORMAT).includes(targetEncodingFormat)) {
    throw new Error(
      `Invalid target encoding format specified: ${targetEncodingFormat}`
    )
  }

  switch (`${sourceEncodingFormat}:${targetEncodingFormat}`) {
    case 'json:json':
    case 'xml:xml':
      return contents
    case 'json:xml': {
      let jsonContents

      try {
        jsonContents = JSON.parse(contents)
      } catch (e) {
        throw new Error(`Failed to decode types as JSON.`)
      }

      const types = convertTypesJsonToXml(jsonContents)

      return xml.build(types)
    }
    case 'xml:json': {
      let jsonContents

      try {
        jsonContents = xml.parse(contents)
      } catch (e) {
        throw new Error(`Failed to decode types as XML.`)
      }

      const types = convertTypesXmlToJson(jsonContents)

      return JSON.stringify(types, null, 2)
    }
    default:
      throw new Error(`Unknown encoding conversion`)
  }
}

module.exports = {
  ENCODING_FORMAT,
  convertTypes,
  detectEncodingFormat,
}
