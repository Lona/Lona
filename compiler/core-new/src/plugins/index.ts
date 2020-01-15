export type Plugin = {
  parseFile(filePath: string, helpers: any, options: any): Promise<string>
  parseWorkspace(
    workspacePath: string,
    helpers: any,
    options: any
  ): Promise<void>

  /** @deprecated */
  legacyParseFile?: (
    filePath: string,
    fromFormat: string,
    helpers: any,
    options: any
  ) => Promise<string>
}
