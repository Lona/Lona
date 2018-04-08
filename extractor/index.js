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

const styleSheet = getStyleSheet(ast.program);
const styles = extractStyles(styleSheet);
const elements = extractElements(ast.program);

const metadata = { styles, elements };

console.log(JSON.stringify(metadata, null, 2));
