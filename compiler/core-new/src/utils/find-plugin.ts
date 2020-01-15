import { Plugin } from '../plugins'

/** Look for a plugin in
 * - node_modules/@lona/compiler-FORMAT
 * - node_modules/lona-compiler-FORMAT
 * - ../plugins/FORMAT
 */
export const findPlugin = (format: string): Plugin => {
  try {
    return require(`@lona/compiler-${format}`)
  } catch (err) {
    try {
      return require(`lona-compiler-${format}`)
    } catch (err) {
      try {
        return require(`../plugins/${format}`)
      } catch (err) {
        throw new Error(`Could not find plugin ${format}`)
      }
    }
  }
}
