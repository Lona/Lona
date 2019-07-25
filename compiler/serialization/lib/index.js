const stringify = require('json-stable-stringify')

const xml = require('./xml')
const {
  convertTypesJsonToXml,
  convertTypesXmlToJson,
} = require('./convert/types')
const {
  convertLogicJsonToXml,
  convertLogicXmlToJson,
} = require('./convert/logic')

const SERIALIZATION_FORMAT = {
  JSON: 'json',
  XML: 'xml',
}

const CONVERSION_TYPE = {
  XML_TO_JSON: 'xmlToJSON',
  JSON_TO_XML: 'jsonToXML',
  NONE: 'none',
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

function detectConversionType(contents, targetFormat, options = {}) {
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
      return CONVERSION_TYPE.NONE
    case 'json:xml': {
      return CONVERSION_TYPE.JSON_TO_XML
    }
    case 'xml:json': {
      return CONVERSION_TYPE.XML_TO_JSON
    }
    default:
      throw new Error(`Unknown Serialization conversion`)
  }
}

function convertTypes(contents, targetFormat, options = {}) {
  const conversionType = detectConversionType(contents, targetFormat, options)

  switch (conversionType) {
    case CONVERSION_TYPE.NONE:
      return contents
    case CONVERSION_TYPE.JSON_TO_XML: {
      let jsonContents

      try {
        jsonContents = JSON.parse(contents)
      } catch (e) {
        throw new Error(`Failed to decode types as JSON.`)
      }

      const types = convertTypesJsonToXml(jsonContents)

      return xml.build({ name: 'root', children: types })
    }
    case CONVERSION_TYPE.XML_TO_JSON: {
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

function convertLogic(contents, targetFormat, options = {}) {
  const conversionType = detectConversionType(contents, targetFormat, options)

  switch (conversionType) {
    case CONVERSION_TYPE.NONE:
      return contents
    case CONVERSION_TYPE.JSON_TO_XML: {
      let jsonContents

      try {
        jsonContents = JSON.parse(contents)
      } catch (e) {
        throw new Error(`Failed to decode types as JSON.`)
      }

      const xmlRepresentation = convertLogicJsonToXml(jsonContents)

      return xml.build(xmlRepresentation)
    }
    case CONVERSION_TYPE.XML_TO_JSON: {
      let jsonContents

      try {
        jsonContents = xml.parse(contents)
      } catch (e) {
        console.log(e)
        throw new Error(`Failed to decode types as XML.`)
      }

      const jsonRepresentation = convertLogicXmlToJson(jsonContents)

      return stringify(jsonRepresentation, { space: '  ' })
    }
    default:
      throw new Error(`Unknown Serialization conversion`)
  }
}

module.exports = {
  SERIALIZATION_FORMAT,
  convertTypes,
  convertLogic,
  detectFormat,
}
