const { convertLogic } = require('../../lib/index')
const { parse: parseSwift, print: printSwift } = require('../../lib/swift')

jest.mock('uuid/v4', () => () => `0`)

//

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

//

describe('top level declarations', () => {
  test('json -> xml', () => {
    const { xml, json } = require('./mocks/files/topLevelDeclarations')

    const source = JSON.stringify(json)
    const converted = convertLogic(source, 'xml')

    expect(converted).toBe(xml)
  })

  test('xml -> json', () => {
    const { xml, json } = require('./mocks/files/topLevelDeclarations')

    const converted = convertLogic(xml, 'json')
    const parsed = JSON.parse(converted)

    expect(parsed).toStrictEqual(json)
  })

  test('code -> json', () => {
    const { code, json } = require('./mocks/files/topLevelDeclarations')

    const converted = parseSwift(code, { generateId: () => '0' })

    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const { code, json } = require('./mocks/files/topLevelDeclarations')

    const converted = printSwift(json)

    expect(converted).toBe(code)
  })
})
