import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'

import { findFirstFile, cleanupLink } from '../../utils'

const Wrapper = styled.header`
  height: 12rem;
  padding-right: 3.2rem;
  padding-left: 3.2rem;
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
  margin-top: 4rem;
  width: 13rem;
  height: 3.8rem;
  color: #161d25;
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
  max-width: 60rem;
  margin-bottom: 0.8em;
  font-size: 1.4rem;
  font-weight: 500;
  line-height: 1.6;
  text-transform: uppercase;
  letter-spacing: 0.1rem;
  margin-bottom: 0;
  line-height: 1;
  display: block;
  position: relative;
  padding: 5.6rem 1.6rem 1.6rem;
  color: #1a222b;
  transition: color 0.24s cubic-bezier(0.64, 0, 0.35, 1);
  text-decoration: none;
  &:hover {
    color: #202e78;
  }
  &::before {
    content: '';
    position: absolute;
    top: 0;
    right: auto;
    left: auto;
    display: block;
    width: calc(100% - 3.2rem);
    border-top: 0.6rem solid #202e78;
    transform: translateY(${p => (p.selected ? 0 : '-.6rem')});
    transition-property: background-color, transform;
    transition-duration: 0.24s;
    transition-timing-function: cubic-bezier(0.64, 0, 0.35, 1);
  }
`

const Header = ({ data, location, files }) => (
  <Wrapper>
    <InnerWrapper>
      <Logo aria-label="Back to Home" to="/">
        {data.siteMetadata.title}
      </Logo>
      <NavigationWrapper>
        <Navigation aria-hidden="false" aria-label="Primary navigation">
          {Object.keys(files).map(section => {
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
                <NavigationItem
                  to={cleanupLink(firstInSection.path)}
                  selected={location.pathname.indexOf(section) === 1}
                >
                  {section}
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
