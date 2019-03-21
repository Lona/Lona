import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'
import PropTypes from 'prop-types'
import { HeaderHeight } from './ui-constants'
import {
  findFirstFile,
  findFirstLink,
  cleanupLink,
  capitalise,
  sortFiles,
} from '../../utils'
import SectionHeader from '../../../lona-workspace/components/SectionHeader.component'
import SubsectionHeader from '../../../lona-workspace/components/SubsectionHeader.component'
import SubSubsectionHeader from '../../../lona-workspace/components/SubSubsectionHeader.component'

const Wrapper = styled.nav`
  flex: 0 0 320px;
  margin-top: 0;
  width: 320px;
`

const InnerWrapper = styled.div`
  padding-left: 66px;
  height: calc(100vh - ${HeaderHeight});
  overflow-y: auto;
`

const NavigationWrapper = styled.nav`
  flex: 0 0 auto;
`

const ItemWrapper = styled.li``

const NavigationItem = styled(Link)`
  text-decoration: none;
`

const Section = styled(ItemWrapper)`
  padding: 28px 0;
`

const SubTitles = styled.ul`
  padding-left: 10px;
`

function pathToTitle(path) {
  const parts = path.split('/')
  return capitalise(parts[parts.length - 1])
}

function shouldPrintTitle(element) {
  return !element.hidden || Object.keys(element.children).length
}

function isSelected(location, section) {
  return (
    location.pathname.indexOf(section.path) === 0 ||
    location.pathname.indexOf(section.path) === 2 // if it /u
  )
}

const SubNavigation = ({ subtitle, location }) => {
  if (!shouldPrintTitle(subtitle)) {
    return null
  }
  const subTitleLink = findFirstLink(subtitle)
  return (
    <li>
      <NavigationItem to={cleanupLink(subTitleLink)}>
        <SubSubsectionHeader
          text={capitalise(subtitle.title)}
          selected={isSelected(location, subtitle)}
        />
      </NavigationItem>
    </li>
  )
}

const Siderbar = ({ location, files }) => {
  const [, selectedSectionOrU, selectedSection] = location.pathname.split('/')

  const sections = Object.keys(files)
    .filter(section => files[section])
    .sort(sortFiles(files))
  return (
    <Wrapper>
      <InnerWrapper>
        <NavigationWrapper ariaLabel="Primary navigation">
          <ul>
            {sections.map(section => {
              const filesInSection = files[section].children || {}

              let firstInSection
              if (files[section].title) {
                firstInSection = files[section]
              } else {
                firstInSection = findFirstFile(filesInSection) || {}
              }

              const subsections = Object.keys(filesInSection)
                .sort(sortFiles(filesInSection))
                .map(x => filesInSection[x])
                .filter(shouldPrintTitle)

              return (
                <Section key={section}>
                  <NavigationItem to={cleanupLink(firstInSection.path)}>
                    <SectionHeader
                      text={section.toUpperCase()}
                      selected={
                        selectedSection === section ||
                        selectedSectionOrU === section
                      }
                    />
                  </NavigationItem>
                  {subsections.length ? (
                    <ul>
                      {subsections.map(subsection => {
                        if (!shouldPrintTitle(subsection)) {
                          return null
                        }
                        const link = findFirstLink(subsection)
                        const selected = isSelected(location, subsection)
                        return (
                          <ItemWrapper key={link}>
                            <NavigationItem to={cleanupLink(link)}>
                              <SubsectionHeader
                                text={
                                  capitalise(subsection.title) ||
                                  pathToTitle(subsection.path)
                                }
                                selected={selected}
                              />
                            </NavigationItem>
                            {selected && (
                              <SubTitles>
                                {Object.keys(subsection.children)
                                  .map(k => subsection.children[k])
                                  .sort((a, b) => a.order - b.order)
                                  .map(subtitle => (
                                    <SubNavigation
                                      subtitle={subtitle}
                                      location={location}
                                      key={subtitle.path}
                                    />
                                  ))}
                              </SubTitles>
                            )}
                          </ItemWrapper>
                        )
                      })}
                    </ul>
                  ) : null}
                </Section>
              )
            })}
          </ul>
        </NavigationWrapper>
      </InnerWrapper>
    </Wrapper>
  )
}

const FilesPropTypes = PropTypes.objectOf(
  PropTypes.shape({
    path: PropTypes.string.isRequired,
    title: PropTypes.string,
    order: PropTypes.number,
    children: PropTypes.any, // should be recursive but it doesn't work
  })
)

Siderbar.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  files: FilesPropTypes.isRequired,
}

SubNavigation.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  subtitle: PropTypes.shape({
    path: PropTypes.string.isRequired,
    title: PropTypes.string,
    order: PropTypes.number,
    children: FilesPropTypes, // eslint-disable-line no-use-before-define
  }).isRequired,
}

export default Siderbar
