const path = require('path')
const generateSketchLibrary = require('@lona/workspace-to-sketch-library')

module.exports = ({ cache, artifacts, cwd }) => {
  let p = Promise.resolve()

  if (artifacts) {
    if (!Array.isArray(artifacts)) {
      throw new Error('artifacts needs to be an array')
    }
    artifacts.forEach(artifact => {
      if (artifact === 'sketch') {
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
