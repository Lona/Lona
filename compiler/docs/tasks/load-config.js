const path = require('path')

module.exports = () => {
  const configFilePath = path.join(
    process.env.WORKSPACE ? process.env.WORKSPACE : process.cwd(),
    'lona.json'
  )

  let config

  try {
    config = require(configFilePath)
  } catch (err) {
    throw new Error('Cannot find the workspace config (lona.json)')
  }

  config.cwd = path.dirname(configFilePath)
  config.filepath = configFilePath

  return config
}
