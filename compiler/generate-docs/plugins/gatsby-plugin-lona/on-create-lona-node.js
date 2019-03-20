const { digest } = require('./create-file-node')

module.exports = function onCreateNode({
  node,
  actions,
  createNodeId,
  reporter,
}) {
  const { createNode, createParentChildLink } = actions

  // We only care about lona component node.
  if (node.type !== 'Component') {
    return
  }

  const { content } = node.internal

  try {
    const data = JSON.parse(content)

    const lonaDescriptionNode = {
      id: createNodeId(`${node.id} >>> LonaComponentDescription`),
      children: [],
      parent: node.id,
      internal: {
        content: (data.metadata || {}).description || '',
        type: `LonaComponentDescription`,
        mediaType: 'text/x-markdown',
      },
    }

    const lonaNode = {
      id: createNodeId(`${node.id} >>> LonaComponent`),
      children: [],
      parent: node.id,
      internal: {
        content,
        type: `LonaComponent`,
      },
    }

    lonaNode.examples = (data.examples || []).map(example => {
      example.params = JSON.stringify(example.params)
      return example
    })
    lonaNode.params = (data.params || []).map(param => {
      param.defaultValue = param.defaultValue
        ? JSON.stringify(param.defaultValue)
        : null
      param.description = param.description || ''
      return param
    })

    // Add path to the component file path
    lonaNode.componentPath = node.relativePath

    lonaNode.internal.contentDigest = digest(JSON.stringify(lonaNode))

    lonaDescriptionNode.internal.contentDigest = digest(
      JSON.stringify(lonaDescriptionNode)
    )

    createNode(lonaNode)
    createParentChildLink({ parent: node, child: lonaNode })
    createNode(lonaDescriptionNode)
    createParentChildLink({ parent: node, child: lonaDescriptionNode })
  } catch (err) {
    reporter.panicOnBuild(
      `Error processing Lona Component ${
        node.absolutePath ? `file ${node.absolutePath}` : `in node ${node.id}`
      }:\n
      ${err.message}`
    )
  }
}
