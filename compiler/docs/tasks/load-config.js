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

  return config
}
