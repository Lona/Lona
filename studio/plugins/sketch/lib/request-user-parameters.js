const { sendRequest } = require('stdio-jsonrpc')

function formatSketchFileUrl(url) {
  url = url.replace('file://', '')

  if (!url.endsWith('.sketch')) {
    url += '.sketch'
  }

  return url
}

module.exports = async function requestUserParameters() {
  const outputUrlKey = 'Save sketch file as'
  const componentsFilterKey = 'Which components?'
  const componentsFilterAll = 'All'
  const componentsFilterInclude = 'Include components matching'
  const componentsFilterExclude = 'Exclude components matching'
  const oneDay = 1000 * 60 * 60 * 24

  const response = await sendRequest(
    'customParameters',
    {
      id: 'dialog-configure-sketch',
      title: 'Configure Sketch file generation',
      params: [
        { name: outputUrlKey, type: 'URL' },
        {
          name: componentsFilterKey,
          type: {
            cases: [
              componentsFilterAll,
              { case: componentsFilterInclude, type: 'String' },
              { case: componentsFilterExclude, type: 'String' },
            ],
            name: 'Enum',
          },
        },
      ],
      persistenceScope: 'workspace',
    },
    oneDay
  )

  console.error(`User params ${response}, ${response[outputUrlKey]}.`)

  if (!response) {
    console.error(`Sketch file generation cancelled`)
    process.exit(0)
  }

  if (!response[outputUrlKey]) {
    console.error(
      `Sketch file generation failed -- an output file path is required`
    )
    process.exit(0)
  }

  const filterValue = response[componentsFilterKey]
  const regex = filterValue ? new RegExp(filterValue.data) : undefined

  return {
    sketchFilePath: formatSketchFileUrl(response[outputUrlKey]),
    componentPathFilter: componentPath => {
      if (!filterValue) {
        return true
      }

      switch (filterValue.case) {
        case componentsFilterAll: {
          return true
        }
        case componentsFilterInclude: {
          return regex.test(componentPath)
        }
        case componentsFilterExclude: {
          return !regex.test(componentPath)
        }
        default: {
          return true
        }
      }
    },
  }
}
