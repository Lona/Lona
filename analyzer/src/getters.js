const babelTypes = require("babel-types");
const { find, findNested } = require("./find");

function getMethod(path, name) {
  return find(path, "ClassMethod", c => {
    const key = c.get("key").node;
    return key && key.name === name;
  })[0];
}

function getComponentClass(path) {
  const predicate = babelTypes.buildMatchMemberExpression("React.Component");

  return find(path, "ClassDeclaration", c => {
    const superClass = c.get("superClass").node;
    return (
      superClass && (superClass.name === "Component" || predicate(superClass))
    );
  })[0];
}

function getComponentRenderFunction(path) {
  const componentClass = getComponentClass(path);
  if (!componentClass) return;
  return getMethod(componentClass, "render");
}

function getPropTypes(path) {
  const componentClass = getComponentClass(path);
  if (!componentClass) return;
  return find(componentClass, "ClassProperty", c => {
    const key = c.get("key").node;
    return key && key.name === "propTypes";
  })[0];
}

function getStyleSheet(path) {
  const predicate = babelTypes.buildMatchMemberExpression("StyleSheet.create");

  return find(path, "CallExpression", c => {
    const callee = c.get("callee").node;
    return callee && predicate(callee);
  })[0];
}

module.exports = {
  getPropTypes,
  getMethod,
  getComponentClass,
  getComponentRenderFunction,
  getStyleSheet
};
