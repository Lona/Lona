import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'
import PropTypes from 'prop-types'
import { HeaderHeight } from './ui-constants'
import { findFirstFile, cleanupLink, sortFiles } from '../../utils'
import HeaderNavigationLink from '../../../lona-workspace/components/HeaderNavigationLink.component'
import WorspaceLogo from '../../../lona-workspace/components/WorkspaceLogo.component'

const Wrapper = styled.header`
  height: ${HeaderHeight};
  padding-right: 65px;
  padding-left: 65px;
`

const InnerWrapper = styled.div`
  display: flex;
  height: 100%;
  position: relative;
  justify-content: space-between;
`

const Logo = styled(Link)`
  text-decoration: none;
`

const NavigationWrapper = styled.nav`
  display: flex;
`

const Navigation = styled.ul`
  display: flex;
`

const NavigationItem = styled(Link)`
  text-transform: capitalize;
  text-decoration: none;
`

const NavigationItemWrapper = styled.li(props => ({
  display: 'flex',
  alignItems: 'center',
  marginLeft: props.first ? '0' : `${65 - 24}px`,
}))

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
            .map((section, i) => {
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
                <NavigationItemWrapper key={section} first={i === 0}>
                  <NavigationItem to={cleanupLink(firstInSection.path)}>
                    <HeaderNavigationLink
                      text={section}
                      selected={
                        location.pathname.indexOf(`/u/${section}`) === 0
                      }
                    />
                  </NavigationItem>
                </NavigationItemWrapper>
              )
            })}
        </Navigation>
      </NavigationWrapper>
    </InnerWrapper>
  </Wrapper>
)

const FilesPropTypes = PropTypes.objectOf(
  PropTypes.shape({
    path: PropTypes.string.isRequired,
    title: PropTypes.string,
    order: PropTypes.number,
    children: (...args) => FilesPropTypes(...args),
  })
)

Header.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  data: PropTypes.shape({
    siteMetadata: PropTypes.shape({
      title: PropTypes.string.isRequired,
      icon: PropTypes.string,
    }).isRequired,
  }).isRequired,
  files: FilesPropTypes.isRequired,
}

export default Header
