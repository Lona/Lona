export function capitalise(string) {
  return string.charAt(0).toUpperCase() + string.slice(1)
}

export function cleanupFiles(files) {
  const cleanedUpFiles = files.map(f => {
    if (!f.node.lona) {
      return undefined
    }
    if (f.node.childMdx) {
      const { frontmatter } = f.node.childMdx
      frontmatter.title = f.node.lona.title
      frontmatter.sections = f.node.lona.sections || []
      frontmatter.path = f.node.lona.path || ''
      frontmatter.subtitles = f.node.childMdx.headings.map(h => h.value)
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
          order: s === 'foundation' ? 0 : 999,
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
    firstFile.sections ||
    !Object.keys(firstFile.children).length
  ) {
    return firstFile
  }

  return findFirstFile(firstFile.children)
}

export function findFirstLink(file) {
  // if there are sections, it means that it's a real file
  return file.sections ? file.path : (findFirstFile(file.children) || {}).path
}

export function cleanupLink(link = '#') {
  return link.replace(/^\/\//, '/')
}
