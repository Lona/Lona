const flexToSketchJSON = require("react-sketchapp/lib/flexToSketchJSON");

function createArtboardNode({ canvas }) {
  const children = canvas.rootLayer ? [createViewNode(canvas.rootLayer)] : [];

  return {
    type: "artboard",
    style: {},
    textStyle: {},
    layout: {
      left: canvas.left || 0,
      top: canvas.top || 0,
      width: canvas.width || 0,
      height: canvas.height || 0
    },
    value: null,
    props: {},
    children
  };
}

function createViewNode(layer) {
  const { layout, style } = layer;

  const children = layer.children.map(createNode);

  return {
    type: "view",
    style,
    textStyle: {},
    layout,
    value: null,
    props: {},
    children
  };
}

function createTextNode(layer) {
  const { layout, textStyle, value, props } = layer;

  const children = layer.children.map(createNode);

  return {
    type: "text",
    style: {},
    textStyle,
    layout,
    value,
    props,
    children
  };
}

function createImageNode(layer) {
  const { layout, props } = layer;

  const children = layer.children.map(createNode);

  return {
    type: "image",
    style: {
      backgroundColor: layer.backgroundColor
    },
    textStyle: {},
    layout,
    value: null,
    props,
    children: children
  };
}

function createNode(layer) {
  switch (layer.type) {
    case "View":
    case "Lona:View":
      return createViewNode(layer);
    case "Text":
    case "Lona:Text":
      return createTextNode(layer);
    case "Image":
    case "Lona:Image":
      return createImageNode(layer);
  }
  if (layer._class) {
    return layer;
  }
  throw new Error("Invalid layer type", layer.type);
}

function convertArtboard(parameters) {
  const artboard = createArtboardNode(parameters);
  return flexToSketchJSON(artboard);
}

function traverse(layer, f) {
  f(layer);

  if (layer.children) {
    layer.children.forEach(child => traverse(child, f));
  }
}

// function getImageReferences(canvas) {
//   const { rootLayer } = canvas;
//   if (!rootLayer || !rootLayer.children || rootLayer.children.length === 0)
//     return [];

//   const images = [];

//   traverse(rootLayer, layer => {
//     if (layer.type !== "Image") return;
//     images.push(layer.props.image);
//   });

//   return images;
// }

module.exports = {
  convertArtboard
  // getImageReferences
};
