const path = require('path')
const generateSketchLibrary = require('@lona/workspace-to-sketch-library')
const loadConfig = require('./load-config')

module.exports = ({ buildDir, watching }) => {
  if (watching) {
    // let's not build the artefact when watching
    return Promise.resolve()
  }

  const config = loadConfig()

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
