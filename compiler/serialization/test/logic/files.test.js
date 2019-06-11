const { convertLogic } = require('../../lib/index')

jest.mock('uuid/v4', () => () => `0`)

test('colors file -> xml', () => {
  const { xml, json } = require('./mocks/files/colors')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('colors file -> json', () => {
  const { xml, json } = require('./mocks/files/colors')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})
