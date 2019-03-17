const path = require('path')
const { execSync } = require('child_process')

module.exports = () => {
  const configFilePath = path.join(
    process.env.WORKSPACE ? process.env.WORKSPACE : process.cwd(),
    'lona.json'
  )

  const compilerPath = require.resolve('lonac/build/index.js')

  const config = JSON.parse(
    execSync(`${compilerPath} config ${configFilePath}}`, { encoding: 'utf8' })
  )

  try {
    Object.assign(config, require(configFilePath))
  } catch (err) {
    // ignore
  }

  config.cwd = path.dirname(configFilePath)

  config.nodeModules = []
  // look for the node_modules in the workspace
  config.nodeModules.push(path.join(config.cwd, 'node_modules'))
  // look for our node_modules
  config.nodeModules.push(path.join(path.dirname(__dirname), 'node_modules'))
  // @lona/docs has probably been installed so we need to look for sibling dependencies
  // as our own dependencies might be siblings now
  if (__dirname.indexOf('/node_modules/') !== -1) {
    config.nodeModules.push(
      path.join(__dirname.split('/node_modules/')[0], 'node_modules')
    )
  }

  return config
}
