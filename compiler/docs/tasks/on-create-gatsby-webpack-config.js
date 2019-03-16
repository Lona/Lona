const path = require('path')
const webpack = require('webpack') // eslint-disable-line
const loadConfig = require('./load-config')

const { cwd } = loadConfig()

module.exports = ({ actions, getConfig }) => {
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
  if (!process.env.NODE_PATH) {
    process.env.NODE_PATH = ''
  }
  // look for the node_modules in the workspace
  const workspaceNodeModules = path.join(cwd, 'node_modules')
  webpackConfig.resolve.modules.push(workspaceNodeModules)
  process.env.NODE_PATH += `:${workspaceNodeModules}`
  // look for our node_modules
  const ourNodeModules = path.join(path.dirname(__dirname), 'node_modules')
  webpackConfig.resolve.modules.push(ourNodeModules)
  process.env.NODE_PATH += `:${ourNodeModules}`
  // @lona/docs has probably been installed so we need to look for sibling dependencies
  // as our own dependencies might be siblings now
  if (__dirname.indexOf('/node_modules/') !== -1) {
    const siblingNodeModules = path.join(
      __dirname.split('/node_modules/')[0],
      'node_modules'
    )
    webpackConfig.resolve.modules.push(siblingNodeModules)
    process.env.NODE_PATH += `:${siblingNodeModules}`
  }
  require('module').Module._initPaths()

  actions.replaceWebpackConfig(webpackConfig)
}
