import * as fs from 'fs'
import * as path from 'path'
import { LogicAST } from '@lona/serialization'

import { config as Config } from '../utils'
import { generate as generateEvaluationContext } from './evaluation-context'
import { EvaluationContext } from './logic-evaluate'
import { HandlePreludeFactory } from './hardcoded-mapping'

export { HardcodedMap } from './hardcoded-mapping'
export { EvaluationContext } from './logic-evaluate'

export type Helpers = {
  fs: {
    readFile(filePath: string): Promise<string>
    writeFile(filePath: string, data: string): Promise<void>
    copyDir(dirPath: string, output?: string): Promise<void>
  }
  config: Config.Config
  evaluationContext: EvaluationContext | void
  HandlePreludeFactory: typeof HandlePreludeFactory
  reporter: {
    log(...args: any[]): void
    warn(...args: any[]): void
    error(...args: any[]): void
  }
}

export type PreludeFlags = {
  [id: string]:
    | LogicAST.RecordDeclaration
    | LogicAST.EnumerationDeclaration
    | LogicAST.NamespaceDeclaration
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

      await Promise.all(
        files.map(async x => {
          if (
            (await fs.promises.stat(path.join(resolvedPath, x))).isDirectory()
          ) {
            return
          }

          return fsWrapper.writeFile(
            path.join(output, x),
            await fsWrapper.readFile(path.join(dirPath, x))
          )
        })
      )
    },
  }

  const config = await Config.load(workspacePath, {
    forEvaluation: true,
    fs: fsWrapper,
  })

  let cachedEvaluationContext: EvaluationContext | void

  return {
    fs: fsWrapper,
    config,
    get evaluationContext() {
      if (cachedEvaluationContext) {
        return cachedEvaluationContext
      }
      cachedEvaluationContext = generateEvaluationContext(config)
      return cachedEvaluationContext
    },
    HandlePreludeFactory,
    reporter: {
      log: console.log.bind(console),
      warn: console.warn.bind(console),
      error: console.error.bind(console),
    },
  }
}
