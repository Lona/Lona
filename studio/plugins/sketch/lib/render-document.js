const fs = require("fs");
const path = require("path");

const parseColor = require("color-parse");
const generateId = require("sketch-file/generateId");
const { TextStyles, renderToJSON } = require("react-sketchapp");
const createComponentLayerCollection = require("./component-layer-collection");

function loadComponent(config, componentPath) {
  const relativeComponentPath = path
    .relative(config.paths.workspace, componentPath)
    .replace(/\.component$/gi, "");
  try {
    return {
      name: relativeComponentPath,
      compiled: require(path.join(config.paths.output, relativeComponentPath))
        .default,
      meta: JSON.parse(fs.readFileSync(componentPath))
    };
  } catch (err) {
    console.error("skipping " + componentPath);
    console.error(err);
  }
}

function arrangeComponentLayerCollections(collections) {
  return collections.reduce(
    (acc, collection) => {
      const { layers, offset } = acc;
      const { artboard, symbols } = collection;

      const arranged = [artboard, ...symbols].map(layer => {
        layer.frame.y += offset;
        return layer;
      });

      return {
        layers: layers.concat(arranged),
        offset: offset + artboard.frame.height + 96
      };
    },
    {
      layers: [],
      offset: 0
    }
  ).layers;
}

module.exports = config => {
  const _TextStyles = require(config.paths.textStyles
    .replace(config.paths.workspace, config.paths.output)
    .replace(/\.json$/gi, "")).default;

  const _Colors = require(config.paths.colors);

  const colors = _Colors.colors
    .map(color => {
      const parsed = parseColor(color.value);
      if (!parsed) {
        return;
      }
      return {
        name: color.name,
        red: parsed.values[0] / 255,
        green: parsed.values[1] / 255,
        blue: parsed.values[2] / 255,
        alpha: parsed.alpha
      };
    })
    .filter(x => x);

  TextStyles.create(
    {
      idMap: Object.keys(_TextStyles).reduce((prev, k) => {
        prev[k] = generateId(k);
        return prev;
      }, {})
    },
    Object.keys(_TextStyles).reduce((prev, k) => {
      prev[k] = _TextStyles[k];
      return prev;
    }, {})
  );

  const components = config.paths.components.map(componentPath =>
    loadComponent(config, componentPath)
  );

  const collections = components
    .map(component => {
      try {
        return createComponentLayerCollection(component);
      } catch (err) {
        console.error(`Skipping ${component.name} due to an error`);
        console.error(err);
        return undefined;
      }
    })
    .filter(x => x);

  return {
    layers: arrangeComponentLayerCollections(collections),
    textStyles: TextStyles.toJSON(),
    colors
  };
};
