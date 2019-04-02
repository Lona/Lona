const fs = require('fs')
const xml = require('./xml')

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

  const types = jsonContents.types
    .map(type => {
      const {
        case: caseType,
        data: { name, ...rest },
      } = type

      switch (caseType) {
        case 'native':
          return {
            name: 'NativeType',
            attributes: { name },
            children: rest.parameters.map(param => ({
              name: 'NativeType:Param',
              attributes: { name: param.name }
            })),
          }
        case 'type':
          return {
            name: 'Type',
            attributes: { name },
            children: rest.cases.map(x => {
              const { name, params } = x

              switch (x.case) {
                case 'normal':
                console.warn(name, params)
                  return {
                    name: 'Type.Case',
                    attributes: { name },
                    children: params.map(param => {
                      const { value: { case: caseType, name, substitutions = [] } } = param;
                      console.warn(caseType, name)
                      switch (caseType) {
                        case 'generic':
                          return {
                            name: 'Type:GenericParam',
                            attributes: { name }
                          }
                        case 'type':
                          return {
                            name: 'Type:Param',
                            attributes: { name },
                            children: substitutions.map(s => {
                              return {
                                name: "TODO"
                              }
                            })
                          }
                        default:
                          throw new Error(`Invalid type ${caseType}`)
                      }
                    })
                  }
                case 'record':
                  return {
                    name: 'Type.RecordCase',
                    attributes: { name },
                    children: params.map(param => {
                      const { key, value: { case: caseType, name, substitutions = [] } } = param;
                      console.warn(key, caseType, name)
                      switch (caseType) {
                        case 'generic':
                          return {
                            name: 'Type:GenericParam',
                            attributes: { name }
                          }
                        case 'type':
                          return {
                            name: 'Type:Param',
                            attributes: { name },
                            children: substitutions.map(s => {
                              return {
                                name: "TODO"
                              }
                            })
                          }
                        default:
                          throw new Error(`Invalid type ${caseType}`)
                      }
                      }
                    })
                  }
              }
            }),
          }
        default:
          throw new Error(`Invalid type ${caseType}`)
      }
    })
    .filter(x => !!x)





  // const rootElement = builder.create('root')

  return xml.build(types)
}

module.exports = {
  convertTypesFile,
}
