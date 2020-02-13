/* eslint-disable import/no-unresolved */
import { convertLogic } from '../../src/index'
import {
  parse as parseSwift,
  print as printSwift,
} from '../../src/convert/swift/logic'

jest.mock('uuid/v4', () => () => `0`)

describe('colors file', () => {
  const { xml, json, code } = require('./mocks/files/colors')

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
    const converted = parseSwift(code, {
      generateId: () => '0',
      startRule: 'program',
    })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})

describe('top level declarations', () => {
  const { xml, json, code } = require('./mocks/files/topLevelDeclarations')

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
    const converted = parseSwift(code, { generateId: () => '0' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})
