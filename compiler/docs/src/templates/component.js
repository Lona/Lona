import { graphql } from 'gatsby'
import React from 'react'
import { MDXRenderer } from 'gatsby-mdx'
import Layout from '../components/Layout'
import Examples from '../components/Examples'
import { capitalise } from '../utils'

export default function Template({ data, pageContext, location }) {
  // this will get replaced by the webpack context plugin
  // it is needed in order to map all the components
  const Component = require(`lona-workspace/${
    data.lonaComponent.componentPath
  }`).default

  // CamelCase title
  const componentName = pageContext.title
    .split(' ')
    .map(capitalise)
    .join('')

  if (data.mdx.frontmatter.overrideLayout) {
    return (
      <MDXRenderer
        scope={{
          Component,
          Examples,
          Layout,
        }}
      >
        {data.mdx.code.body}
      </MDXRenderer>
    )
  }

  return (
    <Layout location={location}>
      <h1>{pageContext.title}</h1>
      {data.mdx.frontmatter.intro ? (
        <div>{data.mdx.frontmatter.intro}</div>
      ) : null}
      <MDXRenderer
        scope={{
          Component,
          Examples,
        }}
      >
        {data.mdx.code.body}
      </MDXRenderer>
      <Examples
        scope={{ [componentName]: Component }}
        examples={data.lonaComponent.examples.map(example => {
          const params = JSON.parse(example.params)
          return {
            name: example.name,
            description: '',
            text: `<${componentName} ${Object.keys(params)
              .map(
                propName => `${propName}={${JSON.stringify(params[propName])}}`
              )
              .join(' ')}/>`,
          }
        })}
      />
    </Layout>
  )
}

export const query = graphql`
  query ComponentById($id: String!, $descriptionId: String!) {
    lonaComponent(id: { eq: $id }) {
      examples {
        id
        name
        params
      }
      params {
        name
        type
      }
      componentPath
    }
    mdx(id: { eq: $descriptionId }) {
      frontmatter {
        intro
        overrideLayout
      }
      code {
        body
      }
    }
  }
`
