const chokidar = require('chokidar')
const Path = require('path')

const {
  createId,
  createFileNode,
  createArtefactsNode,
} = require(`./create-file-node`)
const generateArtefacts = require('./generate-artefacts')

const defaultIgnoredPatterns = [
  '**/*.un~',
  '**/.gitignore',
  '**/.npmignore',
  '**/.babelrc',
  '**/yarn.lock',
  '**/package-lock.json',
  '**/node_modules',
  '../**/dist/**',
  '**/__temp-docs', // created on the CI
  '**/__branch-docs', // created on the CI
  '**/__commit-docs', // created on the CI
]

const SOURCES = [
  {
    pattern: '**/*.md',
    type: 'LonaDocument',
  },
  {
    pattern: '**/*.mdx',
    type: 'LonaDocument',
  },
  {
    pattern: '**/*.component',
    type: 'Component',
  },
  {
    pattern: '**/colors.json',
    type: 'Colors',
  },
  {
    pattern: '**/textStyles.json',
    type: 'TextStyles',
  },
  {
    pattern: '**/shadows.json',
    type: 'Shadows',
  },
  {
    pattern: '**/gradients.json',
    type: 'Gradients',
  },
]

const DECLARE_ALL_FRONTMATTER = Path.join(
  __dirname,
  'utils/declare_all_frontmatter.md'
)

module.exports = function sourceNodes(
  { actions, getNode, reporter, cache },
  pluginOptions
) {
  if (!pluginOptions.cwd) {
    throw new Error('missing cwd in the plugin options')
  }

  const { createNode, deleteNode } = actions

  let ready = false

  const relativePathDeclareAll = Path.relative(
    pluginOptions.cwd,
    DECLARE_ALL_FRONTMATTER
  )

  const createAndProcessNode = path => {
    let type
    if (path === relativePathDeclareAll) {
      type = 'LonaDocumentOnlyThereToProvideAllTheFrontMatterFields'
    } else if (Path.extname(path) === '.md' || Path.extname(path) === '.mdx') {
      type = 'LonaDocument'
    } else if (Path.extname(path) === '.component') {
      type = 'Component'
    } else if (Path.basename(path) === 'colors.json') {
      type = 'Colors'
    } else if (Path.basename(path) === 'textStyles.json') {
      type = 'TextStyles'
    } else if (Path.basename(path) === 'shadows.json') {
      type = 'Shadows'
    } else if (Path.basename(path) === 'gradients.json') {
      type = 'Gradients'
    }
    return createFileNode(path, { type, ...pluginOptions })
      .then(createNode)
      .catch(err => reporter.error(err))
  }

  if (pluginOptions.artefacts && pluginOptions.artefacts.length) {
    createNode(
      createArtefactsNode(pluginOptions.artefacts, {
        type: 'LonaArtefacts',
        cwd: pluginOptions.cwd,
      })
    )
  }

  // For every path that is reported before the 'ready' event, we throw them
  // into a queue and then flush the queue when 'ready' event arrives.
  // After 'ready', we handle the 'add' event without putting it into a queue.
  let pathQueue = [relativePathDeclareAll]

  const flushPathQueue = () => {
    const queue = pathQueue.slice()
    pathQueue = []
    return Promise.all(queue.map(createAndProcessNode))
  }

  const watcher = chokidar.watch(SOURCES.map(s => s.pattern), {
    ignored: pluginOptions.ignored || defaultIgnoredPatterns,
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
    deleteNode(node)

    // Also delete nodes for the file's transformed children nodes.
    node.children.forEach(childId => deleteNode(getNode(childId)))
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
    deleteNode(node)
  })

  return Promise.all([
    pluginOptions.artefacts && pluginOptions.artefacts.length
      ? generateArtefacts({
          cache,
          cwd: pluginOptions.cwd,
          artefacts: pluginOptions.artefacts,
        }).then(() =>
          createNode(
            createArtefactsNode(pluginOptions.artefacts, {
              type: 'LonaArtefacts',
              cwd: pluginOptions.cwd,
            })
          )
        )
      : Promise.resolve(),
    new Promise((resolve, reject) => {
      watcher.on(`ready`, () => {
        if (ready) return

        ready = true
        flushPathQueue().then(resolve, reject)
      })
    }),
  ])
}
