const babelTypes = require("babel-types");
const { find, findNested } = require("./find");

function getMethod(path, name) {
  return find(path, "ClassMethod", c => {
    const key = c.get("key").node;
    return key && key.name === name;
  })[0];
}

function getComponentClass(path) {
  return find(path, "ClassDeclaration", c => {
    const superClass = c.get("superClass").node;
    return superClass && superClass.name === "Component";
  })[0];
}

function getComponentRenderFunction(path) {
  const componentClass = getComponentClass(path);
  if (!componentClass) return;
  return getMethod(componentClass, "render");
}

function getStyleSheet(path) {
  const predicate = babelTypes.buildMatchMemberExpression("StyleSheet.create");

  return find(path, "CallExpression", c => {
    const callee = c.get("callee").node;
    return callee && predicate(callee);
  })[0];
}

module.exports = {
  getMethod,
  getComponentClass,
  getComponentRenderFunction,
  getStyleSheet
};
