const { convertLogic } = require('../../lib/index')

jest.mock('uuid/v4', () => () => `0`)

//

test('function call expression -> xml', () => {
  const { xml, json } = require('./mocks/expressions/functionCallExpression')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('function call expression -> json', () => {
  const { xml, json } = require('./mocks/expressions/functionCallExpression')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

//

test('member expression -> xml', () => {
  const { xml, json } = require('./mocks/expressions/memberExpression')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('member expression -> json', () => {
  const { xml, json } = require('./mocks/expressions/memberExpression')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})
