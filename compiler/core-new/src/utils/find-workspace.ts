import * as path from 'path'
import { isWorkspacePath } from './is-workspace-path'

export const findWorkspace = async (
  start: string
): Promise<string | undefined> => {
  if (await isWorkspacePath(start)) {
    return start
  }

  const parent = path.dirname(start)

  if (!parent || parent === '/' || parent === '.') {
    return undefined
  }

  return findWorkspace(parent)
}
