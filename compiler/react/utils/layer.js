function getAllLayers(root) {
  const layers = [];

  const getLayers = (layer) => {
    const { children } = layer;
    if (!children || children.length === 0) return;

    children.forEach((child) => {
      layers.push(child);
      getLayers(child);
    });
  };

  getLayers(root);

  return layers;
}

function getAllComponentLayers(root) {
  return getAllLayers(root).filter(layer => layer.type === 'Component');
}

module.exports = {
  getAllLayers,
  getAllComponentLayers,
};
