import * as fs from 'fs'
import * as path from 'path'

import { config as Config } from '../utils'
import { generate as generateEvaluationContext } from './evaluation-context'
import { EvaluationContext } from './logic-evaluate'

export type Helpers = {
  fs: {
    readFile(filePath: string): Promise<string>
    writeFile(filePath: string, data: string): Promise<void>
    copyDir(dirPath: string, output?: string): Promise<void>
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
  _outputPath?: unknown
): Promise<Helpers> => {
  const outputPath =
    typeof _outputPath === 'string'
      ? _outputPath
      : path.join(process.cwd(), 'lona-generated')
  const fsWrapper = {
    readFile(filePath: string) {
      return fs.promises.readFile(
        path.resolve(workspacePath, filePath),
        'utf-8'
      )
    },
    writeFile(filePath: string, data: string) {
      const resolvedPath = path.resolve(outputPath, filePath)
      fs.mkdirSync(path.dirname(resolvedPath), { recursive: true })
      return fs.promises.writeFile(resolvedPath, data, 'utf-8')
    },
    async copyDir(dirPath: string, output: string = '.') {
      const resolvedPath = path.resolve(workspacePath, dirPath)
      const files = await fs.promises.readdir(resolvedPath)

      Promise.all(
        files.map(async x => {
          if (
            (await fs.promises.stat(path.join(resolvedPath, x))).isDirectory
          ) {
            return
          }

          return fsWrapper.writeFile(
            path.join(dirPath, x),
            await fsWrapper.readFile(path.join(output, x))
          )
        })
      )
    },
  }

  const config = await Config.load(workspacePath, {
    forEvaluation: true,
    fs: fsWrapper,
  })

  return {
    fs: fsWrapper,
    config,
    get evaluationContext() {
      return generateEvaluationContext(config)
    },
    reporter: {
      log: console.log.bind(console),
      warn: console.warn.bind(console),
      error: console.error.bind(console),
    },
  }
}
