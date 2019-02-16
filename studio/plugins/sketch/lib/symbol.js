const React = require('react');
const generateId = require('sketch-file/generateId');

const { renderToJSON } = require('react-sketchapp');

let id = 0;
const nextId = () => ++id; // eslint-disable-line

const displayName = Component =>
  Component.displayName || Component.name || `UnknownSymbol${nextId()}`;

module.exports = function createSymbol(Component, props, name) {
  const masterName = name || displayName(Component);
  const symbolID = generateId(masterName);
  const symbolMaster = renderToJSON(
    React.createElement(
      'symbolmaster',
      {
        symbolID,
        name: masterName
      },
      [
        React.createElement(Component, props)
      ]
    )
  );
  return symbolMaster;
}
