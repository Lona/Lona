const { convertLogic } = require('../../../lib/index')

jest.mock('uuid/v4', () => () => `0`)

test('import declaration', () => {
  const { xml, json } = require('../mocks/importDeclaration')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

test('variable', () => {
  const { xml, json } = require('../mocks/variable')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})
