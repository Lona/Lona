import React from 'react'
import { graphql } from 'gatsby'
import PropTypes from 'prop-types'
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

Template.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  data: PropTypes.shape({
    site: PropTypes.shape({
      siteMetadata: PropTypes.shape({
        title: PropTypes.string.isRequired,
        icon: PropTypes.string,
      }).isRequired,
    }).isRequired,
  }).isRequired,
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
