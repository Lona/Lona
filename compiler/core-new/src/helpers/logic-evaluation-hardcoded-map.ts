import Color from 'color'

import { HardcodedMap } from './index'
import { Value } from './logic-evaluate'
import { unit, string, bool, color } from './logic-unify'

export const hardcoded: HardcodedMap<Value, (Value | void)[]> = {
  functionCallExpression: {
    'Color.saturate': (node, baseColor, percent) => {
      if (
        !baseColor ||
        baseColor.type.type !== 'constant' ||
        baseColor.type.name !== 'Color' ||
        baseColor.memory.type !== 'record' ||
        !baseColor.memory.value.value ||
        baseColor.memory.value.value.memory.type !== 'string'
      ) {
        throw new Error(
          'The first argument of `Color.saturate` need to be a color'
        )
      }

      const parsedColor = Color(baseColor.memory.value.value.memory.value)

      if (!percent || percent.memory.type !== 'number') {
        throw new Error(
          'The second argument of `Color.saturate` need to be a number'
        )
      }

      return {
        type: color,
        memory: {
          type: 'record',
          value: {
            value: {
              type: string,
              memory: {
                type: 'string',
                value: parsedColor.saturate(percent.memory.value).hex(),
              },
            },
          },
        },
      }
    },
    'Color.setHue': () => {},
    'Color.setSaturation': () => {},
    'Color.setLightness': () => {},
    'Color.fromHSL': () => {},
    'Boolean.or': (node, a, b) => {
      if (!a || a.memory.type !== 'bool') {
        throw new Error(
          'The first argument of `Boolean.or` need to be a boolean'
        )
      }

      if (!b || b.memory.type !== 'bool') {
        throw new Error(
          'The second argument of `Boolean.or` need to be a boolean'
        )
      }

      return {
        type: bool,
        memory: {
          type: 'bool',
          value: a.memory.value || b.memory.value,
        },
      }
    },
    'Boolean.and': (node, a, b) => {
      if (!a || a.memory.type !== 'bool') {
        throw new Error(
          'The first argument of `Boolean.and` need to be a boolean'
        )
      }

      if (!b || b.memory.type !== 'bool') {
        throw new Error(
          'The second argument of `Boolean.and` need to be a boolean'
        )
      }

      return {
        type: bool,
        memory: {
          type: 'bool',
          value: a.memory.value && b.memory.value,
        },
      }
    },
    'String.concat': (node, a, b) => {
      if (!a || a.memory.type !== 'string') {
        throw new Error(
          'The first argument of `String.concat` need to be a string'
        )
      }

      if (!b || b.memory.type !== 'string') {
        throw new Error(
          'The second argument of `String.concat` need to be a string'
        )
      }

      return {
        type: string,
        memory: {
          type: 'string',
          value: a.memory.value + b.memory.value,
        },
      }
    },
    'Number.range': () => {},
    'Array.at': (node, array, index) => {
      if (!array || array.memory.type !== 'array') {
        throw new Error('The first argument of `Array.at` need to be an array')
      }

      if (!index || index.memory.type !== 'number') {
        throw new Error('The second argument of `Array.at` need to be a number')
      }

      return array.memory.value[index.memory.value]
    },
    'Optional.value': (node, value) => {
      if (!value) {
        throw new Error(
          'The first argument of `Optional.value` needs to be a value'
        )
      }
      return value
    },
    Shadow: () => {
      // polyfilled
    },
    TextStyle: () => {
      // polyfilled
    },
  },
  memberExpression: {
    'Optional.none': () => ({
      type: unit,
      memory: { type: 'unit' },
    }),
    'FontWeight.ultraLight': () => {},
    'FontWeight.thin': () => {},
    'FontWeight.light': () => {},
    'FontWeight.regular': () => {},
    'FontWeight.medium': () => {},
    'FontWeight.semibold': () => {},
    'FontWeight.bold': () => {},
    'FontWeight.heavy': () => {},
    'FontWeight.black': () => {},
    'FontWeight.w100': () => {},
    'FontWeight.w200': () => {},
    'FontWeight.w300': () => {},
    'FontWeight.w400': () => {},
    'FontWeight.w500': () => {},
    'FontWeight.w600': () => {},
    'FontWeight.w700': () => {},
    'FontWeight.w800': () => {},
    'FontWeight.w900': () => {},
  },
}
