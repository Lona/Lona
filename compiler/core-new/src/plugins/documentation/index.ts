import * as path from 'path'
import { Helpers } from '../../helpers'
import { ConvertedWorkspace, ConvertedFile } from '../tokens/tokens-ast'
import { convert } from './convert'
import { findChildPages } from './utils'

export const parseFile = async (
  filePath: string,
  helpers: Helpers
): Promise<ConvertedFile> => {
  const documentNode = helpers.config.componentFiles[filePath]

  if (!documentNode) {
    throw new Error(`${filePath} is not a documentation file`)
  }

  const name = path.basename(filePath, path.extname(filePath))
  const outputPath = path.join(path.dirname(filePath), `${name}.mdx`)

  const value = {
    mdxString: convert(documentNode, helpers),
    children: findChildPages(documentNode),
  }

  const file: ConvertedFile = {
    inputPath: filePath,
    outputPath,
    name,
    contents: {
      type: 'documentationPage',
      value,
    },
  }

  return file
}

export const parseWorkspace = async (
  workspacePath: string,
  helpers: Helpers,
  options: {
    [key: string]: unknown
  }
): Promise<ConvertedWorkspace | void> => {
  let workspace: ConvertedWorkspace

  if (!helpers.evaluationContext) {
    helpers.reporter.warn('Failed to evaluate workspace.')
    workspace = { flatTokensSchemaVersion: '0.0.1', files: [] }
  } else {
    workspace = {
      files: await Promise.all(
        helpers.config.logicPaths
          .concat(helpers.config.documentPaths)
          .map(x => parseFile(x, helpers))
      ),
      flatTokensSchemaVersion: '0.0.1',
    }
  }

  if (!options.output) {
    return workspace
  }

  await helpers.fs.writeFile('docs.json', JSON.stringify(workspace, null, '  '))
}
