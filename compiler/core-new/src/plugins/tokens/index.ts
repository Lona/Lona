import * as path from 'path'
import * as serialization from '@lona/serialization'
import { Helpers } from '../../helpers'
import * as LogicAST from '../../helpers/logic-ast'

export const parseFile = async (
  filePath: string,
  helpers: Helpers,
  options: any
): Promise<string> => {
  let logicNode: LogicAST.AST.SyntaxNode
  if (path.extname(filePath) === '.logic') {
    logicNode = JSON.parse(
      serialization.convertLogic(
        await helpers.fs.readFile(filePath),
        serialization.SERIALIZATION_FORMAT.JSON
      )
    )
  } else if (path.extname(filePath) === '.md') {
    logicNode = JSON.parse(
      serialization.extractProgram(await helpers.fs.readFile(filePath))
    )
  } else {
    throw new Error(`${filePath} is not a token file`)
  }
}

export const parseWorkspace = async (
  workspacePath: string,
  helpers: Helpers,
  options: any
): Promise<void> => {
  if (!helpers.evaluationContext) {
    helpers.reporter.warn('Failed to evaluate workspace.')
    console.log(
      JSON.stringify(
        { flatTokensSchemaVersion: '0.0.1', files: [] },
        null,
        '  '
      )
    )
    return
  }

  console.log(
    JSON.stringify(
      {
        flatTokensSchemaVersion: '0.0.1',
        files: (
          await Promise.all(
            helpers.config.logicPaths
              .concat(helpers.config.tokenPaths)
              .map(x => parseFile(x, helpers, options))
          )
        ).map(x => JSON.parse(x)),
      },
      null,
      '  '
    )
  )
  return
}
