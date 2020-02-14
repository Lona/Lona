import uuid from 'uuid/v4'
import { parseXML, buildXML, XMLNode } from './utils'
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
  {} as { [key: string]: string }
)

const singleChildMapping: { [key: string]: string } = {
  declaration: 'content',
  variable: 'initializer',
  literalExpression: 'literal',
  argument: 'expression',
  memberExpression: 'expression',
}

const multipleChildMapping: { [key: string]: string } = {
  program: 'block',
  namespace: 'declarations',
  topLevelDeclarations: 'declarations',
  record: 'declarations',
  functionCallExpression: 'arguments',
}

const implicitPlaceholderMapping: { [key: string]: string } = {
  program: 'block',
  namespace: 'declarations',
  topLevelDeclarations: 'declarations',
  record: 'declarations',
  functionCallExpression: 'arguments',
}

const nodeRenaming: { [key: string]: string } = {
  topLevelDeclarations: 'Declarations',
}

const reverseNodeRenaming: { [key: string]: string } = {
  Declarations: 'topLevelDeclarations',
}

const patternNodeMapping: { [key: string]: string } = {
  importDeclaration: 'name',
  variable: 'name',
  namespace: 'name',
}

const identifierNodeMapping: { [key: string]: string } = {
  memberExpression: 'memberName',
}

const annotationNodeMapping: { [key: string]: string } = {
  variable: 'annotation',
}

const upperFirst = (string: string) =>
  string.slice(0, 1).toUpperCase() + string.slice(1)
const lowerFirst = (string: string) =>
  string.slice(0, 1).toLowerCase() + string.slice(1)

export function print(logicJson: AST.SyntaxNode): string {
  function isNotPlaceholder(
    item: AST.SyntaxNode,
    index: number,
    list: AST.SyntaxNode[]
  ) {
    if (
      index === list.length - 1 &&
      'type' in item &&
      item.type === 'placeholder'
    ) {
      return false
    }
    return true
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

  function processStandardNode(node: AST.SyntaxNode): XMLNode {
    const nodeName = nodeRenaming[node.type] || upperFirst(node.type)

    const attributes: {
      name?: string
      type?: string
      label?: string
      value?: any
    } = {}

    if ('data' in node && patternNodeMapping[node.type]) {
      // @ts-ignore
      attributes.name = node.data[patternNodeMapping[node.type]].name
    }

    if ('data' in node && identifierNodeMapping[node.type]) {
      // @ts-ignore
      attributes.name = node.data[identifierNodeMapping[node.type]].string
    }

    if ('data' in node && annotationNodeMapping[node.type]) {
      attributes.type = serializeAnnotationNode(
        // @ts-ignore
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

        if (
          node.data.initializer &&
          node.data.initializer.type === 'literalExpression'
        ) {
          const literal = node.data.initializer.data.literal
          if (
            compactLiteralTypes.includes(literal.type) &&
            'value' in literal.data
          ) {
            return {
              name: nodeName,
              attributes: {
                ...attributes,
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
                .filter(isNotPlaceholder)
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

    const children = AST.subNodes(node).map(processStandardNode)

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
    } as { type: 'placeholder'; data: { id: string } }
  }

  const compactLiteralTypes = ['Boolean', 'Number', 'String', 'Color']

  function decodeLiteralValue(type: string, value: any) {
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

    let genericArguments = [] as AST.TypeAnnotation[]

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

  function processStandardNode(node: XMLNode): AST.SyntaxNode {
    const { name, attributes = {}, children = [] } = node

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
              ...children.map(processStandardNode).filter(AST.isDeclaration),
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
            }) as AST.ImportDeclaration,
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
                        ...children
                          .map(processStandardNode)
                          .filter(AST.isExpression),
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
    const data: { [key: string]: any } = {
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
      // @ts-ignore
      type: nodeName,
      // @ts-ignore
      data,
    }
  }

  return processStandardNode(parseXML(root))
}
