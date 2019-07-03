const uuid = require('uuid/v4')

function createUUID() {
  return uuid().toUpperCase()
}

const literalToTypeMapping = {
  boolean: 'Boolean',
  number: 'Number',
  string: 'String',
  color: 'Color',
}
const typeToLiteralMapping = Object.entries(literalToTypeMapping).reduce(
  (result, [key, value]) => {
    result[value] = key
    return result
  },
  {}
)

const singleChildMapping = {
  declaration: 'content',
  variable: 'initializer',
  literalExpression: 'literal',
  functionCallArgument: 'expression',
  memberExpression: 'expression',
}

const multipleChildMapping = {
  program: 'block',
  namespace: 'declarations',
  topLevelDeclarations: 'declarations',
  record: 'declarations',
}

const implicitPlaceholderMapping = {
  program: 'block',
  namespace: 'declarations',
  topLevelDeclarations: 'declarations',
  record: 'declarations',
}

const nodeRenaming = {
  topLevelDeclarations: 'Declarations',
}

const reverseNodeRenaming = {
  Declarations: 'topLevelDeclarations',
}

const identifierNodeMapping = {
  importDeclaration: 'name',
  variable: 'name',
  namespace: 'name',
}

const annotationNodeMapping = {
  variable: 'annotation',
}

const upperFirst = string => string.slice(0, 1).toUpperCase() + string.slice(1)
const lowerFirst = string => string.slice(0, 1).toLowerCase() + string.slice(1)

function convertLogicJsonToXml(logicJson) {
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

        const mappedArgs = args.map(arg => ({
          type: 'functionCallArgument',
          data: arg,
        }))

        return [expression, ...mappedArgs]
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
          return `${identifier.string}[${genericArguments.join(',')}]`
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

    const attributes = {}

    if (identifierNodeMapping[type]) {
      attributes.name = data[identifierNodeMapping[type]].name
    }

    if (annotationNodeMapping[type]) {
      attributes.type = serializeAnnotationNode(
        data[annotationNodeMapping[type]]
      )
    }

    switch (type) {
      case 'functionCallArgument': {
        const { label } = data
        attributes.label = label
        break
      }
      case 'variable': {
        const compactLiteralTypes = ['boolean', 'number', 'string', 'color']

        if (
          data.initializer.type === 'literalExpression' &&
          compactLiteralTypes.includes(data.initializer.data.literal.type)
        ) {
          return {
            name: nodeName,
            attributes: {
              ...attributes,
              value: data.initializer.data.literal.data.value,
            },
            children: [],
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
      case 'memberExpression': {
        const { memberName } = data
        attributes.name = memberName.string
        break
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

  return processStandardNode(logicJson)
}

function convertLogicXmlToJson(root) {
  const compactLiteralTypes = ['Boolean', 'Number', 'String', 'Color']

  function deserializeAnnotation(string) {
    return {
      type: 'typeIdentifier',
      data: {
        id: createUUID(),
        genericArguments: [],
        identifier: {
          id: createUUID(),
          isPlaceholder: false,
          string,
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
              id: '0',
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
      case 'Variable':
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
                      value: attributes.value,
                    },
                    children: [],
                  },
                ],
              },
            ],
          })
        }

        break
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
                          value: attributes.value,
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

    const data = {
      id: createUUID(),
      ...attributes,
    }

    if (nodeName === 'functionCallExpression') {
      const [expression, ...args] = children
      data.expression = processStandardNode(expression)
      data.arguments = args.map(processStandardNode).map(arg => arg.data)
    } else if (singleChildMapping[nodeName]) {
      data[singleChildMapping[nodeName]] = processStandardNode(children[0])
    } else if (multipleChildMapping[nodeName]) {
      data[multipleChildMapping[nodeName]] = children.map(processStandardNode)

      if (implicitPlaceholderMapping[nodeName]) {
        data[multipleChildMapping[nodeName]].push({
          data: { id: createUUID() },
          type: 'placeholder',
        })
      }
    }

    if (identifierNodeMapping[nodeName]) {
      data[identifierNodeMapping[nodeName]] = {
        id: createUUID(),
        name: attributes.name,
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

  return processStandardNode(root)
}

module.exports = { convertLogicJsonToXml, convertLogicXmlToJson }
