const webpack = require('webpack') // eslint-disable-line
const loadConfig = require('./load-config')

module.exports = ({ actions, getConfig }) => {
  const { cwd, nodeModules } = loadConfig()

  const webpackConfig = getConfig()

  let jsRule

  webpackConfig.module.rules = webpackConfig.module.rules.map(r => {
    /* eslint-disable no-param-reassign */
    if (r.test && r.test.toString() === /\.jsx?$/.toString()) {
      // fix for running gatsby inside node_modules
      r.exclude = [
        /(node_modules|bower_components)\/(?!@lona\/docs)/,
        /node_modules\/lona-docs\/node_modules/,
      ]

      // load .component as well
      r.test = /\.(jsx?|component)$/
      r.use.push({
        loader: 'lona-loader',
        options: {
          // styleFramework: 'styledcomponents',
        },
      })
      jsRule = r
    }

    return r
  })

  // use the normal js loader for lona files
  webpackConfig.module.rules.push({
    type: 'javascript/auto',
    test: /(colors|textStyles|shadows)\.json$/,
    use: jsRule.use,
  })

  webpackConfig.plugins.push(
    new webpack.ContextReplacementPlugin(/.*lona-workspace/, context => {
      Object.assign(context, {
        regExp: /^\.\/.*\.(component|json)$/,
        request: cwd,
      })
    })
  )

  if (!webpackConfig.resolve.modules) {
    webpackConfig.resolve.modules = []
  }

  webpackConfig.resolve.modules = webpackConfig.resolve.modules.concat(
    nodeModules
  )

  actions.replaceWebpackConfig(webpackConfig)
}
