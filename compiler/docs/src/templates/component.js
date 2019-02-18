import { graphql } from 'gatsby'
import React from 'react'
import Layout from '../components/Layout'
import Examples from '../components/Examples'

export default function Template({ data, location }) {
  // this will get replaced by the webpack context plugin
  // it is needed in order to map all the components

  const Component = require(`lona-workspace/${
    data.lonaComponent.componentPath
  }`).default

  return (
    <Layout location={location}>
      <Examples
        scope={{ Component }}
        examples={data.lonaComponent.examples.map(example => {
          const params = JSON.parse(example.params)
          return {
            name: example.name,
            description: '',
            text: `<Component ${Object.keys(params)
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
  query ComponentById($id: String!) {
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
  }
`
