declare module '@mdx-js/mdx' {
  type RemarkPlugin<T> = () => (ast: T) => T
  type RehypePlugin<T> = () => (ast: T) => T
  export const sync: (
    mdx: string,
    options?: {
      skipExport?: boolean
      filepath?: string
      remarkPlugins?: (RemarkPlugin<any> | [RemarkPlugin<any>, any])[]
      rehypePlugins?: (RehypePlugin<any> | [RehypePlugin<any>, any])[]
    }
  ) => string
}
