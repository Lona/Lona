import * as Glob from 'glob'
import * as path from 'path'

/** search for files respecting the glob patter in the workspace.
 * @returns an array of relative paths
 */
export const sync = (
  workspacePath: string,
  glob: string,
  options: { ignore?: string[] } = {}
) => {
  return Glob.sync(path.join(workspacePath, glob), options).map(x =>
    path.relative(workspacePath, x)
  )
}
