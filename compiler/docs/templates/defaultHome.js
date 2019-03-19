import React from 'react'
import { graphql } from 'gatsby'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'

export default function Template({ data, location }) {
  return (
    <Layout location={location}>
      <ComponentTitle
        name={data.site.siteMetadata.title}
        intro="To personnalize this page, create a REAME.md file at the root of your Lona workspace."
      />
    </Layout>
  )
}

export const query = graphql`
  query DefaultHomeSiteMetadata {
    site {
      siteMetadata {
        title
        icon
      }
    }
  }
`
