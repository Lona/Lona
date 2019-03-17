const path = require('path')
const generateSketchLibrary = require('@lona/workspace-to-sketch-library')
const loadConfig = require('./load-config')

const config = loadConfig()

module.exports = ({ buildDir }) => {
  let p = Promise.resolve()

  if (config.artefacts) {
    if (!Array.isArray(config.artefacts)) {
      throw new Error('artefacts needs to be an array')
    }
    config.artefacts.forEach(artefact => {
      if (artefact === 'sketch') {
        // generate sketch library
        p = p.then(() =>
          generateSketchLibrary(
            config.cwd,
            path.join(buildDir, 'assets', 'library.sketch')
          )
        )
      }
    })
  }

  return p
}
