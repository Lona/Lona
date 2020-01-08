import uuid from 'uuid/v4'
import { parseXML, buildXML } from './utils'

function createUUID() {
  return uuid().toUpperCase()
}

enum literalToTypeMapping {
  boolean = 'Boolean',
  number = 'Number',
  string = 'String',
  color = 'Color',
}
const typeToLiteralMapping = Object.entries(literalToTypeMapping).reduce(
  (result, [key, value]) => {
    result[value] = key
    return result
  },
  {}
)

enum singleChildMapping {
  declaration = 'content',
  variable = 'initializer',
  literalExpression = 'literal',
  argument = 'expression',
  memberExpression = 'expression',
}

enum multipleChildMapping {
  program = 'block',
  namespace = 'declarations',
  topLevelDeclarations = 'declarations',
  record = 'declarations',
  functionCallExpression = 'arguments',
}

enum implicitPlaceholderMapping {
  program = 'block',
  namespace = 'declarations',
  topLevelDeclarations = 'declarations',
  record = 'declarations',
  functionCallExpression = 'arguments',
}

enum nodeRenaming {
  topLevelDeclarations = 'Declarations',
}

enum reverseNodeRenaming {
  Declarations = 'topLevelDeclarations',
}

enum patternNodeMapping {
  importDeclaration = 'name',
  variable = 'name',
  namespace = 'name',
}

enum identifierNodeMapping {
  memberExpression = 'memberName',
}

enum annotationNodeMapping {
  variable = 'annotation',
}

const upperFirst = (string: string) =>
  string.slice(0, 1).toUpperCase() + string.slice(1)
const lowerFirst = (string: string) =>
  string.slice(0, 1).toLowerCase() + string.slice(1)

export function print(logicJson) {
  function isPlaceholder(item, index, list) {
    if (index === list.length - 1 && item.type === 'placeholder') {
      return false
    }
    return true
  }

  function getChildren(node) {
    // console.log(node)
    const { type, data } = node

    switch (type) {
      case 'functionCallExpression': {
        const { expression, arguments: args } = data

        return [expression, ...args.filter(isPlaceholder)]
      }
      default:
        break
    }

    if (singleChildMapping[type]) {
      return [data[singleChildMapping[type]]]
    }
    if (multipleChildMapping[type]) {
      const children = implicitPlaceholderMapping[type]
        ? data[multipleChildMapping[type]].filter(isPlaceholder)
        : data[multipleChildMapping[type]]
      return children
    }

    return []
  }

  function serializeAnnotationNode(node) {
    const { type, data } = node

    switch (type) {
      case 'typeIdentifier': {
        const { genericArguments, identifier } = data

        if (genericArguments && genericArguments.length > 0) {
          const serializedArguments = genericArguments.map(
            serializeAnnotationNode
          )
          return `${identifier.string}(${serializedArguments.join(',')})`
        }

        return identifier.string
      }
      default:
        throw new Error(`Unhandled type identifier ${type}`)
    }
  }

  function processStandardNode(node) {
    const { type, data } = node

    const nodeName = nodeRenaming[type] || upperFirst(type)

    const attributes: {
      name?: string
      type?: string
      label?: string
      value?: any
    } = {}

    if (patternNodeMapping[type]) {
      attributes.name = data[patternNodeMapping[type]].name
    }

    if (identifierNodeMapping[type]) {
      attributes.name = data[identifierNodeMapping[type]].string
    }

    if (annotationNodeMapping[type]) {
      attributes.type = serializeAnnotationNode(
        data[annotationNodeMapping[type]]
      )
    }

    switch (type) {
      case 'argument': {
        const { label } = data
        attributes.label = label
        break
      }
      case 'variable': {
        const compactLiteralTypes = ['boolean', 'number', 'string', 'color']

        if (data.initializer.type === 'literalExpression') {
          const literalType = data.initializer.data.literal.type
          const literalData = data.initializer.data.literal.data
          if (compactLiteralTypes.includes(literalType)) {
            return {
              name: nodeName,
              attributes: {
                ...attributes,
                value: literalData.value,
              },
              children: [],
            }
          }
          if (literalType === 'array') {
            return {
              name: nodeName,
              attributes: {
                ...attributes,
              },
              children: literalData.value
                .filter(isPlaceholder)
                .map(processStandardNode),
            }
          }
        }

        break
      }
      case 'record': {
        const {
          name: { name },
        } = data

        attributes.name = name
        break
      }
      case 'declaration': {
        const child = processStandardNode(data.content)

        return {
          ...child,
          name: ['Declaration', child.name].join('.'),
        }
      }
      case 'color':
      case 'number':
      case 'string':
      case 'boolean': {
        const { value } = data
        attributes.value = value
        break
      }
      case 'literalExpression': {
        const literalNode = processStandardNode(data.literal)

        return {
          name: 'Literal',
          attributes: {
            type: literalNode.name,
            value: literalNode.attributes.value,
          },
        }
      }
      case 'identifierExpression': {
        const { identifier } = data
        attributes.name = identifier.string
        break
      }
      default:
        break
    }

    const children = getChildren(node).map(processStandardNode)

    return {
      name: nodeName,
      attributes,
      children,
    }
  }

  return buildXML(processStandardNode(logicJson))
}

