const chokidar = require('chokidar')

const { createId, createFileNode } = require(`./create-file-node`)

module.exports = function sourceNodes(
  { actions, getNode, reporter },
  pluginOptions
) {
  const { createNode, deleteNode } = actions

  let ready = false

  const createAndProcessNode = path =>
    createFileNode(path, pluginOptions)
      .then(createNode)
      .catch(err => reporter.error(err))

  // For every path that is reported before the 'ready' event, we throw them
  // into a queue and then flush the queue when 'ready' event arrives.
  // After 'ready', we handle the 'add' event without putting it into a queue.
  let pathQueue = []
  const flushPathQueue = () => {
    const queue = pathQueue.slice()
    pathQueue = []
    return Promise.all(queue.map(createAndProcessNode))
  }

  const watcher = chokidar.watch(pluginOptions.pattern, {
    ignored: pluginOptions.ignored,
    cwd: pluginOptions.cwd,
  })

  watcher.on(`add`, path => {
    if (ready) {
      reporter.info(`added file at ${path}`)
      createAndProcessNode(path)
    } else {
      pathQueue.push(path)
    }
  })

  watcher.on(`change`, path => {
    reporter.info(`changed file at ${path}`)
    createAndProcessNode(path)
  })

  watcher.on(`unlink`, path => {
    reporter.info(`file deleted at ${path}`)
    const node = getNode(createId(path))
    deleteNode(node.id, node)

    // Also delete nodes for the file's transformed children nodes.
    node.children.forEach(childId => deleteNode(childId, getNode(childId)))
  })

  watcher.on(`addDir`, path => {
    if (ready) {
      reporter.info(`added directory at ${path}`)
      createAndProcessNode(path)
    } else {
      pathQueue.push(path)
    }
  })

  watcher.on(`unlinkDir`, path => {
    reporter.info(`directory deleted at ${path}`)
    const node = getNode(createId(path))
    deleteNode(node.id, node)
  })

  return new Promise((resolve, reject) => {
    watcher.on(`ready`, () => {
      if (ready) return

      ready = true
      flushPathQueue().then(resolve, reject)
    })
  })
}
