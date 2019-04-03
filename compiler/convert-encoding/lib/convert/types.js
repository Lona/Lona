function convertTypesJsonToXml(typesJson) {
  return typesJson.types
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
              attributes: { type: param.name },
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
                            attributes: { type: name },
                          }
                        case 'type':
                          return {
                            name: 'Case.Param',
                            attributes: { type: name },
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
                            attributes: { name: key, type: name },
                          }
                        case 'type':
                          return {
                            name: 'Record.Param',
                            attributes: { name: key, type: name },
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
}

function convertTypesXmlToJson(typesDefinition) {
  const { children: definitions } = typesDefinition

  return {
    types: definitions.map(definition => {
      const { name, attributes, children = [] } = definition

      switch (name) {
        case 'NativeType':
          return {
            case: 'native',
            data: {
              name: attributes.name,
              parameters: children.map(child => {
                return {
                  name: child.attributes.type,
                }
              }),
            },
          }
        case 'Type':
          return {
            case: 'type',
            data: {
              name: attributes.name,
              cases: children.map(typeCase => {
                switch (typeCase.name) {
                  case 'Case':
                    return {
                      case: 'normal',
                      name: typeCase.attributes.name,
                      params: typeCase.children.map(param => {
                        switch (param.name) {
                          case 'Case.GenericParam':
                            return {
                              value: {
                                case: 'generic',
                                name: param.attributes.type,
                              },
                            }
                          case 'Case.Param':
                            return {
                              value: {
                                case: 'type',
                                name: param.attributes.type,
                                substitutions: param.children.map(
                                  substitution => {
                                    const {
                                      attributes: { generic, instance },
                                    } = substitution

                                    return { generic, instance }
                                  }
                                ),
                              },
                            }
                          default:
                            throw new Error(`Bad typeCase param ${param.name}`)
                        }
                      }),
                    }
                  case 'Record':
                    return {
                      case: 'record',
                      name: typeCase.attributes.name,
                      params: typeCase.children.map(param => {
                        switch (param.name) {
                          case 'Record.GenericParam':
                            return {
                              key: param.attributes.name,
                              value: {
                                case: 'generic',
                                name: param.attributes.type,
                              },
                            }
                          case 'Record.Param':
                            return {
                              key: param.attributes.name,
                              value: {
                                case: 'type',
                                name: param.attributes.type,
                                substitutions: param.children.map(
                                  substitution => {
                                    const {
                                      attributes: { generic, instance },
                                    } = substitution

                                    return { generic, instance }
                                  }
                                ),
                              },
                            }
                          default:
                            throw new Error(`Bad typeCase param ${param.name}`)
                        }
                      }),
                    }

                  default:
                    throw new Error(`Unknown type case: ${typeCase.name}`)
                }
              }),
            },
          }
        default:
          throw new Error(`Unknown type kind: ${name}`)
      }
    }),
  }
}

module.exports = { convertTypesJsonToXml, convertTypesXmlToJson }
