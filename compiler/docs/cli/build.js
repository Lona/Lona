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
      stdio: ['pipe', 'inherit', 'inherit'],
    }

    if (argv.workspace) {
      if (!path.isAbsolute(argv.workspace)) {
        argv.workspace = path.join(process.cwd(), argv.workspace)
      }
      process.env.WORKSPACE = argv.workspace
    }

    const config = loadConfig()

    if (argv.buildDir) {
      if (!path.isAbsolute(argv.buildDir)) {
        argv.buildDir = path.join(process.cwd(), argv.buildDir)
      }
    } else {
      argv.buildDir = path.join(config.cwd, config.docsFolder || './docs')
    }

    let childProcesses = []

    const buildSteps = require('../tasks/build')
    const gatsbyPath = require.resolve('gatsby/dist/bin/gatsby.js')

    const gatsbyOptions = [`--build-dir=${argv.buildDir}`]
    if (argv.cacheDir) {
      if (!path.isAbsolute(argv.cacheDir)) {
        argv.cacheDir = path.join(process.cwd(), argv.cacheDir)
      }
      gatsbyOptions.push(`--cache-dir=${argv.cacheDir}`)
    }

    buildSteps({})
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

    function abort() {
      childProcesses.forEach(p => {
        if (p && !p.killed && p.kill) {
          p.kill()
        }
      })

      process.exit()
    }

    process.on('SIGINT', abort)
  },
}
