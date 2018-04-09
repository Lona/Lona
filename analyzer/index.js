const fs = require("fs");
const babel = require("babel-core");
const babylon = require("babylon");
const traverse = require("@babel/traverse").default;

const { find, findNested } = require("./src/find");
const {
  getComponentClass,
  getMethod,
  getComponentRenderFunction,
  getStyleSheet,
  getPropTypes
} = require("./src/getters");
const {
  memberExpressionPaths,
  jsFromExpression,
  jsFromObjectExpression,
  jsFromJsxElement
} = require("./src/convert");

module.exports = function analyze(source) {
  global.ast = babylon.parse(source, {
    sourceType: "module",
    plugins: ["*"]
  });

  function extractPropTypes(path) {
    const propTypes = getPropTypes(path);
    if (!propTypes) return null;
    return jsFromObjectExpression(propTypes.get("value"), c => {
      const value = c.get("value");
      const names = memberExpressionPaths(value)
        .map(id => id.node.name)
        .filter(name => name !== "PropTypes" && name !== "React");
      const isRequired = names.includes("isRequired");
      // TODO: Complex types
      return {
        type: names[0],
        isRequired
      };
    });
  }

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

  function toLonaFile({ styles, elements, propTypes }) {
    const nextId = (() => {
      let id = 0;
      return () => id++;
    })();

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
      return Object.assign({}, simple);
    }

    function lookupStyle(keyPath) {
      return styles[keyPath[1]];
    }

    function convertAttribute(key, value) {
      switch (key) {
        case "style":
          return literalStyleAttributes(lookupStyle(value));
        case "id":
          return {};
        default:
          return { [key]: value };
      }
    }

    const typeNameMap = {
      bool: "Boolean",
      number: "Number",
      string: "String"
    };

    function propTypeToLonaParameter(name, { type, isRequired }) {
      return {
        name,
        type: typeNameMap[type] + (isRequired ? "" : "?")
      };
    }

    function elementToLonaLayer({ tag, attributes, children }) {
      const params = Object.entries(attributes).reduce((acc, [key, value]) => {
        Object.assign(acc, convertAttribute(key, value));
        return acc;
      }, {});

      return {
        id: attributes.id || `${tag}${nextId()}`,
        type: `Lona:${tag}`,
        params,
        children: children.map(elementToLonaLayer)
      };
    }

    return {
      root: elementToLonaLayer(elements),
      params: Object.entries(propTypes).map(([name, propType]) =>
        propTypeToLonaParameter(name, propType)
      ),
      logic: [],
      canvases: []
    };
  }

  const propTypes = extractPropTypes(ast.program);
  const styleSheet = getStyleSheet(ast.program);
  const styles = styleSheet && extractStyles(styleSheet);
  const elements = extractElements(ast.program);

  // console.log(propTypes, styles, elements);

  if (!elements) {
    return null;
  }

  const metadata = {
    elements,
    styles: styles || {},
    propTypes: propTypes || {}
  };

  return toLonaFile(metadata);
  // console.log(JSON.stringify(toLonaFile(metadata), null, 2));
};

// const source = fs.readFileSync("./examples/View1.js", "utf8");
