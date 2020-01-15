import * as Glob from 'glob'

export const sync = (glob: string, options: { ignore?: string[] } = {}) => {
  return Glob.sync(glob, options)
}
