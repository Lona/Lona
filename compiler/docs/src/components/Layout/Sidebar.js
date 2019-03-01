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

const Wrapper = styled.nav`
  flex: 0 0 30rem;
  margin-top: 0;
  width: 300px;
`

const InnerWrapper = styled.div`
  height: calc(100vh - ${HeaderHeight});
  overflow-y: auto;
`

const NavigationWrapper = styled.nav`
  flex: 0 0 auto;
`

const ItemWrapper = styled.li``

const NavigationItem = styled(Link)`
  display: flex;
  align-items: center;
  position: relative;
  text-decoration: none;
`

const Section = styled(NavigationItem)`
  font-weight: 500;
  text-transform: uppercase;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
  color: #637381;
  padding-top: 4rem;
`

const SubSection = styled(NavigationItem)`
  padding-top: 2rem;
  text-transform: capitalize;
  overflow: hidden;
  max-width: 100%;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 1.4rem;
  color: #000000;
`

const SubTitles = styled.ul`
  padding-left: 3.5rem;
  list-style: disc;
`

const SubTitle = styled(Link)`
  position: relative;
  display: block;
  padding: 0.8rem 0 0;
  text-decoration: ${p => (p.selected ? 'underline' : 'none')};
  display: inline-block;
  font-weight: ${p => (p.selected ? 800 : 400)};
  color: #000000;
  will-change: color, font-weight, transform;
  transition: color 0.24s cubic-bezier(0.64, 0, 0.35, 1),
    font-weight 0.24s cubic-bezier(0.64, 0, 0.35, 1),
    transform 0.24s cubic-bezier(0.64, 0, 0.35, 1);
  line-height: 1.4;
  font-size: 1.2rem;
  &:hover {
    text-decoration: underline;
  }
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
      <SubTitle to={cleanupLink(subTitleLink)} selected={selectedSubtitle}>
        {subtitle.title}
      </SubTitle>
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
                <ItemWrapper key={section}>
                  <Section
                    to={cleanupLink(firstInSection.path)}
                    selected={selectedSection === section}
                  >
                    {section}
                  </Section>
                  {subsections.length ? (
                    <ul>
                      {subsections.map(subsection => {
                        if (!shouldPrintTitle(subsection)) {
                          return null
                        }
                        const link = findFirstLink(subsection)
                        const selected = location.pathname.indexOf(link) === 0
                        return (
                          <ItemWrapper key={link}>
                            <SubSection
                              to={cleanupLink(link)}
                              selected={selected}
                            >
                              {subsection.title || pathToTitle(subsection.path)}
                            </SubSection>
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
                </ItemWrapper>
              )
            })}
          </ul>
        </NavigationWrapper>
      </InnerWrapper>
    </Wrapper>
  )
}

export default Siderbar
