const path = require('path')
const fs = require('fs')
const { getOptions } = require('loader-utils')
const { exec } = require('child_process')

const lonac = path.join(__dirname, '../../core/src/main.bs.js')

const IMPORT_REGEX = /import [a-zA-Z]+ from "([a-zA-Z./]+)"/g
function parseImports(source) {
  const imports = []

  let match = IMPORT_REGEX.exec(source)

  while (match) {
    // if it's a relative import
    if (match[1].match(/^\./)) {
      imports.push(match[1])
    }
    match = IMPORT_REGEX.exec(source)
  }

  return imports
}

module.exports = function loader(source) {
  const callback = this.async()
  const options = getOptions(this) || {}

  const rawFilePath = path.normalize(this.resourcePath)
  if (path.extname(rawFilePath) !== '.component') {
    callback(null, source)
    return
  }

  exec(
    `node "${lonac}" component js --framework=${options.framework ||
      'reactdom'}${
      options.styleFramework
        ? ` --styleFramework=${options.styleFramework}`
        : ''
    } "${rawFilePath}"`,
    (err, stdout, stderr) => {
      if (err) {
        callback(stderr || err)
        return
      }
      const imports = parseImports(stdout)

      imports.forEach(relativeFilePath => {
        const absolutePath = path.resolve(
          path.dirname(rawFilePath),
          relativeFilePath
        )
        if (fs.existsSync(absolutePath)) {
          return
        }
        if (fs.existsSync(`${absolutePath}.component`)) {
          stdout = stdout.replace(
            relativeFilePath,
            `${relativeFilePath}.component`
          )

          return
        }
        if (fs.existsSync(`${absolutePath}.json`)) {
          switch (path.basename(absolutePath)) {
            // TODO:
            case 'colors': {
              break
            }
            case 'shadows': {
              break
            }
            case 'textStyles': {
              break
            }
            default:
          }
        }
      })

      callback(null, stdout)
    }
  )
}

module.exports.raw = true
