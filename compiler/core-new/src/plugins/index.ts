import { Helpers } from '../helpers'

export type Plugin = {
  parseFile(
    filePath: string,
    helpers: Helpers,
    options: {
      [argName: string]: unknown
    }
  ): Promise<any>
  parseWorkspace(
    workspacePath: string,
    helpers: Helpers,
    options: {
      [argName: string]: unknown
    }
  ): Promise<any>
}
