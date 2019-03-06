import React from 'react'
import styled from 'styled-components'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'
import ColorCard from '../lona-workspace/components/ColorCard.component'

const Wrapper = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`

export default function Template({ pageContext: { colors }, location }) {
  return (
    <Layout location={location}>
      <ComponentTitle name="Colors" intro={colors.description} />
      <Wrapper>
        {colors.colors.map(color => (
          <ColorCard
            key={color.id}
            color={color.value}
            colorName={color.name}
            colorCode={color.value}
          />
        ))}
      </Wrapper>
    </Layout>
  )
}
