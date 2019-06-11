const uuid = require('uuid/v4')

function createUUID() {
  return uuid().toUpperCase()
}

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
  function getChildren(node) {
    // console.log(node)
    const { type, data } = node

    switch (type) {
      case 'functionCallExpression': {
        const { expression, arguments: args } = data
        console.log('ARGS', args)

        const mappedArgs = args.map(arg => arg.expression)

        return [expression, ...mappedArgs]
      }
      default:
        break
    }

    if (singleChildMapping[type]) {
      return [data[singleChildMapping[type]]]
    }
    if (multipleChildMapping[type]) {
      return data[multipleChildMapping[type]]
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

    const nodeName = upperFirst(type)

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

  return logicJson.data.block.map(processStandardNode)
}

function convertLogicXmlToJson(program) {
  const { children: programStatements } = program

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

    const nodeName = lowerFirst(name)

    const data = {
      id: createUUID(),
      ...attributes,
    }

    if (singleChildMapping[nodeName]) {
      data[singleChildMapping[nodeName]] = processStandardNode(children[0])
    } else if (multipleChildMapping[nodeName]) {
      data[multipleChildMapping[nodeName]] = children.map(processStandardNode)
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

  return {
    type: 'program',
    data: {
      id: createUUID(),
      block: programStatements.map(processStandardNode),
    },
  }
}

module.exports = { convertLogicJsonToXml, convertLogicXmlToJson }
