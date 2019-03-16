const fs = require('fs')
const os = require('os')
const path = require('path')
const { exec } = require('child_process')
const renderDocument = require('./render-document')
const modifySketchTemplate = require('./modify-sketch-template')

// https://gist.github.com/branneman/8048520#gistcomment-1249909
// Add node_modules to the path, so they're resolved even when loading modules
// from our compilerOutput directory (which is outside the root of this project)
process.env.NODE_PATH = path.join(__dirname, '../node_modules')
process.env.NODE_PATH += ':'
process.env.NODE_PATH += path.join(process.cwd(), 'node_modules')
require('module').Module._initPaths()

// Temporary directory for the compiler to write generated JS files
const compilerOutput = path.join(os.tmpdir(), 'lona-sketch-library-generated')
const babelOutput = path.join(os.tmpdir(), 'lona-sketch-library-compiled')

module.exports = function generateSketchLibrary(
  workspace,
  sketchFilePath,
  options
) {
  let { devicePresetList, compiler, componentPathFilter, logFunction } =
    options || {}

  function log(text) {
    if (logFunction) {
      logFunction(text)
    }
  }

  if (!workspace) {
    throw new Error('missing workspace path')
  }

  if (!sketchFilePath) {
    throw new Error('missing output path')
  }

  if (!compiler) {
    compiler = require.resolve('lonac')
  }

  if (!devicePresetList) {
    devicePresetList = [
      { name: 'iPhone SE', width: 320, height: 568 },
      { name: 'iPhone 8', width: 375, height: 667 },
      { name: 'iPhone 8 Plus', width: 414, height: 736 },
      { name: 'iPhone XS', width: 375, height: 812 },
      { name: 'iPhone XR', width: 414, height: 896 },
      { name: 'iPhone XS Max', width: 414, height: 896 },
      { name: 'iPad', width: 768, height: 1024 },
      { name: 'iPad Pro 10.5"', width: 834, height: 1112 },
      { name: 'iPad Pro 11"', width: 834, height: 1194 },
      { name: 'iPad Pro 12.9"', width: 1024, height: 1366 },
      { name: 'Pixel 2', width: 412, height: 732 },
      { name: 'Pixel 2 XL', width: 360, height: 720 },
      { name: 'Galaxy S8', width: 360, height: 740 },
      { name: 'Nexus 7', width: 600, height: 960 },
      { name: 'Nexus 9', width: 768, height: 1024 },
      { name: 'Nexus 10', width: 800, height: 1280 },
      { name: 'Desktop', width: 1024, height: 1024 },
      { name: 'Desktop HD', width: 1440, height: 1024 },
    ]
  }

  if (!componentPathFilter) {
    componentPathFilter = function() {
      return true
    }
  }

  try {
    fs.mkdirSync(compilerOutput, { recursive: true })
  } catch (err) {
    if (err.code !== 'EEXIST') {
      throw err
    }
    // TODO: remove previous export
  }

  return new Promise((resolve, reject) => {
    log(`Getting the configuration of the workspace`)
    exec(`node "${compiler}" config "${workspace}"`, (err, stdout, stderr) => {
      if (err) {
        err.stdout = stdout
        err.stderr = stderr
        return reject(err)
      }

      return resolve(stdout)
    })
  })
    .then(rawConfig => {
      const compilerConfig = JSON.parse(rawConfig)

      return {
        paths: {
          output: babelOutput,
          sketchFile: sketchFilePath,
          workspace: compilerConfig.paths.workspace,
          colors: compilerConfig.paths.colors,
          textStyles: compilerConfig.paths.textStyles,
          components: compilerConfig.paths.components,
        },
        devicePresetList,
        componentPathFilter,
      }
    })
    .then(
      config =>
        new Promise((resolve, reject) => {
          log(`Generating react-sketchapp project at ${compilerOutput}`)
          exec(
            `node "${compiler}" workspace js "${workspace}" "${compilerOutput}" --framework=reactsketchapp`,
            (err, stdout, stderr) => {
              if (err) {
                err.stdout = stdout
                err.stderr = stderr
                return reject(err)
              }
              console.error(stdout)
              console.error(stderr)
              return resolve(config)
            }
          )
        })
    )
    .then(
      config =>
        new Promise((resolve, reject) => {
          log(`Compiling react-sketchapp project at ${babelOutput}`)
          exec(
            `node "${require.resolve(
              '@babel/cli/bin/babel'
            )}" "${compilerOutput}" --out-dir "${babelOutput}"  --presets=@babel/env,@babel/react`,
            (err, stdout, stderr) => {
              if (err) {
                err.stdout = stdout
                err.stderr = stderr
                return reject(err)
              }
              console.error(stdout)
              console.error(stderr)
              return resolve(config)
            }
          )
        })
    )
    .then(config => {
      log(`Generating sketch file at ${sketchFilePath}`)
      const values = renderDocument(config)
      return modifySketchTemplate(values, config.paths.sketchFile)
    })
}
