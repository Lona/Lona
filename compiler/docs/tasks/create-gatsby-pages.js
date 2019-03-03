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
            path: node.lona.path,
            component: docTemplate,
            context: {
              id: node.childMdx.id,
            },
          })

          if (node.lona.path === '/') {
            didCreateHome = true
          }

          return
        }

        if (node.type === 'Colors') {
          createPage({
            path: node.lona.path,
            component: colorsTemplate,
            context: {
              colors: node.lona.content,
            },
          })
        }

        if (node.type === 'TextStyles') {
          createPage({
            path: node.lona.path,
            component: textStylesTemplate,
            context: {
              textStyles: node.lona.content,
            },
          })
        }

        if (node.type === 'Gradients') {
          createPage({
            path: node.lona.path,
            component: gradientsTemplate,
            context: {
              gradients: node.lona.content,
            },
          })
        }

        if (node.type === 'Shadows') {
          createPage({
            path: node.lona.path,
            component: shadowsTemplate,
            context: {
              shadows: node.lona.content,
            },
          })
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
