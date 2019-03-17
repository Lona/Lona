const execa = require('execa')
const path = require('path')
const loadConfig = require('../tasks/load-config')

module.exports = {
  command: 'build',

  desc: 'Build the Lona workspace docs.',

  builder: {
    watch: {
      description: 'Watch your workspace and rebuild the docs when they change',
      type: 'boolean',
      default: 'false',
      alias: 'w',
    },
    'prefix-paths': {
      type: `boolean`,
      default: false,
      describe: `Build site with link paths prefixed (set docs.pathPrefix in your lona.json).`,
    },
    workspace: {
      description: 'The path to the Lona workspace',
      type: 'string',
      alias: 'c',
    },
    'build-dir': {
      description:
        'The path to the output directory. Default to the `docs` folder in the workspace',
      type: 'string',
      alias: 'o',
    },
    'cache-dir': {
      description: 'The path to the cache directory.',
      type: 'string',
    },
  },

  handler(argv) {
    const shellOptions = {
      cwd: path.dirname(__dirname),
      stdio: argv.stdio || ['pipe', 'inherit', 'inherit'],
    }

    if (argv.env) {
      if (!argv.env.NODE_PATH) {
        argv.env.NODE_PATH = ''
      }
      shellOptions.env = argv.env
    } else {
      shellOptions.env = {
        NODE_PATH: '',
      }
    }

    if (argv.workspace) {
      if (!path.isAbsolute(argv.workspace)) {
        argv.workspace = path.join(process.cwd(), argv.workspace)
      }
      process.env.WORKSPACE = argv.workspace
    }

    const config = loadConfig()

    shellOptions.env.NODE_PATH += `:${config.nodeModules.join(':')}`

    if (argv.buildDir) {
      if (!path.isAbsolute(argv.buildDir)) {
        argv.buildDir = path.join(process.cwd(), argv.buildDir)
      }
    } else {
      argv.buildDir = path.join(config.cwd, config.docsFolder || './docs')
    }

    let childProcesses = []

    function abort() {
      childProcesses.forEach(p => {
        if (p && !p.killed && p.kill) {
          p.kill()
        }
      })

      process.exit()
    }

    process.on('SIGINT', abort)

    const buildSteps = require('../tasks/build')
    const gatsbyPath = require.resolve(
      '@mathieudutour/gatsby/dist/bin/gatsby.js'
    )

    const gatsbyOptions = [`--build-dir=${argv.buildDir}`]
    if (argv.cacheDir) {
      if (!path.isAbsolute(argv.cacheDir)) {
        argv.cacheDir = path.join(process.cwd(), argv.cacheDir)
      }
      gatsbyOptions.push(`--cache-dir=${argv.cacheDir}`)
    }
    if (argv.noColor) {
      gatsbyOptions.push('--no-color')
    }
    if (argv.verbose) {
      gatsbyOptions.push('--verbose')
    }
    if (argv.prefixPaths) {
      gatsbyOptions.push('--prefix-paths')
    }

    return buildSteps({})
      .then(() => {
        if (argv.watch || process.env.WATCH) {
          childProcesses = [
            execa(gatsbyPath, ['develop', ...gatsbyOptions], shellOptions),
          ].concat(
            buildSteps({
              watching: true,
            })
          )

          return childProcesses
        }
        return execa(gatsbyPath, ['build', ...gatsbyOptions], shellOptions)
      })
      .catch(() => {})
  },
}
