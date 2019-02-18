const execa = require('execa')
const path = require('path')

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
  },

  handler(argv) {
    const shellOptions = {
      cwd: path.dirname(__dirname),
      stdio: ['pipe', 'inherit', 'inherit'],
    }

    if (argv.workspace) {
      // eslint-disable-next-line no-param-reassign
      argv.workspace = path.join(process.cwd(), argv.workspace)
      process.env.WORKSPACE = argv.workspace
    }

    let childProcesses = []

    const buildSteps = require('../tasks/build')
    const copyPublicFolder = require('../tasks/copy-public-folder')

    buildSteps({})
      .then(() => {
        if (argv.watch || process.env.WATCH) {
          childProcesses = [execa('gatsby', ['develop'], shellOptions)].concat(
            buildSteps({
              watching: true,
            })
          )

          return childProcesses
        }
        return execa('gatsby', ['build'], shellOptions).then(copyPublicFolder)
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
