import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'
import { HeaderHeight } from './ui-constants'
import { findFirstFile, cleanupLink, sortFiles } from '../../utils'
import HeaderNavigationLink from '../../../lona-workspace/components/HeaderNavigationLink.component'
import WorspaceLogo from '../../../lona-workspace/components/WorkspaceLogo.component'

const Wrapper = styled.header`
  height: ${HeaderHeight};
  padding-right: 26px;
  padding-left: 65px;
`

const InnerWrapper = styled.div`
  display: flex;
  height: 100%;
  position: relative;
  max-width: 140rem;
  margin-right: auto;
  margin-left: auto;
  justify-content: space-between;
`

const Logo = styled(Link)`
  text-decoration: none;
`

const NavigationWrapper = styled.nav`
  flex: 0 0 auto;
`

const Navigation = styled.ul`
  float: left;
  margin-right: 1.6rem;
  display: flex;
`

const NavigationItem = styled(Link)`
  text-transform: capitalize;
  text-decoration: none;
`

const Header = ({ data, location, files }) => (
  <Wrapper>
    <InnerWrapper>
      <Logo aria-label="Back to Home" to="/">
        <WorspaceLogo
          text={data.siteMetadata.title}
          image={data.siteMetadata.icon}
        />
      </Logo>
      <NavigationWrapper>
        <Navigation aria-hidden="false" aria-label="Secondary navigation">
          {Object.keys(files)
            .sort(sortFiles(files))
            .map(section => {
              if (!files[section]) {
                return null
              }

              let firstInSection
              if (files[section].title) {
                firstInSection = files[section]
              } else {
                const filesInSection = files[section].children
                firstInSection = findFirstFile(filesInSection) || {}
              }

              return (
                <li key={section}>
                  <NavigationItem to={cleanupLink(firstInSection.path)}>
                    <HeaderNavigationLink
                      text={section}
                      selected={location.pathname.indexOf(section) === 1}
                    />
                  </NavigationItem>
                </li>
              )
            })}
        </Navigation>
      </NavigationWrapper>
    </InnerWrapper>
  </Wrapper>
)

export default Header
