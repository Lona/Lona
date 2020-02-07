import * as path from 'path'
import upperFirst from 'lodash.upperfirst'
import camelCase from 'lodash.camelcase'
import { Helpers } from '../../helpers'
import convertLogic from './convert-logic'
import renderJS from './render-ast'
import * as JSAST from './js-ast'

export const parseFile = async (
  filePath: string,
  helpers: Helpers & {
    emitFile?: (filePath: string, data: string) => Promise<void>
  },
  options: {
    [key: string]: unknown
  }
): Promise<string> => {
  let jsAST: JSAST.JSNode | undefined

  const logicNode = helpers.config.logicFiles[filePath]
  if (logicNode) {
    if (
      logicNode.type !== 'topLevelDeclarations' ||
      !logicNode.data.declarations.length
    ) {
      return ''
    }
    jsAST = convertLogic(logicNode, helpers)
  }

  if (!jsAST) {
    return ''
  }

  // only output file if we passed an output option
  const outputFile =
    typeof options['output'] !== 'undefined' ? helpers.fs.writeFile : undefined

  return `${renderJS(jsAST, { outputFile, reporter: helpers.reporter })}`
}

export const parseWorkspace = async (
  workspacePath: string,
  helpers: Helpers,
  options: {
    [key: string]: unknown
  }
): Promise<void> => {
  await Promise.all(
    helpers.config.logicPaths
      .concat(helpers.config.documentPaths)
      .map(async filePath => {
        const swiftContent = await parseFile(filePath, helpers, options)
        if (!swiftContent) {
          return
        }
        const name = upperFirst(
          camelCase(path.basename(filePath, path.extname(filePath)))
        )
        const outputPath = path.join(path.dirname(filePath), `${name}.js`)

        await helpers.fs.writeFile(outputPath, swiftContent)
      })
  )

  // await helpers.fs.copyDir(
  //   path.join(__dirname, '../../../static/js'),
  //   './lona-helpers'
  // )
}
