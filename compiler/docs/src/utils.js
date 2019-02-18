export function cleanupFiles(files) {
  const cleanedUpFiles = files.map(f => {
    if (!f.node.lona) {
      return undefined
    }
    if (f.node.childMarkdownRemark) {
      const { frontmatter } = f.node.childMarkdownRemark
      frontmatter.title = f.node.lona.title
      frontmatter.sections = f.node.lona.sections || []
      frontmatter.path = f.node.lona.path || ''
      frontmatter.subtitles = f.node.childMarkdownRemark.headings.map(
        h => h.value
      )
      frontmatter.component = true
      return frontmatter
    }

    return f.node.lona
  })

  return cleanedUpFiles.reduce((prev, f) => {
    if (!f) {
      return prev
    }

    let currentPath = ''
    let currentPrev = prev
    f.sections.forEach((s, i, a) => {
      currentPath = `${currentPath}/${s}`
      if (!currentPrev[s]) {
        currentPrev[s] = {
          path: currentPath,
          order: s === 'tokens' ? 0 : 999,
          children: {},
        }
      }
      if (i < a.length - 1) {
        currentPrev = currentPrev[s].children
      } else {
        currentPrev = currentPrev[s]
      }
    })
    Object.assign(currentPrev, f)
    return prev
  }, {})
}

export function findFirstFile(files = {}) {
  const firstFile =
    files[Object.keys(files).sort((a, b) => files[a].order - files[b].order)[0]]

  if (
    !firstFile ||
    firstFile.component ||
    !Object.keys(firstFile.children).length
  ) {
    return firstFile
  }

  return findFirstFile(firstFile.children)
}

export function cleanupLink(link = '#') {
  return link.replace(/^\/\//, '/')
}
