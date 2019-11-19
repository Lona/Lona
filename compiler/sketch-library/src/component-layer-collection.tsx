import path from 'path'
import React from 'react'
import { Artboard, Text, View, StyleSheet, renderToJSON } from 'react-sketchapp'
import { FileFormat1 } from '@sketch-hq/sketch-file-format-ts'

import measureComponent, { Component } from './measure-component'
import deviceInfo, { Preset } from './device-info'
import createSymbol from './symbol'

function flatten<T>(arrays: T[][]): T[] {
  return [].concat(...arrays)
}

/* Calculate the sum of the first n elements in an array, optionally with spacing */
function prefixSum(array: number[], n: number, spacing = 0) {
  let sum = 0

  for (let i = 0; i < n; i += 1) {
    sum += array[i] + spacing
  }

  return sum
}

const marginHorizontal = 24
const headerHeight = 133 /* Determined by measuring from within Sketch */
const symbolVerticalSpacing = 40
const symbolHorizontalSpacing = 48

function createComponentSymbols(
  component: Component,
  measured: { rowHeights: number[]; columnWidths: number[] },
  devicePresetList: Preset[]
) {
  const {
    compiled,
    meta: { examples, devices },
  } = component
  const { rowHeights, columnWidths } = measured

  return flatten(
    examples.map((example, exampleIndex) =>
      devices.map((device, deviceIndex) => {
        const { name: deviceName, width: deviceWidth } = deviceInfo(
          device,
          devicePresetList
        )

        const symbol = createSymbol(
          compiled,
          example.params,
          `${example.name}/${deviceName}`,
          { width: deviceWidth }
        )

        symbol.frame.x =
          marginHorizontal +
          prefixSum(columnWidths, deviceIndex, symbolHorizontalSpacing)

        symbol.frame.y =
          headerHeight +
          prefixSum(rowHeights, exampleIndex, symbolVerticalSpacing)

        return symbol
      })
    )
  )
}

const styles = StyleSheet.create({
  artboard: {
    backgroundColor: '#FAFAFA',
  },
  header: {
    padding: 24,
    backgroundColor: 'white',
    marginBottom: 16,
  },
  componentLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#A4A4A4',
    marginBottom: 4,
  },
  componentTitle: {
    fontSize: 18,
  },
})

function createComponentArtboard(
  component: Component,
  measured: { rowHeights: number[]; columnWidths: number[] }
) {
  const { name } = component
  const { rowHeights, columnWidths } = measured

  const componentName = path.basename(name)
  const componentDirectoryPath = path.dirname(name)

  const totalWidth =
    marginHorizontal +
    prefixSum(columnWidths, columnWidths.length, symbolHorizontalSpacing)

  const totalHeight =
    headerHeight +
    prefixSum(rowHeights, rowHeights.length, symbolVerticalSpacing)

  return renderToJSON(
    <Artboard
      name={name}
      style={[styles.artboard, { width: totalWidth, height: totalHeight }]}
    >
      <View name="Header" style={styles.header}>
        {componentDirectoryPath ? (
          <Text name="Label" style={styles.componentLabel}>
            {componentDirectoryPath.replace('/', ' / ').toUpperCase()}
          </Text>
        ) : null}
        <Text name="Title" style={styles.componentTitle}>
          {componentName}
        </Text>
      </View>
    </Artboard>
  ) as FileFormat1.Artboard
}

export default function createComponentLayerCollection(
  component: Component,
  devicePresetList: Preset[]
) {
  const measured = measureComponent(component, devicePresetList)
  const artboard = createComponentArtboard(component, measured)
  const symbols = createComponentSymbols(component, measured, devicePresetList)

  return { artboard, symbols }
}
