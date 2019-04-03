const xml = require('./xml')
const {
  convertTypesJsonToXml,
  convertTypesXmlToJson,
} = require('./convert/types')

const SERIALIZATION_FORMAT = {
  JSON: 'json',
  XML: 'xml',
}

function detectFormat(contents) {
  if (contents.startsWith('{') || contents.startsWith('[')) {
    return SERIALIZATION_FORMAT.JSON
  }
  if (contents.startsWith('<')) {
    return SERIALIZATION_FORMAT.XML
  }

  return null
}

function convertTypes(contents, targetFormat, options = {}) {
  const sourceFormat = options.sourceFormat || detectFormat(contents)

  if (!sourceFormat) {
    throw new Error(
      `Unable to detect source Serialization format, and none was specified`
    )
  }

  if (!Object.values(SERIALIZATION_FORMAT).includes(sourceFormat)) {
    throw new Error(
      `Invalid source Serialization format specified: ${sourceFormat}`
    )
  }

  if (!Object.values(SERIALIZATION_FORMAT).includes(targetFormat)) {
    throw new Error(
      `Invalid target Serialization format specified: ${targetFormat}`
    )
  }

  switch (`${sourceFormat}:${targetFormat}`) {
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
      throw new Error(`Unknown Serialization conversion`)
  }
}

module.exports = {
  SERIALIZATION_FORMAT,
  convertTypes,
  detectFormat,
}
