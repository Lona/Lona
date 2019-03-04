import React from 'react'
import PropTypes from 'prop-types'
import styled, { createGlobalStyle } from 'styled-components'
import { LiveProvider, LiveEditor, LiveError, LivePreview } from 'react-live'

import H3 from '../../../lona-workspace/components/markdown/H3.component'

const SelectionWrapper = styled.div`
  display: flex;
  margin-bottom: 1.6rem;
`

const SelectionInputWrapper = styled.div`
  margin-bottom: 0;
  position: relative;
  top: -0.4rem;
  flex: 1 1 0%;
  max-width: 38rem;
  margin-left: 3.2rem;
  &::after {
    content: '';
    position: absolute;
    top: 0.2rem;
    right: 0.4rem;
    bottom: 0.7rem;
    width: 7.2rem;
    background: linear-gradient(270deg, #fff 60%, hsla(0, 0%, 100%, 0));
    pointer-events: none;
  }
`

const SelectionInput = styled.select`
  width: 100%;
  height: 4.8rem;
  padding-right: 2.4rem;
  padding-left: 2.4rem;
  border: 0.1rem solid #c4cdd5;
  border-radius: 0.6rem;
  line-height: 4.8rem;
  font-size: 1.6rem;
  color: #161d25;
  background-color: #fff;
  box-shadow: inset 0 0 0 0.2rem rgba(92, 106, 196, 0),
    inset 0 0.1rem 0.2rem 0 rgba(99, 115, 129, 0.2);
  transition-property: border-color, box-shadow;
  transition-duration: 0.24s;
  transition-timing-function: cubic-bezier(0.64, 0, 0.35, 1);
  height: 3.8rem;
  padding-right: 1.6rem;
  padding-left: 1.6rem;
  line-height: 3.8rem;
`

const Option = styled.option`
  font-size: 1.6rem;
`

const ChevronWrapper = styled.div`
  position: absolute;
  z-index: 1;
  top: 50%;
  right: 1.6rem;
  pointer-events: none;
  transform: translateY(-50%);
  color: #5c6ac4;
  margin-bottom: 0;
`

const ChevronSVG = styled.svg`
  width: 1.2rem;
  height: 1.2rem;
  fill: currentColor;
  stroke: currentColor;
  stroke-width: 1;
  stroke-linecap: round;
  margin-bottom: 0;
  transform: rotate(180deg);
`

const StyledLivePreview = styled(LivePreview)`
  display: flex;
  width: 100%;
  padding: 0.8rem;
  border-radius: 0.6rem;
  background-color: #f4f6f8;
`

const GlobalStyle = createGlobalStyle`
  .prism-code.prism-code {
    display: flex;
    flex-direction: column;
    margin-top: 2.4rem;
    margin-bottom: 2.4rem;
    padding: 1.6rem;
    border-radius: 0.6rem;
    background-color: #000639;
    font-size: 1.6rem;
  }
`

class Examples extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      selectedExample: 0,
    }
    this.onChangeExample = this.onChangeExample.bind(this)
  }

  onChangeExample(event) {
    this.setState({
      selectedExample: event.target.value,
    })
  }

  render() {
    return (
      <div>
        <GlobalStyle />
        <SelectionWrapper>
          <H3 text="Examples" />
          <SelectionInputWrapper>
            <SelectionInput
              ariaLabelledby="ExamplesLabel"
              value={this.state.selectedExample}
              onChange={this.onChangeExample}
            >
              {this.props.examples.map(({ name }, i) => (
                <Option key={name} value={i}>
                  {name}
                </Option>
              ))}
            </SelectionInput>
            <ChevronWrapper>
              <ChevronSVG
                viewBox="0 0 20 20"
                preserveAspectRatio="xMidYMid"
                focusable="false"
                ariaHidden="true"
              >
                <path d="M.326 15.23c.434.434 1.137.434 1.57 0L10 7.127l8.103 8.103c.434.434 1.137.434 1.57 0 .435-.434.435-1.137 0-1.57l-8.887-8.89c-.217-.217-.502-.326-.786-.326s-.57.11-.786.326l-8.89 8.89c-.433.433-.433 1.136.002 1.57z" />
              </ChevronSVG>
            </ChevronWrapper>
          </SelectionInputWrapper>
        </SelectionWrapper>
        <div>
          <p>{this.props.examples[this.state.selectedExample].description}</p>
        </div>
        <div>
          <LiveProvider
            code={this.props.examples[this.state.selectedExample].text}
            scope={{ React, styled, ...this.props.scope }}
          >
            <StyledLivePreview />
            <LiveEditor />
            <LiveError />
          </LiveProvider>
        </div>
      </div>
    )
  }
}

Examples.propTypes = {
  examples: PropTypes.arrayOf(
    PropTypes.shape({
      text: PropTypes.string,
      description: PropTypes.string,
      name: PropTypes.string,
    })
  ).isRequired,
  scope: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
}

export default Examples
