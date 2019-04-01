const path = require('path')
const React = require('react')
const {
  Artboard,
  Text,
  View,
  StyleSheet,
  renderToJSON,
} = require('react-sketchapp')

const measureComponent = require('./measure-component')
const deviceInfo = require('./device-info')
const createSymbol = require('./symbol')

function flatten(arrays) {
  return [].concat(...arrays)
}

/* Calculate the sum of the first n elements in an array, optionally with spacing */
function prefixSum(array, n, spacing = 0) {
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

function createComponentSymbols(component, measured, devicePresetList) {
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

        const symbolElement = createSymbol(
          compiled,
          example.params,
          `${example.name}/${deviceName}`,
          { width: deviceWidth }
        )

        const symbol = renderToJSON(symbolElement)

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

function createComponentArtboard(component, measured) {
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
    React.createElement(
      Artboard,
      {
        name,
        style: [styles.artboard, { width: totalWidth, height: totalHeight }],
      },
      React.createElement(View, { name: 'Header', style: styles.header }, [
        componentDirectoryPath
          ? React.createElement(
              Text,
              { name: 'Label', style: styles.componentLabel, key: 'Label' },
              componentDirectoryPath.replace('/', ' / ').toUpperCase()
            )
          : null,
        React.createElement(
          Text,
          { name: 'Title', style: styles.componentTitle, key: 'title' },
          componentName
        ),
      ])
    )
  )
}

module.exports = function createComponentLayerCollection(
  component,
  devicePresetList
) {
  const measured = measureComponent(component, devicePresetList)
  const artboard = createComponentArtboard(component, measured)
  const symbols = createComponentSymbols(component, measured, devicePresetList)

  return { artboard, symbols }
}
