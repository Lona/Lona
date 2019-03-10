const { Buffer } = require('buffer')
const {
  createNewSketchFile,
  writeSketchFile,
  generateId,
} = require('sketch-file')

function findImages(layers) {
  const images = {}
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
          fill.image._ref = `images/${fill.image.sha1._data}`
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

module.exports = function modifySketchTemplate(
  { layers, textStyles, colors },
  output
) {
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
