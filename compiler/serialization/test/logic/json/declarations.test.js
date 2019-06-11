const { convertLogic } = require('../../../lib/index')

test('import declaration', () => {
  const { xml, json } = require('../mocks/importDeclaration')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('variable declaration', () => {
  const { xml, json } = require('../mocks/variable')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})
