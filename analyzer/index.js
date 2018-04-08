const fs = require("fs");
const babel = require("babel-core");
const babylon = require("babylon");
const traverse = require("@babel/traverse").default;

const { find, findNested } = require("./src/find");
const {
  getComponentClass,
  getMethod,
  getComponentRenderFunction,
  getStyleSheet
} = require("./src/getters");
const {
  memberExpressionPaths,
  jsFromExpression,
  jsFromObjectExpression,
  jsFromJsxElement
} = require("./src/convert");

const source = fs.readFileSync("./examples/View1.js", "utf8");

global.ast = babylon.parse(source, {
  sourceType: "module",
  plugins: ["jsx"]
});

function extractStyles(path) {
  const extractAttributes = style =>
    jsFromObjectExpression(style.get("value"), attr =>
      jsFromExpression(attr.get("value"))
    );
  return jsFromObjectExpression(path.get("arguments")[0], extractAttributes);
}

function extractElements(path) {
  const renderFunction = getComponentRenderFunction(ast.program);
  if (!renderFunction) return;
  const rootElement = find(path, "ReturnStatement")[0].get("argument");
  return jsFromJsxElement(rootElement);
}

function toLonaFile({ styles, elements }) {
  function convertSimpleStyleAttribute(key, value) {
    switch (key) {
      // case "width":
      // case "height":
      // case "backgroundColor":
      // case "borderWidth":
      // case "borderColor":
      // case "borderRadius":
      //   return value;
      default:
        // throw new Error(`Unrecognized style attribute -- ${key}: ${value}`);
        return value;
    }
  }

  function literalStyleAttributes(style) {
    const simple = Object.entries(style).reduce((acc, [key, value]) => {
      acc[key] = convertSimpleStyleAttribute(key, value);
      return acc;
    }, {});
    return { ...simple };
  }

  function lookupStyle(keyPath) {
    return styles[keyPath[1]];
  }

  function convertAttribute(key, value) {
    switch (key) {
      case "style":
        return literalStyleAttributes(lookupStyle(value));
      default:
        return { [key]: value };
    }
  }

  function elementToLonaLayer({ tag, attributes, children }) {
    const params = Object.entries(attributes).reduce((acc, [key, value]) => {
      Object.assign(acc, convertAttribute(key, value));
      return acc;
    }, {});

    return {
      id: "Test",
      type: `Lona:${tag}`,
      params,
      children: children.map(elementToLonaLayer)
    };
  }

  return {
    root: elementToLonaLayer(elements),
    logic: [],
    params: [],
    canvases: []
  };
}

const styleSheet = getStyleSheet(ast.program);
const styles = extractStyles(styleSheet);
const elements = extractElements(ast.program);

const metadata = { styles, elements };

console.log(JSON.stringify(toLonaFile(metadata), null, 2));
