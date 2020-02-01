import * as path from 'path'
import * as fs from 'fs'

import { Plugin } from './plugins'
import { findPlugin, isWorkspacePath, config, findWorkspace } from './utils'
import Helpers from './helpers'

export const getConfig = async (workspacePath: string) => {
  const resolvedPath = path.resolve(workspacePath)

  if (!(await isWorkspacePath(resolvedPath))) {
    throw new Error(
      'The path provided is not a Lona Workspace. A workspace must contain a `lona.json` file.'
    )
  }

  return await config.load(resolvedPath)
}

export const convertFile = async (
  filePath: string,
  formatter: Plugin,
  options?: {
    [argName: string]: unknown
  }
) => {
  const workspace = await findWorkspace(filePath)
  if (!workspace) {
    throw new Error(
      'The path provided is not part of a Lona Workspace. A workspace must contain a `lona.json` file.'
    )
  }

  return formatter.parseFile(
    path.relative(workspace, filePath),
    await Helpers(workspace),
    options || {}
  )
}

export const convertWorkspace = async (
  workspacePath: string,
  outputPath: unknown,
  formatter: Plugin,
  options?: {
    [argName: string]: unknown
  }
) => {
  return formatter.parseWorkspace(
    workspacePath,
    await Helpers(workspacePath, outputPath),
    options || {}
  )
}

export const convert = async (
  fileOrWorkspacePath: string,
  format: string,
  options?: {
    [argName: string]: unknown
  }
) => {
  const resolvedPath = path.resolve(fileOrWorkspacePath)
  const formatter = findPlugin(format)

  if (await isWorkspacePath(resolvedPath)) {
    return convertWorkspace(
      resolvedPath,
      (options || {}).output,
      formatter,
      options
    )
  } else if (!fs.statSync(resolvedPath).isDirectory) {
    return convertFile(resolvedPath, formatter, options)
  } else {
    throw new Error(
      'The path provided is not a Lona Workspace. A workspace must contain a `lona.json` file.'
    )
  }
}
