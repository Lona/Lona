const React = require('react')
const generateId = require('sketch-file/generateId')

const displayName = require('./display-name')

module.exports = function createSymbol(
  Component,
  props,
  name,
  symbolStyle = {}
) {
  const componentName = displayName(Component)
  const masterName = name ? `${componentName}/${name}` : componentName
  const symbolID = generateId(masterName)

  const symbolMaster = React.createElement(
    'symbolmaster',
    {
      symbolID,
      name: masterName,
      style: symbolStyle,
    },
    React.createElement(Component, props)
  )

  return symbolMaster
}
