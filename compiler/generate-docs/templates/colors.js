import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'
import ColorCard from '../lona-workspace/components/ColorCard.component'

const Wrapper = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`

export default function Template({
  pageContext: { colors, pathInWorkspace },
  location,
}) {
  pathInWorkspace = pathInWorkspace.slice(1)
  // eslint-disable-next-line
  const Colors = require(`lona-workspace/${pathInWorkspace}.json`).default

  return (
    <Layout location={location}>
      <ComponentTitle name="Colors" intro={colors.description} />
      <Wrapper>
        {colors.colors.map(color => (
          <ColorCard
            key={color.id}
            color={Colors[color.id]}
            colorName={color.name}
            colorCode={color.value}
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
    colors: PropTypes.shape({
      description: PropTypes.string,
      colors: PropTypes.arrayOf(
        PropTypes.shape({
          id: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
          value: PropTypes.string.isRequired,
        }).isRequired
      ),
    }).isRequired,
  }).isRequired,
}
