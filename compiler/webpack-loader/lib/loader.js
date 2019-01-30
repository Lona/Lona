const path = require('path')
const fs = require('fs')
const qs = require('querystring')
const { getOptions } = require('loader-utils')
const { exec } = require('child_process')

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

// TODO: update that when we have a proper release
const lonacPath = path.join(__dirname, '../../core/src/main.bs.js')

function lonac(command, filePath, options, callback) {
  exec(
    `node "${lonacPath}" ${command} js --framework=${options.framework ||
      'reactdom'}${
      options.styleFramework
        ? ` --styleFramework=${options.styleFramework}`
        : ''
    } "${filePath}"`,
    (err, stdout, stderr) => {
      if (err) {
        callback(stderr || err)
        return
      }

      const imports = parseImports(stdout)

      imports.forEach(relativeFilePath => {
        const absolutePath = path.resolve(
          path.dirname(filePath),
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
          // we are assuming that all imported .json files should be handled by Lona
          stdout = stdout.replace(
            relativeFilePath,
            `${relativeFilePath}.js!=!${__filename}!${relativeFilePath}.json?__forceLona=1`
          )
        }
      })

      callback(null, stdout)
    }
  )
}

module.exports = function loader(source) {
  const callback = this.async()
  const options = getOptions(this) || {}

  const rawFilePath = path.normalize(this.resourcePath)

  // we only want to handle .component or files that were marked as such (for the .json files)
  if (
    path.extname(rawFilePath) !== '.component' &&
    (!this.resourceQuery || !qs.parse(this.resourceQuery)['?__forceLona'])
  ) {
    callback(null, source)
    return
  }

  switch (path.basename(rawFilePath)) {
    case 'colors.json':
      lonac('colors', rawFilePath, options, callback)
      break
    case 'textStyles.json':
      lonac('textStyles', rawFilePath, options, callback)
      break
    case 'shadows.json':
      lonac('shadows', rawFilePath, options, callback)
      break
    case 'types.json':
      lonac('types', rawFilePath, options, callback)
      break
    default:
      lonac('component', rawFilePath, options, callback)
  }
}

module.exports.raw = true
