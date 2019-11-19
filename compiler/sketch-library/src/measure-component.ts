import { View, renderToJSON } from 'react-sketchapp'
import React from 'react'

import deviceInfo, { Preset, Device } from './device-info'

export type Component = {
  name: string
  compiled: React.ComponentType
  meta: {
    examples: { params: { [name: string]: any }; name: string }[]
    devices: Device[]
  }
}

type Frame = { width: number; height: number; x: number; y: number }

function measureElement(element: React.ReactElement): Frame {
  return renderToJSON(element).frame
}

/* Measure each combination of example/device */
function measureComponentElements(
  component: Component,
  devicePresetList: Preset[]
) {
  const {
    compiled,
    meta: { examples, devices },
  } = component

  return examples.map(example => {
    return devices.map(device => {
      return measureElement(
        React.createElement(
          View,
          { style: { width: deviceInfo(device, devicePresetList).width } },
          React.createElement(compiled, example.params)
        )
      )
    })
  })
}

/* Determines the max height of every element in a row */
function measureRowHeights(elements: Frame[][]) {
  return elements.map(frames => Math.max(...frames.map(frame => frame.height)))
}

/* Determines the max width of every element in a column */
function measureColumnWidths(elements: Frame[][]) {
  const columnWidths: number[] = []
  const columnCount = Math.max(...elements.map(frames => frames.length))

  for (let j = 0; j < elements.length; j += 1) {
    for (let i = 0; i < columnCount; i += 1) {
      columnWidths[i] = Math.max(columnWidths[i] || 0, elements[j][i].width)
    }
  }

  return columnWidths
}

export default function measureComponent(
  component: Component,
  devicePresetList: Preset[]
) {
  const elements = measureComponentElements(component, devicePresetList)
  const rowHeights = measureRowHeights(elements)
  const columnWidths = measureColumnWidths(elements)

  return {
    elements,
    rowHeights,
    columnWidths,
  }
}
