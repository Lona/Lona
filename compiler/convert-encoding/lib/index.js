const fs = require('fs')
const xml = require('./xml')

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
        case: kind,
        data: { name: typeName, ...rest },
      } = type

      switch (kind) {
        case 'native':
          return {
            name: 'NativeType',
            attributes: { name: typeName },
            children: rest.parameters.map(param => ({
              name: 'NativeType.GenericParam',
              attributes: { name: param.name },
            })),
          }
        case 'type':
          return {
            name: 'Type',
            attributes: { name: typeName },
            children: rest.cases.map(caseObj => {
              const { name: caseName, params } = caseObj

              switch (caseObj.case) {
                case 'normal':
                  return {
                    name: 'Case',
                    attributes: { name: caseName },
                    children: params.map(param => {
                      const {
                        value: { case: caseType, name, substitutions = [] },
                      } = param
                      switch (caseType) {
                        case 'generic':
                          return {
                            name: 'Case.GenericParam',
                            attributes: { name },
                          }
                        case 'type':
                          return {
                            name: 'Case.Param',
                            attributes: { name },
                            children: substitutions.map(s => {
                              return {
                                name: 'Case.Substitution',
                                attributes: {
                                  generic: s.generic,
                                  instance: s.instance,
                                },
                              }
                            }),
                          }
                        default:
                          throw new Error(`Invalid case param type ${caseType}`)
                      }
                    }),
                  }
                case 'record':
                  return {
                    name: 'Record',
                    attributes: { name: caseName },
                    children: params.map(param => {
                      const {
                        key,
                        value: { case: caseType, name, substitutions = [] },
                      } = param
                      switch (caseType) {
                        case 'generic':
                          return {
                            name: 'Record.GenericParam',
                            attributes: { key, name },
                          }
                        case 'type':
                          return {
                            name: 'Record.Param',
                            attributes: { key, name },
                            children: substitutions.map(s => {
                              return {
                                name: 'Record.Substitution',
                                attributes: {
                                  generic: s.generic,
                                  instance: s.instance,
                                },
                              }
                            }),
                          }
                        default:
                          throw new Error(
                            `Invalid record param type ${caseType}`
                          )
                      }
                    }),
                  }
                default:
                  throw new Error(`Invalid type ${caseObj.case}`)
              }
            }),
          }
        default:
          throw new Error(`Invalid type ${kind}`)
      }
    })
    .filter(x => !!x)

  return xml.build(types)
}

module.exports = {
  convertTypesFile,
}
