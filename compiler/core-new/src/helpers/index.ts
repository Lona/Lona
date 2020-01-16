import * as fs from 'fs'
import * as path from 'path'

import { config as Config } from '../utils'
import { generate as generateEvaluationContext } from './evaluation-context'
import { EvaluationContext } from './logic-evaluate'

export type Helpers = {
  fs: {
    readFile(filePath: string): Promise<string>
    writeFile(filePath: string, data: string): Promise<void>
  }
  config: Config.Config
  evaluationContext: EvaluationContext | void
  reporter: {
    log(...args: any[]): void
    warn(...args: any[]): void
    error(...args: any[]): void
  }
}

export default async (
  workspacePath: string,
  outputPath?: string
): Promise<Helpers> => {
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

  const evaluationContext = await generateEvaluationContext(config, fsWrapper)

  return {
    fs: fsWrapper,
    config,
    evaluationContext,
    reporter: {
      log: console.log.bind(console),
      warn: console.warn.bind(console),
      error: console.error.bind(console),
    },
  }
}
