import * as fs from 'fs'
import * as path from 'path'

/** Wether the path is a Lona workspace */
export const isWorkspacePath = async (fileOrWorkspacePath: string) => {
  // it's a workspace if it has a lona.json file
  return fs.existsSync(path.join(fileOrWorkspacePath, 'lona.json'))
}
