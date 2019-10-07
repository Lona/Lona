const { convertLogic } = require('../../lib/index')

jest.mock('uuid/v4', () => () => `0`)

//

test('record -> xml', () => {
  const { xml, json } = require('./mocks/declarations/record')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('record -> json', () => {
  const { xml, json } = require('./mocks/declarations/record')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

//

test('import declaration -> xml', () => {
  const { xml, json } = require('./mocks/declarations/importDeclaration')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('import declaration -> json', () => {
  const { xml, json } = require('./mocks/declarations/importDeclaration')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

//

test('variable declaration -> xml', () => {
  const { xml, json } = require('./mocks/declarations/variable')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('variable declaration -> json', () => {
  const { xml, json } = require('./mocks/declarations/variable')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

//

test('array variable declaration -> xml', () => {
  const { xml, json } = require('./mocks/declarations/arrayVariable')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('array variable declaration -> json', () => {
  const { xml, json } = require('./mocks/declarations/arrayVariable')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})

//

test('namespace declaration -> xml', () => {
  const { xml, json } = require('./mocks/declarations/namespace')

  const source = JSON.stringify(json)
  const converted = convertLogic(source, 'xml')

  expect(converted).toBe(xml)
})

test('namespace declaration -> json', () => {
  const { xml, json } = require('./mocks/declarations/namespace')

  const converted = convertLogic(xml, 'json')
  const parsed = JSON.parse(converted)

  expect(parsed).toStrictEqual(json)
})
