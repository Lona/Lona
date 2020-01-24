import * as path from 'path'
import upperFirst from 'lodash.upperfirst'
import camelCase from 'lodash.camelcase'
import { Helpers } from '../../helpers'
import convertLogic from './convert-logic'
import * as SwiftAST from '../../types/swift-ast'

export const parseFile = async (
  filePath: string,
  helpers: Helpers
): Promise<string> => {
  let swiftAST: SwiftAST.SwiftNode | undefined

  const logicNode = helpers.config.logicFiles[filePath]
  if (logicNode) {
    if (
      logicNode.type !== 'topLevelDeclarations' ||
      !logicNode.data.declarations.length
    ) {
      return ''
    }
    swiftAST = convertLogic(logicNode, helpers)
  }

  if (!swiftAST) {
    return ''
  }

  return JSON.stringify(swiftAST, null, '  ')
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
        const swiftContent = await parseFile(filePath, helpers)
        if (!swiftContent) {
          return
        }
        const name = upperFirst(
          camelCase(path.basename(filePath, path.extname(filePath)))
        )
        const outputPath = path.relative(
          helpers.config.workspacePath,
          path.join(path.dirname(filePath), `${name}.swift`)
        )

        await helpers.fs.writeFile(outputPath, swiftContent)
      })
  )
}
