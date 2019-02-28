const path = require('path')
const loadConfig = require('./tasks/load-config')

const config = loadConfig()

const defaultIgnoredPatterns = [
  `**/*.un~`,
  `**/.gitignore`,
  `**/.npmignore`,
  `**/.babelrc`,
  `**/yarn.lock`,
  `**/package-lock.json`,
  `**/node_modules`,
  `../**/dist/**`,
]

const userConfig = config.gatsby || {}

const SOURCES = [
  {
    pattern: '**/*.md',
    type: `LonaDocument`,
  },
  {
    pattern: '**/*.mdx',
    type: `LonaDocument`,
  },
  {
    pattern: '**/*.component',
    type: `Component`,
  },
  {
    pattern: 'colors.json',
    type: `Colors`,
  },
  {
    pattern: 'textStyles.json',
    type: `TextStyles`,
  },
  {
    pattern: 'shadows.json',
    type: `Shadows`,
  },
  {
    pattern: 'gradients.json',
    type: `Gradients`,
  },
]

const plugins = SOURCES.map(({ pattern, type }) => ({
  resolve: 'gatsby-plugin-lona',
  options: {
    cwd: config.cwd,
    pattern,
    type,
    ignored: config.ignored || defaultIgnoredPatterns,
  },
}))
  .concat([
    {
      resolve: 'gatsby-plugin-lona',
      options: {
        cwd: path.join(__dirname, 'utils'),
        pattern: 'declare_all_frontmatter.md',
        ignored: config.ignored || defaultIgnoredPatterns,
        type: `LonaDocumentOnlyThereToProvideAllTheFrontMatterFields`,
      },
    },
    'gatsby-plugin-react-helmet',
    {
      resolve: `gatsby-mdx`,
      options: {
        extensions: [`.mdx`, `.md`],
      },
    },
    'gatsby-plugin-styled-components',
  ])
  .concat(userConfig.plugins || [])

module.exports = Object.assign(userConfig, {
  siteMetadata: Object.assign(
    {
      title: config.title || path.basename(config.cwd),
    },
    userConfig.siteMetadata || {}
  ),
  plugins,
})
