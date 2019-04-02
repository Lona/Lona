const xmlbuilder = require('xmlbuilder')

function processChildren(builder, children) {
  return children.reduce(process, builder).up()
}

function process(builder, item) {
  const { name, attributes = {}, children = [] } = item;

  return processChildren(builder.ele(name, attributes), children)
}

function build(children) {
  const builder = xmlbuilder.create('root');

  const result = children.reduce(process, builder);

  return result.end({ pretty: true })
}

module.exports = {
  build,
}