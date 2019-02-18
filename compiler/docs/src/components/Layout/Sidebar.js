import React from 'react'
import { Link } from 'gatsby'
import styled from 'styled-components'

import { findFirstFile, cleanupLink } from '../../utils'

const Wrapper = styled.nav`
  flex: 0 0 34rem;
  margin-top: 0;
  width: 340px;
`

const InnerWrapper = styled.div`
  height: calc(100vh - 3.2rem);
  overflow-y: auto;
`

const NavigationWrapper = styled.nav`
  flex: 0 0 auto;
`

const ItemWrapper = styled.li`
  & + li {
    padding-top: 2.4rem;
  }
`

const NavigationItem = styled(Link)`
  display: flex;
  align-items: center;
  position: relative;
  text-decoration: none;
`

const Icon = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  width: 4.8rem;
  height: 4.8rem;
  border-radius: 50%;
  color: #fff;
  background-color: ${p => (p.selected ? '#202e78' : '#5c6ac4')};
  min-width: 0;
  max-width: 100%;
  flex: 0 0 4.8rem;
  margin-right: 1.6rem;
  transition: background-color 0.24s cubic-bezier(0.64, 0, 0.35, 1);
  ${NavigationItem}:hover & {
    background-color: '#202e78';
  }
`

const Label = styled.span`
  font-weight: 500;
  letter-spacing: 0.1rem;
  text-transform: uppercase;
  display: block;
  overflow: hidden;
  max-width: 100%;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 1.4rem;
  color: ${p => (p.selected ? '#212b35' : '#637381')};
  transform: translateX(0);
  backface-visibility: hidden;
  ${NavigationItem}:hover & {
    color: ${p => (p.selected ? '#202e78' : '#5c6ac4')};
  }
`

const SubTitles = styled.ul`
  overflow: hidden;
  height: auto;
  padding-top: 0;
  padding-bottom: 0;
  backface-visibility: hidden;
  will-change: opacity, height;
  opacity: 1;
  padding-left: 4.8rem;
`

const SubTitle = styled(Link)`
  position: relative;
  display: block;
  padding: 0.8rem 1.6rem;
  text-decoration: none;
  display: inline-block;
  color: ${p => (p.selected ? '#202e78' : '#637381')};
  transform: translateX(${p => (p.selected ? '1.6rem' : 0)});
  backface-visibility: hidden;
  will-change: color, font-weight, transform;
  transition: color 0.24s cubic-bezier(0.64, 0, 0.35, 1),
    font-weight 0.24s cubic-bezier(0.64, 0, 0.35, 1),
    transform 0.24s cubic-bezier(0.64, 0, 0.35, 1);
  line-height: 1.4;
  font-size: 1.6rem;
  &:hover {
    color: ${p => (p.selected ? '#202e78' : '#5c6ac4')};
  }
`

const SelectedMarker = styled.div`
  position: absolute;
  top: 50%;
  left: 0;
  display: block;
  width: 0.4rem;
  height: calc(100% - 1.2rem);
  transform: translate(0, -50%) scaleX(${p => (p.selected ? 1 : 0)});
  opacity: ${p => (p.selected ? 1 : 0)};
  transform-origin: 0 0;
  transition: transform 0.24s cubic-bezier(0.36, 0, 1, 1),
    opacity 0.24s cubic-bezier(0.36, 0, 1, 1);
  background: #202e78;
`

function shouldPrintTitle(element) {
  return !element.hidden || Object.keys(element.children).length
}

const SubNavigation = ({ subtitle, location }) => {
  if (!shouldPrintTitle(subtitle)) {
    return null
  }
  const subTitleLink = subtitle.component
    ? subtitle.path
    : (findFirstFile(subtitle.children) || {}).path
  const selectedSubtitle = location.pathname.indexOf(subtitle.path) === 0
  return (
    <li>
      <SubTitle to={cleanupLink(subTitleLink)} selected={selectedSubtitle}>
        <SelectedMarker selected={selectedSubtitle} />
        {subtitle.title}
      </SubTitle>
    </li>
  )
}

const Siderbar = ({ data, location, files }) => {
  const [, selectedSection] = location.pathname.split('/')

  const filesInSection = (files[selectedSection] || {}).children || {}

  const subsections = Object.keys(filesInSection)
    .map(k => filesInSection[k])
    .sort((a, b) => a.order - b.order)
    .filter(shouldPrintTitle)

  return (
    <Wrapper>
      <InnerWrapper>
        <NavigationWrapper ariaLabel="Secondary navigation">
          <ul>
            {subsections.map(subsection => {
              if (!shouldPrintTitle(subsection)) {
                return null
              }
              const link = subsection.path
              const selected = location.pathname.indexOf(link) === 0
              return (
                <ItemWrapper key={link}>
                  <NavigationItem to={cleanupLink(link)} selected={selected}>
                    <Icon selected={selected} />
                    <Label selected={selected}>
                      {subsection.title || subsection.path}
                    </Label>
                  </NavigationItem>
                  {selected && (
                    <SubTitles>
                      {subsection.showSubtitlesInSidebar
                        ? subsection.subtitles.map(subtitle => (
                            <li key={subtitle}>
                              <SubTitle to={`#${subtitle}`}>
                                {subtitle}
                              </SubTitle>
                            </li>
                          ))
                        : Object.keys(subsection.children)
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
        </NavigationWrapper>
      </InnerWrapper>
    </Wrapper>
  )
}

export default Siderbar
