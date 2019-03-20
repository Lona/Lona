import React from 'react'
import { graphql, StaticQuery } from 'gatsby'
import PropTypes from 'prop-types'
import Helmet from 'react-helmet'
import styled from 'styled-components'

import { cleanupFiles } from '../../utils'

import Header from './Header'
import Sidebar from './Sidebar'
import './index.css'
import Section from './Section'

const Page = styled.div`
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  > * {
    flex: none;
  }
`

const SkipLink = styled.a`
  position: absolute;
  top: 0;
  clip: rect(1px, 1px, 1px, 1px);
  overflow: hidden;
  height: 1px;
  width: 1px;
  padding: 0;
  border: 0;
`

const Content = styled.main`
  display: flex;
`

const Layout = ({ children, location }) => (
  <StaticQuery
    query={graphql`
      query LayoutQuery {
        site {
          siteMetadata {
            title
            icon
          }
        }
        allLonaFile {
          edges {
            node {
              childMdx {
                frontmatter {
                  title
                  icon
                  order
                  hidden
                }
                headings(depth: h2) {
                  value
                }
              }
              lona {
                title
                icon
                order
                hidden
                path
                sections
              }
            }
          }
        }
      }
    `}
    render={data => {
      const files = cleanupFiles(data.allLonaFile.edges)
      return (
        <Page>
          <SkipLink href="#MainContent">Skip to main content</SkipLink>
          <Helmet
            title={data.site.siteMetadata.title || 'Design System'}
            meta={[
              {
                name: 'description',
                content: data.site.siteMetadata.title || 'Design System',
              },
              {
                name: 'keywords',
                content: (
                  data.site.siteMetadata.keywords || ['design', 'system']
                ).join(', '),
              },
            ]}
          />
          <Header data={data.site} files={files} location={location} />
          <Content>
            <Sidebar files={files} location={location} />
            <Section>{children}</Section>
          </Content>
        </Page>
      )
    }}
  />
)

Layout.propTypes = {
  children: PropTypes.node.isRequired,
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
}

export default Layout
