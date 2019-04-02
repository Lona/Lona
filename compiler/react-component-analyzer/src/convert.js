function memberExpressionPaths(path) {
  const list = []
  let current = path
  while (current.node && current.node.type === 'MemberExpression') {
    list.unshift(current.get('property'))
    current = current.get('object')
  }
  list.unshift(current)
  return list
}

function jsFromExpression(path) {
  // console.log(path.node.type);
  switch (path.node.type) {
    case 'Identifier':
      return path.node.name
    case 'StringLiteral':
    case 'NumericLiteral':
      return path.node.value
    case 'MemberExpression':
      return memberExpressionPaths(path).map(jsFromExpression)
    case 'JSXExpressionContainer':
      return jsFromExpression(path.get('expression'))
    default:
      return null
  }
}

function jsFromObjectExpression(path, transform = x => x) {
  return path.get('properties').reduce((properties, property) => {
    const key = property.get('key').node.name
    properties[key] = transform(property, key)
    return properties
  }, {})
}

function jsFromJsxElement(path) {
  const opening = path.get('openingElement')
  const tag = opening.get('name').node.name
  const attributes = opening.get('attributes').reduce((prev, attr) => {
    const key = attr.get('name').node.name
    prev[key] = jsFromExpression(attr.get('value'))
    return prev
  }, {})
  const children = path
    .get('children')
    .filter(child => child.node.type === 'JSXElement')
    .map(jsFromJsxElement)
  return { tag, attributes, children }
}

module.exports = {
  memberExpressionPaths,
  jsFromExpression,
  jsFromObjectExpression,
  jsFromJsxElement,
}
