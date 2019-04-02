/* globals ast */
const traverse = require('@babel/traverse').default

function find(path, type, predicate = x => !!x) {
  const results = []

  traverse(
    ast,
    {
      [type](_path) {
        if (!predicate(_path)) return
        results.push(_path)
      },
    },
    path
  )

  return results
}

function findNested(path, entries = []) {
  if (entries.length === 0) return []

  return entries.reduce(
    (paths, entry) => {
      const { type, predicate } = entry
      const results = paths.map(c => this.find(c, type, predicate))
      return [].concat(...results)
    },
    [path]
  )
}

module.exports = { find, findNested }
