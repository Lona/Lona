import { Helpers } from '../helpers'

export type Plugin = {
  parseFile(
    filePath: string,
    helpers: Helpers,
    options: {
      [argName: string]: unknown
    }
  ): Promise<string>
  parseWorkspace(
    workspacePath: string,
    helpers: Helpers,
    options: {
      [argName: string]: unknown
    }
  ): Promise<void>
}
