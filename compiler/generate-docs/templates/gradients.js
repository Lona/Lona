import React from 'react'
import PropTypes from 'prop-types'
import Layout from '../src/components/Layout'

export default function Template({ pageContext: { gradients }, location }) {
  return (
    <Layout location={location}>
      <pre>{JSON.stringify(gradients, null, '  ')}</pre>
    </Layout>
  )
}

Template.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  pageContext: PropTypes.shape({
    pathInWorkspace: PropTypes.string.isRequired,
    gradients: PropTypes.shape({
      description: PropTypes.string,
      gradients: PropTypes.arrayOf(
        PropTypes.shape({
          id: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
          value: PropTypes.string.isRequired,
        }).isRequired
      ),
    }).isRequired,
  }).isRequired,
}
