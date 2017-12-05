const _ = require('lodash');
const fs = require('fs');
const path = require('path-extra');
const { getAllComponentLayers } = require('./layer');

function normalizeURL(url) {
  const normalized = url.replace('file://', '');

  return normalized;
}

function getComponentName(url) {
  return path.basename(url, path.extname(url));
}

// function readComponentsRecursive(component, results = []) {
//   getAllComponentLayers(component.rootLayer)
//     .map(layer => readComponent(layer.url))
//     .forEach((nested) => {
//       if (results.find(result => result.name === nested.name)) return;
//       results.push(nested);
//       readComponentsRecursive(nested, results);
//     });

//   return results;
// }

function readComponent(inFile) {
  const url = normalizeURL(inFile);

  const component = JSON.parse(fs.readFileSync(url, 'utf8'));

  const componentReferences = getAllComponentLayers(
    component.rootLayer,
  ).map(layer => ({
    path: path.removeExt(layer.url),
    name: getComponentName(layer.url),
  }));

  component.name = getComponentName(url);
  component.references = {
    components: _.uniqBy(componentReferences, 'path'),
  };

  return component;
}

module.exports = {
  readComponent,
  getComponentName,
};
