import React from 'react'
import PropTypes from 'prop-types'
import styled, { createGlobalStyle } from 'styled-components'
import { LiveProvider, LiveEditor, LiveError, LivePreview } from 'react-live'
import SplitPane from 'react-split-pane'

import H3 from '../../../lona-workspace/components/markdown/H3.component'
import highlightCSS from './highlight-theme'

const Wrapper = styled.div`
  flex: 1;
  display: flex;
  height: 350px;
  width: 100%;
  border: 1px solid #d8d8d8;
  position: relative;
`

const CodeWrapper = styled.div`
  height: 100%;
  position: relative;
`

const SelectionWrapper = styled.div`
  display: flex;
  border-bottom: 1px solid #d8d8d8;
`

const PreviewHeader = styled.div`
  height: 50px;
  border-bottom: 1px solid #d8d8d8;
  line-height: 50px;
  font-size: 16px;
  color: #a4a4a4;
  padding-right: 16px;
  padding-left: 16px;
`

const SelectionInputWrapper = styled.div`
  margin-bottom: 0;
  position: relative;
  flex: 1 1 0%;
`

const SelectionInput = styled.select`
  width: 100%;
  height: 49px;
  border: 0 solid transparent;
  line-height: 49px;
  font-size: 16px;
  color: #161d25;
  background-color: #fff;
  padding-right: 16px;
  padding-left: 16px;
`

const Option = styled.option`
  font-size: 16px;
`

const ChevronWrapper = styled.div`
  position: absolute;
  z-index: 1;
  top: 50%;
  right: 1.6rem;
  pointer-events: none;
  transform: translateY(-50%);
  color: #d8d8d8;
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
`

const GlobalStyle = createGlobalStyle`
  .Resizer {
    background: #000;
    opacity: .2;
    z-index: 1;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    -moz-background-clip: padding;
    -webkit-background-clip: padding;
    background-clip: padding-box;
  }

  .Resizer:hover {
    -webkit-transition: all 2s ease;
    transition: all 2s ease;
  }

  .Resizer.horizontal {
    height: 11px;
    margin: -5px 0;
    border-top: 5px solid rgba(255, 255, 255, 0);
    border-bottom: 5px solid rgba(255, 255, 255, 0);
    cursor: row-resize;
    width: 100%;
  }

  .Resizer.horizontal:hover {
    border-top: 5px solid rgba(0, 0, 0, 0.5);
    border-bottom: 5px solid rgba(0, 0, 0, 0.5);
  }

  .Resizer.vertical {
    width: 11px;
    margin: 0 -5px;
    border-left: 5px solid rgba(255, 255, 255, 0);
    border-right: 5px solid rgba(255, 255, 255, 0);
    cursor: col-resize;
  }

  .Resizer.vertical:hover {
    border-left: 5px solid rgba(0, 0, 0, 0.5);
    border-right: 5px solid rgba(0, 0, 0, 0.5);
  }
  .Resizer.disabled {
    cursor: not-allowed;
  }
  .Resizer.disabled:hover {
    border-color: transparent;
  }

  .prism-code.prism-code {
    display: flex;
    flex-direction: column;
    font-size: 16px;
    height: calc(100% - 50px);
  }

  ${highlightCSS}
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
        <H3 text="Examples" />
        <div>
          <p>{this.props.examples[this.state.selectedExample].description}</p>
        </div>
        <Wrapper>
          <LiveProvider
            code={this.props.examples[this.state.selectedExample].text}
            scope={{ React, styled, ...this.props.scope }}
            mountStylesheet={false}
          >
            <SplitPane defaultSize="50%" split="vertical">
              <CodeWrapper>
                <SelectionWrapper>
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
                <LiveError
                  style={{
                    position: 'absolute',
                    bottom: 0,
                    background: 'red',
                    color: 'white',
                    fontSize: '12px',
                    whiteSpace: 'pre',
                    padding: '8px',
                    width: '100%',
                  }}
                />
                <LiveEditor />
              </CodeWrapper>
              <div>
                <PreviewHeader>Live preview</PreviewHeader>
                <StyledLivePreview />
              </div>
            </SplitPane>
          </LiveProvider>
        </Wrapper>
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
