const execa = require('execa')
const loadConfig = require('./load-config')

const config = loadConfig()
const shellOptions = {
  cwd: config.cwd,
  stdio: ['pipe', 'inherit', 'inherit'],
}

module.exports = () => {
  let p = Promise.resolve()

  if (config.artefacts) {
    if (Array.isArray(config.artefacts)) {
      config.artefacts.forEach(artefact => {
        if (artefact === 'sketch') {
          // generate sketch library
          p = p.then(() =>
            execa.shell('echo "generate sketch library', shellOptions)
          )
        }
      })
    } else {
      throw new Error('artefacts needs to be an array')
    }
  }

  return p
}
