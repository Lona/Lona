/* eslint-disable import/no-unresolved */
import React from 'react'
import { Link, graphql } from 'gatsby'
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
