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

module.exports = { convertTypesJsonToXml }
