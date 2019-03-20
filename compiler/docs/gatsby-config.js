const path = require('path')
const loadConfig = require('./tasks/load-config')

const config = loadConfig()

const userConfig = config.docs || {}

const plugins = [
  {
    resolve: 'gatsby-plugin-lona',
    options: {
      cwd: config.cwd,
      ignored: config.ignored,
      artifacts: config.artifacts,
    },
  },
  'gatsby-plugin-react-helmet',
  {
    resolve: '@mathieudutour/gatsby-mdx',
    options: {
      extensions: ['.mdx', '.md'],
    },
  },
  'gatsby-plugin-styled-components',
].concat(userConfig.plugins || [])

module.exports = Object.assign(userConfig, {
  siteMetadata: Object.assign(
    {
      title: config.workspaceName || path.basename(config.cwd),
      icon: config.workspaceIcon || null,
    },
    userConfig.siteMetadata || {}
  ),
  plugins,
})
