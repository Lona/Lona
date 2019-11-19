const path = require('path')

module.exports = ({ cache, artifacts, cwd, reporter }) => {
  let p = Promise.resolve([])

  if (artifacts) {
    if (!Array.isArray(artifacts)) {
      throw new Error('artifacts needs to be an array')
    }
    artifacts.forEach(artifact => {
      if (artifact === 'sketch') {
        // generate sketch library
        p = p.then(previousArtifacts => {
          try {
            const now = Date.now()
            const generateSketchLibrary = require('@lona/workspace-to-sketch-library')
              .default
            return generateSketchLibrary(
              cwd,
              path.join(cache.directory, 'library.sketch'),
              { logFunction: reporter.info.bind(reporter) }
            )
              .then(() => {
                reporter.success(
                  `Generated the Sketch Library — ${(
                    (Date.now() - now) /
                    1000
                  ).toFixed(3)} s`
                )
                return previousArtifacts.concat(artifact)
              })
              .catch(err => {
                reporter.error('Could not build the Sketch Library', err)
                return previousArtifacts
              })
          } catch (err) {
            reporter.error('Could not build the Sketch Library', err)
            return previousArtifacts
          }
        })
      }
    })
  }

  return p
}
