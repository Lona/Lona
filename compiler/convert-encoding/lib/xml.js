const xmlbuilder = require('xmlbuilder')
const { parseString } = require('xml2js')

function processChildren(builder, children) {
  // eslint-disable-next-line no-use-before-define
  return children.reduce(process, builder).up()
}

function process(builder, item) {
  const { name, attributes = {}, children = [] } = item

  return processChildren(builder.ele(name, attributes), children)
}

function build(children) {
  const builder = xmlbuilder.create('root')

  const result = children.reduce(process, builder)

  return result.end({ pretty: true })
}

function parse(xmlString) {
  let parsed
  let error

  parseString(
    xmlString,
    { explicitChildren: true, preserveChildrenOrder: true },
    (err, result) => {
      error = err
      parsed = result
    }
  )

  if (error) {
    throw new Error(error)
  }

  function unwrap(xmlNodeDescription) {
    const { '#name': name, $: attributes, $$: children } = xmlNodeDescription

    return {
      name,
      attributes,
      children: children ? children.map(unwrap) : [],
    }
  }

  return unwrap(parsed.root)
}

module.exports = {
  build,
  parse,
}
