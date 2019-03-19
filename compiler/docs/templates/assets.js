/* eslint-disable import/no-unresolved */
import React from 'react'
import PropTypes from 'prop-types'
import { graphql } from 'gatsby'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'
import H3 from '../lona-workspace/components/markdown/H3.component'

export default function Template({
  data,
  pageContext: { artefacts },
  location,
}) {
  return (
    <Layout location={location}>
      <ComponentTitle name="Assets" intro="" />
      {artefacts.map(artefact => {
        if (artefact === 'sketch') {
          return (
            <div key={artefact}>
              <H3 text="Sketch Library" />
              <p>
                <a
                  href={require('gatsby-cache-dir/caches/gatsby-plugin-lona/library.sketch')}
                >
                  Download the Sketch Library
                </a>{' '}
                to start designing with {data.site.siteMetadata.title}
              </p>
              <p>
                To learn more about using Sketch, we recommend visiting the{' '}
                <a
                  href="https://sketch.com"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Sketch
                </a>{' '}
                website and its Support section.
              </p>
            </div>
          )
        }
        return null
      })}
    </Layout>
  )
}

Template.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  pageContext: PropTypes.shape({
    artefacts: PropTypes.arrayOf(PropTypes.string).isRequired,
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
  query SiteMetadata {
    site {
      siteMetadata {
        title
        icon
      }
    }
  }
`
