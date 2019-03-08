const fs = require('fs')
const os = require('os')
const path = require('path')
const { Buffer } = require('buffer')
const { exec, execSync } = require('child_process')
const {
  createNewSketchFile,
  writeSketchFile,
  generateId,
} = require('sketch-file')
const renderDocument = require('./render-document')

// Temporary directory for the compiler to write generated JS files
const compilerOutput = path.join(os.tmpdir(), 'lona-sketch-library-generated')

function findImages(layers) {
  let images = {}
  layers.forEach(layer => {
    if (layer && layer.style && layer.style.fills) {
      layer.style.fills.forEach(fill => {
        if (!fill.image) {
          return
        }
        if (fill.image.data && fill.image.sha1) {
          images[fill.image.sha1._data] = Buffer.from(
            fill.image.data._data,
            'base64'
          )
          fill.image._ref = 'images/' + fill.image.sha1._data
          delete fill.image.data
          delete fill.image.sha1
          fill.image._class = 'MSJSONFileReference'
        }
      })
    }
    if (layer.layers) {
      Object.assign(images, findImages(layer.layers))
    }
  })
  return images
}

function modifySketchTemplate({ layers, textStyles, colors }, output) {
  const sketchDoc = createNewSketchFile(generateId(output))

  const images = findImages(layers)

  sketchDoc.document.layerTextStyles.objects = textStyles
  sketchDoc.document.assets.colors = colors.map(c => ({
    _class: 'color',
    alpha: c.alpha,
    blue: c.blue,
    green: c.green,
    red: c.red,
  }))
  sketchDoc.document.assets.colorAssets = colors.map(c => ({
    _class: 'MSImmutableColorAsset',
    name: c.name,
    color: {
      _class: 'color',
      alpha: c.alpha,
      blue: c.blue,
      green: c.green,
      red: c.red,
    },
  }))
  sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers)
  sketchDoc.images = images

  return writeSketchFile(sketchDoc, output)
}

module.exports = function(workspace, sketchFilePath, options) {
  const { devicePresetList, compiler, componentPathFilter, logFunction } =
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
          output: compilerOutput,
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
    .then(config => {
      log(`Generating sketch file at ${sketchFilePath}`)
      const values = renderDocument(config)
      return modifySketchTemplate(values, config.paths.sketchFile)
    })
}