export function parse(root) {
  function makePlaceholder() {
    return {
      data: { id: createUUID() },
      type: 'placeholder',
    }
  }

  const compactLiteralTypes = ['Boolean', 'Number', 'String', 'Color']

  function decodeLiteralValue(type, value) {
    switch (type) {
      case 'Boolean':
        return value === 'true'
      case 'Number':
        return value
      case 'String':
        return value
      case 'Color':
        return value
      default:
        throw new Error('Invalid literal value type')
    }
  }

  // TODO: Handle nested generics
  function deserializeAnnotation(string: string) {
    const startParens = string.indexOf('(')
    const endParens = string.lastIndexOf(')')

    let genericArguments = []

    const name = startParens >= 0 ? string.slice(0, startParens) : string
    if (startParens !== -1 && endParens !== -1) {
      const argumentsString = string.slice(startParens + 1, endParens)
      const args = argumentsString.split(',').map(s => s.trim())
      genericArguments = args.map(deserializeAnnotation)
    }

    return {
      type: 'typeIdentifier',
      data: {
        id: createUUID(),
        genericArguments,
        identifier: {
          id: createUUID(),
          isPlaceholder: false,
          string: name,
        },
      },
    }
  }

  function processStandardNode(node) {
    const { name, attributes = {}, children } = node

    switch (name) {
      case 'IdentifierExpression':
        return {
          data: {
            id: createUUID(),
            identifier: {
              id: createUUID(),
              isPlaceholder: false,
              string: attributes.name,
            },
          },
          type: 'identifierExpression',
        }
      case 'Record':
        return {
          data: {
            declarations: [
              ...children.map(processStandardNode),
              {
                data: { id: createUUID() },
                type: 'placeholder',
              },
            ],
            genericParameters: [],
            id: createUUID(),
            name: {
              id: createUUID(),
              name: attributes.name,
            },
          },
          type: 'record',
        }
      case 'Declaration.ImportDeclaration':
        return {
          type: 'declaration',
          data: {
            id: createUUID(),
            content: processStandardNode({
              ...node,
              name: 'ImportDeclaration',
            }),
          },
        }
      case 'Declaration.Namespace':
        return {
          type: 'declaration',
          data: {
            id: createUUID(),
            content: processStandardNode({
              ...node,
              name: 'Namespace',
            }),
          },
        }
      case 'Literal':
        return processStandardNode({
          name: 'LiteralExpression',
          attributes: {},
          children: [
            {
              name: attributes.type,
              attributes: {
                value: attributes.value,
              },
              children: [],
            },
          ],
        })
      case 'Variable': {
        if (compactLiteralTypes.includes(attributes.type) && attributes.value) {
          return processStandardNode({
            name: 'Variable',
            attributes: {
              name: attributes.name,
              type: attributes.type,
            },
            children: [
              {
                name: 'LiteralExpression',
                attributes: {},
                children: [
                  {
                    name: typeToLiteralMapping[attributes.type],
                    attributes: {
                      value: decodeLiteralValue(
                        attributes.type,
                        attributes.value
                      ),
                    },
                    children: [],
                  },
                ],
              },
            ],
          })
        }

        const deserializedType = deserializeAnnotation(attributes.type)

        if (deserializedType.data.identifier.string === 'Array') {
          return {
            type: 'variable',
            data: {
              id: createUUID(),
              name: {
                id: createUUID(),
                name: attributes.name,
              },
              annotation: deserializedType,
              initializer: {
                type: 'literalExpression',
                data: {
                  id: createUUID(),
                  literal: {
                    type: 'array',
                    data: {
                      id: createUUID(),
                      value: [
                        ...children.map(processStandardNode),
                        makePlaceholder(),
                      ],
                    },
                  },
                },
              },
            },
          }
        }

        break
      }
      case 'Declaration.Variable': {
        if (compactLiteralTypes.includes(attributes.type) && attributes.value) {
          return {
            type: 'declaration',
            data: {
              id: createUUID(),
              content: processStandardNode({
                name: 'Variable',
                attributes: {
                  name: attributes.name,
                  type: attributes.type,
                },
                children: [
                  {
                    name: 'LiteralExpression',
                    attributes: {},
                    children: [
                      {
                        name: typeToLiteralMapping[attributes.type],
                        attributes: {
                          value: decodeLiteralValue(
                            attributes.type,
                            attributes.value
                          ),
                        },
                        children: [],
                      },
                    ],
                  },
                ],
              }),
            },
          }
        }

        return {
          type: 'declaration',
          data: {
            id: createUUID(),
            content: processStandardNode({
              ...node,
              name: 'Variable',
            }),
          },
        }
      }
      default:
        break
    }

    const nodeName = reverseNodeRenaming[name] || lowerFirst(name)

    // We implicitly transfer any single-value nodes to the data object
    const data = {
      id: createUUID(),
      ...attributes,
    }

    if (nodeName === 'functionCallExpression') {
      const [expression, ...args] = children
      data.expression = processStandardNode(expression)
      const processedArguments = args.map(processStandardNode)
      data.arguments =
        processedArguments.length === 0
          ? processedArguments
          : [...processedArguments, makePlaceholder()]
    } else if (singleChildMapping[nodeName]) {
      data[singleChildMapping[nodeName]] = processStandardNode(children[0])
    } else if (multipleChildMapping[nodeName]) {
      data[multipleChildMapping[nodeName]] = children.map(processStandardNode)

      if (implicitPlaceholderMapping[nodeName]) {
        data[multipleChildMapping[nodeName]].push(makePlaceholder())
      }
    }

    if (patternNodeMapping[nodeName]) {
      data[patternNodeMapping[nodeName]] = {
        id: createUUID(),
        name: attributes.name,
      }
    }

    if (identifierNodeMapping[nodeName]) {
      delete data.name
      data[identifierNodeMapping[nodeName]] = {
        id: createUUID(),
        isPlaceholder: false,
        string: attributes.name,
      }
    }

    if (annotationNodeMapping[nodeName]) {
      data[annotationNodeMapping[nodeName]] = deserializeAnnotation(
        attributes.type
      )
      delete data.type
    }

    switch (nodeName) {
      case 'number': {
        data.value = parseFloat(data.value)
        break
      }
      default:
        break
    }

    return {
      type: nodeName,
      data,
    }
  }

  return processStandardNode(parseXML(root))
}
