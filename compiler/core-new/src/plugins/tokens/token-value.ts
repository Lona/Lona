import * as LogicEvaluate from '../../helpers/logic-evaluate'
import * as LogicUnify from '../../helpers/logic-unify'
import * as TokenAST from './tokens-ast'

let getField = (key: string, fields: LogicEvaluate.Memory) => {
  if (fields.type !== 'record') {
    return
  }
  return fields.value[key]
}

const getColorString = (value: LogicEvaluate.Value): string | undefined => {
  if (
    value.type.type !== 'constant' ||
    value.type.name !== LogicUnify.color.name ||
    value.memory.type !== 'record'
  ) {
    return undefined
  }
  const field = getField('value', value.memory)
  if (field && field.memory.type === 'string') {
    return field.memory.value
  }
}

const getColorValue = (
  value?: LogicEvaluate.Value
): TokenAST.ColorTokenValue | undefined => {
  if (!value) {
    return undefined
  }
  const css = getColorString(value)
  if (css) {
    return { type: 'color', value: { css } }
  }
  return undefined
}

const getOptional = (value?: LogicEvaluate.Value) => {
  if (!value) {
    return undefined
  }
  if (
    value.type.type === 'constant' &&
    value.type.name === 'Optional' &&
    value.memory.type === 'enum' &&
    value.memory.value === 'value' &&
    value.memory.data.length === 1
  ) {
    return value.memory.data[0]
  }
  return undefined
}

const getFontWeight = (
  value?: LogicEvaluate.Value
): TokenAST.FontWeight | undefined => {
  if (!value) {
    return undefined
  }
  if (
    value.type.type !== 'constant' ||
    value.type.name !== 'FontWeight' ||
    value.memory.type !== 'enum'
  ) {
    return undefined
  }

  switch (value.memory.value) {
    case 'ultraLight':
      return '100'
    case 'thin':
      return '200'
    case 'light':
      return '300'
    case 'regular':
      return '400'
    case 'medium':
      return '500'
    case 'semibold':
      return '600'
    case 'bold':
      return '700'
    case 'heavy':
      return '800'
    case 'black':
      return '900'
    default: {
      throw new Error('Bad FontWeight: ' + value.memory.value)
    }
  }
}

const getShadowValue = (
  value?: LogicEvaluate.Value
): TokenAST.ShadowTokenValue | undefined => {
  if (!value) {
    return undefined
  }
  if (
    value.type.type !== 'constant' ||
    value.type.name !== LogicUnify.shadow.name ||
    value.memory.type !== 'record'
  ) {
    return undefined
  }

  const fields = value.memory

  const [x, y, blur, radius] = ['x', 'y', 'blur', 'radius']
    .map(x => getField(x, fields))
    .map(x => (x && x.memory.type === 'number' ? x.memory.value : 0))
  let color: TokenAST.ColorValue | undefined
  if (fields.value['color']) {
    const colorValue = getColorValue(fields.value['color'])
    if (colorValue) {
      color = colorValue.value
    }
  }
  if (!color) {
    color = { css: 'black' }
  }
  return { type: 'shadow', value: { x, y, blur, radius, color } }
}

const getTextStyleValue = (
  value?: LogicEvaluate.Value
): TokenAST.TextStyleTokenValue | undefined => {
  if (!value) {
    return undefined
  }
  if (
    value.type.type !== 'constant' ||
    value.type.name !== LogicUnify.textStyle.name ||
    value.memory.type !== 'record'
  ) {
    return undefined
  }

  const fields = value.memory

  const [fontSize, lineHeight, letterSpacing] = [
    'fontSize',
    'lineHeight',
    'letterSpacing',
  ]
    .map(x => getOptional(getField(x, fields)))
    .map(x => (x && x.memory.type === 'number' ? x.memory.value : undefined))
  const [fontName, fontFamily] = ['fontName', 'fontFamily']
    .map(x => getOptional(getField(x, fields)))
    .map(x => (x && x.memory.type === 'string' ? x.memory.value : undefined))
  const [color] = ['color']
    .map(x => getColorValue(getOptional(getField(x, fields))))
    .map(x => (x ? x.value : undefined))
  const [fontWeight] = ['fontWeight']
    .map(x => getField(x, fields))
    .map(x => getFontWeight(x) || '400')

  return {
    type: 'textStyle',
    value: {
      fontFamily,
      fontWeight,
      fontSize,
      lineHeight,
      letterSpacing,
      fontName,
      color,
    },
  }
}

export const create = (
  value?: LogicEvaluate.Value
): TokenAST.TokenValue | undefined =>
  getColorValue(value) ||
  getShadowValue(value) ||
  getTextStyleValue(value) ||
  undefined
