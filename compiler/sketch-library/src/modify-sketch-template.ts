import { Buffer } from 'buffer'
import { createNewSketchFile, writeSketchFile, generateId } from 'sketch-file'
import renderDocument from './render-document'

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

export default function modifySketchTemplate(
  { layers, textStyles, colors }: ReturnType<typeof renderDocument>,
  output: string
) {
  const sketchDoc = createNewSketchFile()
  sketchDoc.document.do_objectID = generateId(output)

  const images = findImages(layers)

  sketchDoc.document.layerTextStyles.objects = textStyles
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
  sketchDoc.pages[0].name = 'Components'
  sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers)
  sketchDoc.images = images

  return writeSketchFile(sketchDoc, output)
}
