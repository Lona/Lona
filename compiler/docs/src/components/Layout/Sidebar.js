import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'
import { HeaderHeight } from './ui-constants'
import {
  findFirstFile,
  findFirstLink,
  cleanupLink,
  capitalise,
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

const SubNavigation = ({ subtitle, location }) => {
  if (!shouldPrintTitle(subtitle)) {
    return null
  }
  const subTitleLink = findFirstLink(subtitle)
  const selectedSubtitle = location.pathname.indexOf(subtitle.path) === 0
  return (
    <li>
      <NavigationItem to={cleanupLink(subTitleLink)}>
        <SubSubsectionHeader
          text={subtitle.title}
          selected={selectedSubtitle}
        />
      </NavigationItem>
    </li>
  )
}

const Siderbar = ({ data, location, files }) => {
  const [, selectedSection] = location.pathname.split('/')

  const sections = Object.keys(files).filter(section => files[section])

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

              const subsections = Object.values(filesInSection)
                .sort((a, b) => a.order - b.order)
                .filter(shouldPrintTitle)

              return (
                <Section key={section}>
                  <NavigationItem to={cleanupLink(firstInSection.path)}>
                    <SectionHeader
                      text={section.toUpperCase()}
                      selected={selectedSection === section}
                    />
                  </NavigationItem>
                  {subsections.length ? (
                    <ul>
                      {subsections.map(subsection => {
                        if (!shouldPrintTitle(subsection)) {
                          return null
                        }
                        const link = findFirstLink(subsection)
                        const selected =
                          location.pathname.indexOf(subsection.path) === 0
                        return (
                          <ItemWrapper key={link}>
                            <NavigationItem to={cleanupLink(link)}>
                              <SubsectionHeader
                                text={
                                  subsection.title ||
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

export default Siderbar
