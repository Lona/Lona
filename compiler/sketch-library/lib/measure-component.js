const { View, renderToJSON } = require('react-sketchapp')
const React = require('react')

const deviceInfo = require('./device-info')

function measureElement(element) {
  return renderToJSON(element).frame
}

/* Measure each combination of example/device */
function measureComponentElements(component, devicePresetList) {
  const {
    compiled,
    meta: { examples, devices },
  } = component

  return examples.map((example, exampleIndex) => {
    return devices.map((device, deviceIndex) => {
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
function measureRowHeights(elements) {
  return elements.map(frames => Math.max(...frames.map(frame => frame.height)))
}

/* Determines the max width of every element in a column */
function measureColumnWidths(elements) {
  const columnWidths = []
  const columnCount = Math.max(...elements.map(frames => frames.length))

  for (let j = 0; j < elements.length; j++) {
    for (let i = 0; i < columnCount; i++) {
      columnWidths[i] = Math.max(columnWidths[i] || 0, elements[j][i].width)
    }
  }

  return columnWidths
}

module.exports = function measureComponent(component, devicePresetList) {
  const elements = measureComponentElements(component, devicePresetList)
  const rowHeights = measureRowHeights(elements)
  const columnWidths = measureColumnWidths(elements)

  return {
    elements,
    rowHeights,
    columnWidths,
  }
}
