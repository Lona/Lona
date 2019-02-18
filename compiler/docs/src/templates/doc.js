import { graphql } from 'gatsby'
import React from 'react'
import Layout from '../components/Layout'

export default function Template({ data, location }) {
  const { markdownRemark } = data
  const { /* frontmatter = {}, */ html } = markdownRemark
  return (
    <Layout location={location}>
      <div dangerouslySetInnerHTML={{ __html: html }} />
    </Layout>
  )
}

export const query = graphql`
  query DocById($id: String!) {
    markdownRemark(id: { eq: $id }) {
      html
    }
  }
`
