import xmlbuilder from 'xmlbuilder'
import { parseString } from 'xml2js'

export type XMLNode = {
  name: string
  attributes: { [key: string]: any }
  children?: XMLNode[]
}

export function buildXML(root: XMLNode): string {
  function processChildren(
    builder: xmlbuilder.XMLElementOrXMLNode,
    children: XMLNode[]
  ): xmlbuilder.XMLElementOrXMLNode {
    return children.reduce(process, builder).up()
  }

  function process(
    builder: xmlbuilder.XMLElementOrXMLNode,
    item: XMLNode
  ): xmlbuilder.XMLElementOrXMLNode {
    const { name, attributes = {}, children = [] } = item

    return processChildren(builder.ele(name, attributes), children)
  }

  function createRoot(item: XMLNode) {
    const { name, attributes = {}, children = [] } = item

    const builder = xmlbuilder.create(name)

    const withAttributes = Object.entries(attributes).reduce(
      (result, [key, value]) => {
        return result.att(key, value)
      },
      builder
    )

    return children.reduce(process, withAttributes)
  }

  const result = createRoot(root)
  const xmlString = result.end({ pretty: true })

  return xmlString
}

export function parseXML(xmlString: string) {
  let parsed: any
  let error: Error | undefined

  parseString(
    xmlString,
    { explicitChildren: true, preserveChildrenOrder: true },
    (err, result) => {
      error = err
      parsed = result
    }
  )

  if (error) {
    throw error
  }

  if (!parsed) {
    throw new Error('Cannot parse the xml')
  }

  function unwrap(xmlNodeDescription: any): XMLNode {
    const {
      '#name': name,
      $: attributes = {},
      $$: children = [],
    } = xmlNodeDescription

    return {
      name,
      attributes,
      children: children.map(unwrap),
    }
  }

  const root = Object.values(parsed)[0]

  return unwrap(root)
}
