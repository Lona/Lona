const path = require('path')
const generateSketchLibrary = require('@lona/workspace-to-sketch-library')

module.exports = ({ cache, artefacts, cwd }) => {
  let p = Promise.resolve()

  if (artefacts) {
    if (!Array.isArray(artefacts)) {
      throw new Error('artefacts needs to be an array')
    }
    artefacts.forEach(artefact => {
      if (artefact === 'sketch') {
        // generate sketch library
        p = p.then(() =>
          generateSketchLibrary(
            cwd,
            path.join(cache.directory, 'library.sketch')
          )
        )
      }
    })
  }

  return p
}
