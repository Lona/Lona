const path = require('path')

// create components pages
module.exports = ({ actions, graphql }) => {
  const { createPage } = actions

  const docTemplate = path.resolve('templates/doc.js')
  const componentTemplate = path.resolve('templates/component.js')
  const colorsTemplate = path.resolve('templates/colors.js')
  const textStylesTemplate = path.resolve('templates/textStyles.js')
  const gradientsTemplate = path.resolve('templates/gradients.js')
  const shadowsTemplate = path.resolve('templates/shadows.js')
  const assetsTemplate = path.resolve('templates/assets.js')
  const defaultHomeTemplate = path.resolve('templates/defaultHome.js')

  let didCreateHome = false

  return graphql(`
    {
      allLonaFile {
        edges {
          node {
            type
            childMdx {
              id
              frontmatter {
                hidden
              }
            }
            childLonaComponent {
              id
            }
            childLonaComponentDescription {
              childMdx {
                id
              }
            }
            lona {
              hidden
              path
              pathInWorkspace
              content
              title
            }
          }
        }
      }
    }
  `)
    .then(result => {
      if (result.errors) {
        throw result.errors[0]
      }

      result.data.allLonaFile.edges.forEach(({ node }) => {
        if (node.type === 'Component') {
          if (node.lona.hidden) {
            return
          }

          createPage({
            path: node.lona.path,
            component: componentTemplate,
            context: {
              title: node.lona.title,
              id: node.childLonaComponent.id,
              descriptionId: node.childLonaComponentDescription.childMdx.id,
            },
          })
          return
        }

        if (node.type === 'LonaDocument') {
          if (node.lona.hidden) {
            return
          }

          createPage({
            path: node.lona.path === '/u/' ? '/' : node.lona.path,
            component: docTemplate,
            context: {
              id: node.childMdx.id,
            },
          })

          if (node.lona.path === '/u/') {
            didCreateHome = true
          }

          return
        }

        if (node.type === 'Colors') {
          createPage({
            path: node.lona.path,
            component: colorsTemplate,
            context: {
              pathInWorkspace: node.lona.pathInWorkspace,
              colors: JSON.parse(node.lona.content),
            },
          })
        }

        if (node.type === 'TextStyles') {
          createPage({
            path: node.lona.path,
            component: textStylesTemplate,
            context: {
              pathInWorkspace: node.lona.pathInWorkspace,
              textStyles: JSON.parse(node.lona.content),
            },
          })
        }

        if (node.type === 'Gradients') {
          createPage({
            path: node.lona.path,
            component: gradientsTemplate,
            context: {
              pathInWorkspace: node.lona.pathInWorkspace,
              gradients: JSON.parse(node.lona.content),
            },
          })
        }

        if (node.type === 'Shadows') {
          createPage({
            path: node.lona.path,
            component: shadowsTemplate,
            context: {
              pathInWorkspace: node.lona.pathInWorkspace,
              shadows: JSON.parse(node.lona.content),
            },
          })
        }

        if (node.type === 'LonaArtifacts') {
          const artifacts = JSON.parse(node.lona.content)
          if (artifacts.length) {
            createPage({
              path: node.lona.path,
              component: assetsTemplate,
              context: {
                artifacts: JSON.parse(node.lona.content),
              },
            })
          }
        }
      })
    })
    .then(() => {
      if (!didCreateHome) {
        createPage({
          path: '/',
          component: defaultHomeTemplate,
          context: {},
        })
      }
    })
}
