import React from 'react'
import styled from 'styled-components'
import PropTypes from 'prop-types'
import Layout from '../src/components/Layout'
import ComponentTitle from '../lona-workspace/components/ComponentTitle.component'
import TextStyleCard from '../lona-workspace/components/TextStyleCard.component'

const Wrapper = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`

// https://fonts.google.com
export const TEXT_EXAMPLES = [
  'All their equipment and\ninstruments are alive.',
  'A red flare silhouetted\nthe jagged edge of a wing.',
  'I watched the storm, so\nbeautiful yet terrific.',
  'Almost before we knew it,\nwe had left the ground.',
  'A shining crescent far\nbeneath the flying vessel.',
  'It was going to be a\nlonely trip back.',
  'Mist enveloped the ship\nthree hours out from port.',
  'My two natures had\nmemory in common.',
  'Silver mist suffused\nthe deck of the ship.',
  'The face of the moon\nwas in shadow.',
  'She stared through\nthe window at the stars.',
  'The recorded voice\nscratched in the speaker.',
  'The sky was cloudless\nand of a deep dark blue.',
  'The spectacle before\nus was indeed sublime.',
  'Then came the night of\nthe first falling star.',
  'Waves flung themselves\nat the blue evening.',
]

export default function Template({
  pageContext: { textStyles, pathInWorkspace },
  location,
}) {
  pathInWorkspace = pathInWorkspace.slice(1)
  // eslint-disable-next-line
  const TextStyles = require(`lona-workspace/${pathInWorkspace}.json`).default

  return (
    <Layout location={location}>
      <ComponentTitle name="Text Styles" intro={textStyles.description} />
      <Wrapper>
        {textStyles.styles.map((textStyle, i) => (
          <TextStyleCard
            key={textStyle.id}
            textStyle={TextStyles[textStyle.id]}
            textStyleName={textStyle.name}
            textStyleCode=""
            text={TEXT_EXAMPLES[i % TEXT_EXAMPLES.length]}
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
    textStyles: PropTypes.shape({
      description: PropTypes.string,
      styles: PropTypes.arrayOf(
        PropTypes.shape({
          id: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
        }).isRequired
      ),
    }).isRequired,
  }).isRequired,
}
