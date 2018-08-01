const pluginDefaults = {
  transformType: (context, filename, typename) => typename
};

module.exports = function buildConfigObject(configPath) {
  let compilerConfig = {};

  try {
    compilerConfig = require(configPath) || {};
  } catch (e) {}

  const { plugins = [] } = compilerConfig;

  return {
    plugins: plugins.map(plugin => Object.assign({}, pluginDefaults, plugin))
  };
};
