import { graphql } from 'gatsby'
import React from 'react'
import PropTypes from 'prop-types'
import { MDXRenderer } from 'gatsby-mdx'
import Layout from '../src/components/Layout'

export default function Template({ data, location }) {
  return (
    <Layout location={location}>
      <MDXRenderer>{data.mdx.code.body}</MDXRenderer>
    </Layout>
  )
}

Template.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  data: PropTypes.shape({
    mdx: PropTypes.shape({
      frontmatter: PropTypes.shape({
        intro: PropTypes.string,
        overrideLayout: PropTypes.bool,
      }),
      code: PropTypes.shape({
        body: PropTypes.string.isRequired,
      }).isRequired,
    }).isRequired,
  }).isRequired,
}

export const query = graphql`
  query DocById($id: String!) {
    mdx(id: { eq: $id }) {
      code {
        body
      }
    }
  }
`
