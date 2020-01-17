import * as serialization from '@lona/serialization'

export const findChildPages = (root: {
  children: serialization.MDXAST.Content[]
}): string[] => {
  return root.children
    .map(child => {
      if (child.type === 'page') {
        return child.data.url
      }
    })
    .filter(x => !!x)
}
