import React from 'react'
import styled from 'styled-components'
import PropTypes from 'prop-types'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'
import ShadowCard from '../lona-workspace/components/ShadowCard.component'

const Wrapper = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`

export default function Template({
  pageContext: { shadows, pathInWorkspace },
  location,
}) {
  pathInWorkspace = pathInWorkspace.slice(1)
  // eslint-disable-next-line
  const Shadows = require(`lona-workspace/${pathInWorkspace}.json`).default

  return (
    <Layout location={location}>
      <ComponentTitle name="Shadows" intro={shadows.description} />
      <Wrapper>
        {shadows.shadows.map(shadow => (
          <ShadowCard
            key={shadow.id}
            shadow={Shadows[shadow.id]}
            shadowName={shadow.name}
            shadowCode={Shadows[shadow.id].filter}
          />
        ))}
      </Wrapper>
    </Layout>
  )
}

Template.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  pageContext: PropTypes.shape({
    pathInWorkspace: PropTypes.string.isRequired,
    shadows: PropTypes.shape({
      description: PropTypes.string,
      shadows: PropTypes.arrayOf(
        PropTypes.shape({
          id: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
        }).isRequired
      ),
    }).isRequired,
  }).isRequired,
}
