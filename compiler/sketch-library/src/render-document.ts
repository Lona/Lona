/* eslint-disable global-require, import/no-dynamic-require */
import fs from 'fs'
import path from 'path'
import parseColor from 'color-parse'
import { TextStyles } from 'react-sketchapp'
import { FileFormat1 } from '@sketch-hq/sketch-file-format-ts'

import createComponentLayerCollection from './component-layer-collection'
import { Component } from './measure-component'
import { Preset } from './device-info'
import { ColorToken, TextStyleToken, ShadowToken } from './flat-tokens'

type Config = {
  paths: {
    output: string
    sketchFile: string
    workspace: string
    components: string[]
  }
  tokens: {
    colors: ColorToken[]
    textStyles: TextStyleToken[]
    shadows: ShadowToken[]
  }
  devicePresetList: Preset[]
  componentPathFilter: (filePath: string) => boolean
}

function loadComponent(config: Config, componentPath: string): Component {
  const relativeComponentPath = path
    .relative(config.paths.workspace, componentPath)
    .replace(/\.component$/gi, '')
  try {
    return {
      name: relativeComponentPath,
      compiled: require(path.join(config.paths.output, relativeComponentPath))
        .default,
      meta: JSON.parse(fs.readFileSync(componentPath, 'utf8')),
    }
  } catch (err) {
    console.error(`Failed to load ${componentPath}`)
    console.error(err)
    return undefined
  }
}

function arrangeComponentLayerCollections(
  collections: ReturnType<typeof createComponentLayerCollection>[]
) {
  return collections.reduce<{
    offset: number
    layers: (FileFormat1.SymbolMaster | FileFormat1.Artboard)[]
  }>(
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

export default (config: Config) => {
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
    config.tokens.textStyles.reduce((prev, k) => {
      const name = k.qualifiedName.join('/')

      prev[name] = {
        ...k.value.value,
        ...(k.value.value.color ? { color: k.value.value.color.css } : {}),
      }
      return prev
    }, {})
  )

  const components: Component[] = config.paths.components
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
