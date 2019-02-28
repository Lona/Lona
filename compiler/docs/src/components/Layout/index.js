import React from 'react'
import { graphql, StaticQuery } from 'gatsby'
import PropTypes from 'prop-types'
import Helmet from 'react-helmet'
import styled from 'styled-components'

import { cleanupFiles } from '../../utils'

import Header from './Header'
import Sidebar from './Sidebar'
import './index.css'
import sectionCSS from './section-css'

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
  padding-right: 3.2rem;
  padding-left: 3.2rem;
  max-width: 140rem;
  margin-right: auto;
  margin-left: auto;
  display: flex;
  margin-bottom: 50px;
`

const Section = styled.section`
  position: relative;
  z-index: 800;
  flex: 1 1 auto;
  border-radius: 0.6rem;
  box-shadow: 0 1.2rem 3.6rem rgba(0, 0, 0, 0.2);
  min-width: 0;
  max-width: calc(100vw - 404px);
  width: 1040px;
  background-color: #fff;
  padding: 4rem;
  ${sectionCSS};
`

const Layout = ({ children, location }) => (
  <StaticQuery
    query={graphql`
      query LayoutQuery {
        site {
          siteMetadata {
            title
          }
        }
        allLonaFile {
          edges {
            node {
              childMdx {
                frontmatter {
                  title
                  showSubtitlesInSidebar
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
                subtitles
                showSubtitlesInSidebar
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
  location: PropTypes.any.isRequired,
}

export default Layout
