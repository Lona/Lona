const path = require('path')
const webpack = require('webpack') // eslint-disable-line
const loadConfig = require('./load-config')

const { cwd } = loadConfig()

module.exports = ({ actions, getConfig }) => {
  const webpackConfig = getConfig()

  webpackConfig.module.rules = webpackConfig.module.rules.map(r => {
    /* eslint-disable no-param-reassign */
    if (r.test && r.test.toString() === /\.jsx?$/.toString()) {
      // fix for running gatsby inside node_modules
      r.exclude = [
        /(node_modules|bower_components)\/(?!lona-docs)/,
        /node_modules\/lona-docs\/node_modules/,
      ]

      // load .component as well
      r.test = /\.(jsx?|component)$/
      r.use.push({
        loader: 'lona-loader',
      })
    }

    return r
  })

  webpackConfig.plugins.push(
    new webpack.ContextReplacementPlugin(/.*lona-workspace/, context => {
      Object.assign(context, {
        regExp: /^\.\/.*\.component$/,
        request: cwd,
      })
    })
  )

  if (!webpackConfig.resolve.modules) {
    webpackConfig.resolve.modules = []
  }
  // look for the node_modules next the config (useful when using lona-docs as a global)
  webpackConfig.resolve.modules.push(path.join(cwd, 'node_modules'))
  // look for our node_modules
  webpackConfig.resolve.modules.push(
    path.join(path.dirname(__dirname), 'node_modules')
  )

  // see https://github.com/webpack/webpack/issues/5600
  if (!webpackConfig.optimization) {
    webpackConfig.optimization = {}
  }
  webpackConfig.optimization.concatenateModules = true

  actions.replaceWebpackConfig(webpackConfig)
}
