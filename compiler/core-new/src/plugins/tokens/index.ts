import * as path from 'path'
import { Helpers } from '../../helpers'
import { ConvertedWorkspace, ConvertedFile } from './tokens-ast'
import { convert } from './convert'

export const parseFile = async (
  filePath: string,
  helpers: Helpers
): Promise<string> => {
  const logicNode = helpers.config.logicFiles[filePath]

  if (!logicNode) {
    throw new Error(`${filePath} is not a token file`)
  }

  const name = path.basename(filePath, path.extname(filePath))
  const outputPath = path.relative(
    helpers.config.workspacePath,
    path.join(path.dirname(filePath), `${name}.flat.json`)
  )

  const file: ConvertedFile = {
    inputPath: path.relative(helpers.config.workspacePath, filePath),
    outputPath,
    name,
    contents: {
      type: 'flatTokens',
      value: convert(logicNode, helpers),
    },
  }

  return JSON.stringify(file, null, '  ')
}

export const parseWorkspace = async (
  workspacePath: string,
  helpers: Helpers
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

  const workspace: ConvertedWorkspace = {
    files: (
      await Promise.all(
        helpers.config.logicPaths
          .concat(helpers.config.documentPaths)
          .map(x => parseFile(x, helpers))
      )
    ).map(x => JSON.parse(x)),
    flatTokensSchemaVersion: '0.0.1',
  }
  console.log(JSON.stringify(workspace, null, '  '))
  return
}
