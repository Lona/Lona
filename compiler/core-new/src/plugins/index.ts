import { Helpers } from '../helpers'

export type Plugin = {
  parseFile(filePath: string, helpers: Helpers, options: any): Promise<string>
  parseWorkspace(
    workspacePath: string,
    helpers: Helpers,
    options: any
  ): Promise<void>
}
