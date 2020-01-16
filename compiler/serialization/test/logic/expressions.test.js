/* eslint-disable import/no-unresolved */
import { convertLogic } from '../../src/index'
import {
  parse as parseSwift,
  print as printSwift,
} from '../../src/convert/swift/logic'

const generateId = () => '0'

jest.mock('uuid/v4', () => () => `0`)

describe('function call expression', () => {
  const {
    xml,
    json,
    code,
  } = require('./mocks/expressions/functionCallExpression')

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
    const converted = parseSwift(code, { generateId, startRule: 'expression' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})

describe('member expression', () => {
  const { xml, json, code } = require('./mocks/expressions/memberExpression')

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
    const converted = parseSwift(code, { generateId, startRule: 'expression' })
    expect(converted).toStrictEqual(json)
  })

  test('json -> code', () => {
    const converted = printSwift(json)
    expect(converted).toBe(code)
  })
})
