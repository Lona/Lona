const fs = require('fs')
const xml = require('xml')
const xml2js = require('xml2js')

const ENCODING_FORMAT = {
  JSON: 'json',
  XML: 'xml',
}

function detectEncodingFormat(contents) {
  if (contents.startsWith('{')) {
    return ENCODING_FORMAT.JSON
  } else if (contents.startsWith('<')) {
    return ENCODING_FORMAT.XML
  }

  return null
}

function convertTypesFile(filename, targetEncodingFormat) {
  const contents = fs.readFileSync(filename, 'utf8')

  const sourceEncodingFormat = detectEncodingFormat(contents)

  if (!sourceEncodingFormat) {
    throw new Error(`Unknown encoding format for ${filename}`)
  }

  if (!Object.values(ENCODING_FORMAT).includes(targetEncodingFormat)) {
    throw new Error(`Invalid encoding format passed: ${targetEncodingFormat}`)
  }

  const jsonContents = JSON.parse(contents)

  // const xmlString = xml({ root: jsonContents }, { index: '  ' })
  // return xmlString

  // const obj = { name: 'Super', Surname: 'Man', age: 23 }

  const types = jsonContents.types
    .map(type => {
      const {
        case: caseType,
        data: { name, ...rest },
      } = type

      switch (caseType) {
        case 'native':
          return {
            NativeType: {
              $: { name },
              NativeTypeParam: rest.parameters.map(param => ({
                $: { name: param.name },
              })),
            },
          }
        case 'type':
          return {
            Type: {
              $: { name },
              TypeCase: rest.cases.map(x => {
                const { name, params } = x
                switch (x.case) {
                  case 'normal':
                    return { normal: { params } }
                  case 'record':
                    return { record: { params } }
                }
              }),
            },
          }
        default:
          throw new Error(`Invalid type ${caseType}`)
      }
    })
    .filter(x => !!x)

  const builder = new xml2js.Builder({ explicitArray: true })
  const xml = builder.buildObject({ root: types })

  return xml
}

module.exports = {
  convertTypesFile,
}
