import * as fs from 'fs'
import * as path from 'path'

import { config as Config } from '../utils'
import { generate as generateEvaluationContext } from './evaluation-context'

export default async (workspacePath: string, outputPath?: string) => {
  const config = await Config.load(workspacePath)

  const fsWrapper = {
    readFile(filePath: string) {
      return fs.promises.readFile(
        path.resolve(workspacePath, filePath),
        'utf-8'
      )
    },
    writeFile(filePath: string, data: string) {
      return fs.promises.writeFile(
        path.resolve(outputPath, filePath),
        data,
        'utf-8'
      )
    },
  }

  const evaluationContext = generateEvaluationContext(config, fsWrapper)

  return {
    fs: fsWrapper,
    config,
  }
}
