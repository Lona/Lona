import * as path from 'path'
import * as serialization from '@lona/serialization'
import { Helpers } from '../../helpers'
import { ConvertedWorkspace, ConvertedFile } from './tokens-ast'
import { convert } from './convert'

export const parseFile = async (
  filePath: string,
  helpers: Helpers
): Promise<string> => {
  let logicNode: serialization.LogicAST.SyntaxNode
  if (path.extname(filePath) === '.logic') {
    logicNode = serialization.decodeLogic(await helpers.fs.readFile(filePath))
  } else if (path.extname(filePath) === '.md') {
    logicNode = serialization.extractProgramAST(
      await helpers.fs.readFile(filePath)
    )
  } else {
    throw new Error(`${filePath} is not a token file`)
  }

  const name = path.basename(filePath, path.extname(filePath))
  const outputPath = path.join(path.dirname(filePath), `${name}.flat.json`)

  const file: ConvertedFile = {
    inputPath: filePath,
    name,
    outputPath,
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
    flatTokensSchemaVersion: '0.0.1',
    files: (
      await Promise.all(
        helpers.config.logicPaths
          .concat(helpers.config.tokenPaths)
          .map(x => parseFile(x, helpers))
      )
    ).map(x => JSON.parse(x)),
  }
  console.log(JSON.stringify(workspace, null, '  '))
  return
}
