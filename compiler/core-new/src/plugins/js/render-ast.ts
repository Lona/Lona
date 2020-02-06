import {
  builders,
  group,
  indent,
  join,
  prefixAll,
  Doc,
  print,
} from '../../utils/printer'

import * as JSAST from './js-ast'

type Options = {
  outputFile?: (filePath: string, data: string) => Promise<void>
  reporter: {
    log(...args: any[]): void
    warn(...args: any[]): void
    error(...args: any[]): void
  }
}

const printerOptions = { printWidth: 120, tabWidth: 2, useTabs: false }

export default function toString(ast: JSAST.JSNode, options: Options) {
  return print(render(ast, options), printerOptions)
}
