import { parseXML, buildXML } from './utils'
import * as AST from '../../types/types-ast'

function assertNever(x: never): never {
  throw new Error('Unknown type: ' + x['case'])
}

export function print(typesJson: AST.Root) {
  const types = typesJson.types.map(type => {
    switch (type.case) {
      case 'native':
        return {
          name: 'NativeType',
          attributes: { name: type.data.name },
          children: type.data.parameters.map(param => ({
            name: 'NativeType.GenericParam',
            attributes: { type: param.name },
          })),
        }
      case 'type':
        return {
          name: 'Type',
          attributes: { name: type.data.name },
          children: type.data.cases.map(caseObj => {
            switch (caseObj.case) {
              case 'normal':
                return {
                  name: 'Case',
                  attributes: { name: caseObj.name },
                  children: caseObj.params.map(param => {
                    switch (param.value.case) {
                      case 'generic':
                        return {
                          name: 'Case.GenericParam',
                          attributes: { type: param.value.name },
                        }
                      case 'type':
                        return {
                          name: 'Case.Param',
                          attributes: { type: param.value.name },
                          children: param.value.substitutions.map(s => {
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
                        assertNever(param.value)
                    }
                  }),
                }
              case 'record':
                return {
                  name: 'Record',
                  attributes: { name: caseObj.name },
                  children: caseObj.params.map(param => {
                    switch (param.value.case) {
                      case 'generic':
                        return {
                          name: 'Record.GenericParam',
                          attributes: { name: param.key, type: name },
                        }
                      case 'type':
                        return {
                          name: 'Record.Param',
                          attributes: { name: param.key, type: name },
                          children: param.value.substitutions.map(s => {
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
                        assertNever(param.value)
                    }
                  }),
                }
              default:
                assertNever(caseObj)
            }
          }),
        }
      default:
        assertNever(type)
    }
  })

  return buildXML({ name: 'root', attributes: {}, children: types })
}

export function parse(typesDefinition: string): AST.Root {
  const { children: definitions = [] } = parseXML(typesDefinition)

  return {
    types: definitions.map(definition => {
      const { name, attributes = {}, children = [] } = definition

      switch (name) {
        case 'NativeType':
          return {
            case: 'native',
            data: {
              name: attributes.name,
              parameters: children.map(child => {
                return {
                  name: (child.attributes || {}).type,
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
                      params: (typeCase.children || []).map(param => {
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
                                substitutions: (param.children || []).map(
                                  substitution => {
                                    const {
                                      generic,
                                      instance,
                                    } = substitution.attributes

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
                      params: (typeCase.children || []).map(param => {
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
                                substitutions: (param.children || []).map(
                                  substitution => {
                                    const {
                                      generic,
                                      instance,
                                    } = substitution.attributes

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
