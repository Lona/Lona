const { convertLogic } = require('../../lib/index')
const { parse: parseSwift, print: printSwift } = require('../../lib/swift')

const generateId = () => '0'

jest.mock('uuid/v4', () => () => '0')

describe('import declaration', () => {
  const { xml, json, code } = require('./mocks/declarations/importDeclaration')

  test('json -> xml', () => {
    const source = JSON.stringify(json)
    const converted = convertLogic(source, 'xml')
    expect(converted).toBe(xml)
  })

  test('xml -> json', () => {
    const converted = convertLogic(xml, 'json')
    const parsed = JSON.parse(converted)
    expect(parsed).toStrictEqual(json)
  })

  test('code -> json', () => {
    const converted = parseSwift(code, { generateId, startRule: 'statement' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})

describe('variable declaration', () => {
  const { xml, json, code } = require('./mocks/declarations/variable')

  test('json -> xml', () => {
    const source = JSON.stringify(json)
    const converted = convertLogic(source, 'xml')
    expect(converted).toBe(xml)
  })

  test('xml -> json', () => {
    const converted = convertLogic(xml, 'json')
    const parsed = JSON.parse(converted)
    expect(parsed).toStrictEqual(json)
  })

  test('code -> json', () => {
    const converted = parseSwift(code, { generateId, startRule: 'statement' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})

describe('variable declaration', () => {
  const { xml, json, code } = require('./mocks/declarations/namespace')

  test('json -> xml', () => {
    const source = JSON.stringify(json)
    const converted = convertLogic(source, 'xml')
    expect(converted).toBe(xml)
  })

  test('xml -> json', () => {
    const converted = convertLogic(xml, 'json')
    const parsed = JSON.parse(converted)
    expect(parsed).toStrictEqual(json)
  })

  test('code -> json', () => {
    const converted = parseSwift(code, { generateId, startRule: 'statement' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})

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

describe('array variable declaration', () => {
  const { xml, json, code } = require('./mocks/declarations/arrayVariable')

  test('json -> xml', () => {
    const source = JSON.stringify(json)
    const converted = convertLogic(source, 'xml')
    expect(converted).toBe(xml)
  })

  test('xml -> json', () => {
    const converted = convertLogic(xml, 'json')
    const parsed = JSON.parse(converted)
    expect(parsed).toStrictEqual(json)
  })

  test('code -> json', () => {
    const converted = parseSwift(code, { generateId, startRule: 'declaration' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})
