import * as path from 'path'
import * as fs from 'fs'

import * as fileSearch from './file-search'

type LonaJSON = {
  ignore: string[]
}

export type Config = {
  version: string
  componentPaths: string[]
  tokenPaths: string[]
  logicPaths: string[]
} & LonaJSON

export const load = async (workspacePath: string): Promise<Config> => {
  const rootDirname = path.dirname(path.dirname(__dirname))
  console.warn(`Running compiler from: ${rootDirname}`)

  const logicLibrariesPath = path.join(rootDirname, 'static/logic')

  const lonaFile = JSON.parse(
    await fs.promises.readFile(path.join(workspacePath, 'lona.json'), 'utf-8')
  ) as LonaJSON

  if (!lonaFile.ignore) {
    lonaFile.ignore = ['node_modules', '.git']
  }

  const componentPaths = fileSearch.sync(
    path.join(workspacePath, '**/*.component'),
    lonaFile
  )
  const tokenPaths = fileSearch.sync(
    path.join(workspacePath, '**/*.md'),
    lonaFile
  )
  const logicPaths = fileSearch.sync(
    path.join(workspacePath, '**/*.logic'),
    lonaFile
  )

  return {
    ...lonaFile,
    componentPaths,
    tokenPaths,
    logicPaths,
    version: require('../../package.json').version,
  }
}
