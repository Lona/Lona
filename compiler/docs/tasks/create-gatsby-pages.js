const path = require('path')

// create components pages
module.exports = ({ actions, graphql }) => {
  const { createPage } = actions

  const docTemplate = path.resolve('src/templates/doc.js')
  const componentTemplate = path.resolve('src/templates/component.js')
  const colorsTemplate = path.resolve('src/templates/colors.js')
  const textStylesTemplate = path.resolve('src/templates/textStyles.js')
  const gradientsTemplate = path.resolve('src/templates/gradients.js')
  const shadowsTemplate = path.resolve('src/templates/shadows.js')
  const defaultHomeTemplate = path.resolve('src/templates/defaultHome.js')

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
            lona {
              hidden
              path
              content
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
              id: node.childLonaComponent.id,
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
