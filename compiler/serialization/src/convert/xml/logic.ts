import uuid from 'uuid/v4'
import { parseXML, buildXML } from './utils'
import * as AST from '../../types/logic-ast'

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

export function print(logicJson: AST.SyntaxNode): string {
  function isPlaceholder(
    item: AST.SyntaxNode,
    index: number,
    list: AST.SyntaxNode[]
  ) {
    if (index === list.length - 1 && item.type === 'placeholder') {
      return false
    }
    return true
  }

  function getChildren(node: AST.SyntaxNode): AST.SyntaxNode[] {
    switch (node.type) {
      case 'functionCallExpression': {
        const { expression, arguments: args } = node.data

        return [expression, ...args.filter(isPlaceholder)]
      }
      default:
        break
    }

    if ('data' in node && singleChildMapping[node.type]) {
      return [node.data[singleChildMapping[node.type]]]
    }
    if ('data' in node && multipleChildMapping[node.type]) {
      const children = implicitPlaceholderMapping[node.type]
        ? node.data[multipleChildMapping[node.type]].filter(isPlaceholder)
        : node.data[multipleChildMapping[node.type]]
      return children
    }

    return []
  }

  function serializeAnnotationNode(node: AST.TypeAnnotation): string {
    switch (node.type) {
      case 'typeIdentifier': {
        const { genericArguments, identifier } = node.data

        if (genericArguments && genericArguments.length > 0) {
          const serializedArguments = genericArguments.map(
            serializeAnnotationNode
          )
          return `${identifier.string}(${serializedArguments.join(',')})`
        }

        return identifier.string
      }
      default:
        throw new Error(`Unhandled type identifier ${node.type}`)
    }
  }

  function processStandardNode(node: AST.SyntaxNode) {
    const nodeName = nodeRenaming[node.type] || upperFirst(node.type)

    const attributes: {
      name?: string
      type?: string
      label?: string
      value?: any
    } = {}

    if ('data' in node && patternNodeMapping[node.type]) {
      attributes.name = node.data[patternNodeMapping[node.type]].name
    }

    if ('data' in node && identifierNodeMapping[node.type]) {
      attributes.name = node.data[identifierNodeMapping[node.type]].string
    }

    if ('data' in node && annotationNodeMapping[node.type]) {
      attributes.type = serializeAnnotationNode(
        node.data[annotationNodeMapping[node.type]]
      )
    }

    switch (node.type) {
      case 'argument': {
        const { label } = node.data
        attributes.label = label
        break
      }
      case 'variable': {
        const compactLiteralTypes = ['boolean', 'number', 'string', 'color']

        if (node.data.initializer.type === 'literalExpression') {
          const literal = node.data.initializer.data.literal
          if (compactLiteralTypes.includes(literal.type)) {
            return {
              name: nodeName,
              attributes: {
                ...attributes,
                // @ts-ignore
                value: literal.data.value,
              },
              children: [],
            }
          }
          if (literal.type === 'array') {
            return {
              name: nodeName,
              attributes: {
                ...attributes,
              },
              children: literal.data.value
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
        } = node.data

        attributes.name = name
        break
      }
      case 'declaration': {
        const child = processStandardNode(node.data.content)

        return {
          ...child,
          name: ['Declaration', child.name].join('.'),
        }
      }
      case 'color':
      case 'number':
      case 'string':
      case 'boolean': {
        const { value } = node.data
        attributes.value = value
        break
      }
      case 'literalExpression': {
        const literalNode = processStandardNode(node.data.literal)

        return {
          name: 'Literal',
          attributes: {
            type: literalNode.name,
            value: literalNode.attributes.value,
          },
        }
      }
      case 'identifierExpression': {
        const { identifier } = node.data
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

export function parse(root: string): AST.SyntaxNode {
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
  function deserializeAnnotation(
    string: string
  ): AST.TypeIdentifierTypeAnnotation {
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
          type: 'identifier',
          id: createUUID(),
          isPlaceholder: false,
          string: name,
        },
      },
    }
  }

  function processStandardNode(node): AST.SyntaxNode {
    const { name, attributes = {}, children } = node

    switch (name) {
      case 'IdentifierExpression':
        return {
          data: {
            id: createUUID(),
            identifier: {
              type: 'identifier',
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
              type: 'pattern',
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
            }) as AST.ImportDeclarationDeclaration,
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
            }) as AST.NamespaceDeclaration,
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
                type: 'pattern',
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
              }) as AST.VariableDeclaration,
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
            }) as AST.VariableDeclaration,
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
        type: 'pattern',
        id: createUUID(),
        name: attributes.name,
      }
    }

    if (identifierNodeMapping[nodeName]) {
      delete data.name
      data[identifierNodeMapping[nodeName]] = {
        type: 'identifier',
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
