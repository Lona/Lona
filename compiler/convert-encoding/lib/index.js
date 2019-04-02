const fs = require('fs')
const xml = require('./xml')
const { convertTypesJsonToXml } = require('./convert/types')

const ENCODING_FORMAT = {
  JSON: 'json',
  XML: 'xml',
}

function detectEncodingFormat(contents) {
  if (contents.startsWith('{')) {
    return ENCODING_FORMAT.JSON
  }
  if (contents.startsWith('<')) {
    return ENCODING_FORMAT.XML
  }

  return null
}

function convertTypesFile(filename, targetEncodingFormat) {
  if (!Object.values(ENCODING_FORMAT).includes(targetEncodingFormat)) {
    throw new Error(`Invalid encoding format passed: ${targetEncodingFormat}`)
  }

  const contents = fs.readFileSync(filename, 'utf8')

  const sourceEncodingFormat = detectEncodingFormat(contents)

  if (!sourceEncodingFormat) {
    throw new Error(`Unknown encoding format for ${filename}`)
  }

  let jsonContents

  try {
    jsonContents = JSON.parse(contents)
  } catch (e) {
    throw new Error(`Failed to decode types file as JSON: ${filename}`)
  }

  const types = convertTypesJsonToXml(jsonContents)

  return xml.build(types)
}

module.exports = {
  convertTypesFile,
}
