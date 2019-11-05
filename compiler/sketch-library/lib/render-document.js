/* eslint-disable global-require, import/no-dynamic-require */
const fs = require('fs')
const path = require('path')

const parseColor = require('color-parse')
const generateId = require('sketch-file/generateId')
const { TextStyles } = require('react-sketchapp')
const createComponentLayerCollection = require('./component-layer-collection')

function loadComponent(config, componentPath) {
  const relativeComponentPath = path
    .relative(config.paths.workspace, componentPath)
    .replace(/\.component$/gi, '')
  try {
    return {
      name: relativeComponentPath,
      compiled: require(path.join(config.paths.output, relativeComponentPath))
        .default,
      meta: JSON.parse(fs.readFileSync(componentPath)),
    }
  } catch (err) {
    console.error(`Failed to load ${componentPath}`)
    console.error(err)
    return undefined
  }
}

function arrangeComponentLayerCollections(collections) {
  return collections.reduce(
    (acc, collection) => {
      const { layers, offset } = acc
      const { artboard, symbols } = collection

      const arranged = [artboard, ...symbols].map(layer => {
        layer.frame.y += offset
        return layer
      })

      return {
        layers: layers.concat(arranged),
        offset: offset + artboard.frame.height + 96,
      }
    },
    {
      layers: [],
      offset: 0,
    }
  ).layers
}

module.exports = config => {
  const colors = config.tokens.colors
    .map(color => {
      const parsed = parseColor(color.value.value.css)
      if (!parsed) {
        return undefined
      }

      return {
        name: color.qualifiedName.join('/'),
        red: parsed.values[0] / 255,
        green: parsed.values[1] / 255,
        blue: parsed.values[2] / 255,
        alpha: parsed.alpha,
      }
    })
    .filter(x => x)

  TextStyles.create(
    {
      idMap: config.tokens.textStyles.reduce((prev, k) => {
        const name = k.qualifiedName.join('/')
        prev[name] = generateId(name)
        return prev
      }, {}),
    },
    config.tokens.textStyles.reduce((prev, k) => {
      const name = k.qualifiedName.join('/')
      if (k.value.value.color) {
        k.value.value.color = k.value.value.color.css
      }
      prev[name] = k.value.value
      return prev
    }, {})
  )

  const components = config.paths.components
    .filter(componentPath => {
      const relativeComponentPath = path
        .relative(config.paths.workspace, componentPath)
        .replace(/\.component$/gi, '')
      return config.componentPathFilter(relativeComponentPath)
    })
    .map(componentPath => loadComponent(config, componentPath))
    .filter(x => x)

  const collections = components
    .map(component => {
      try {
        return createComponentLayerCollection(
          component,
          config.devicePresetList
        )
      } catch (err) {
        console.error(`Skipping ${component.name} due to an error`)
        console.error(err)
        return undefined
      }
    })
    .filter(x => x)

  return {
    layers: arrangeComponentLayerCollections(collections),
    textStyles: TextStyles.toJSON(),
    colors,
  }
}
