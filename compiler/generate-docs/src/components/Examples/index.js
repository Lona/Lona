import React from 'react'
import PropTypes from 'prop-types'
import styled, { createGlobalStyle } from 'styled-components'
import { LiveProvider, LiveEditor, LiveError, LivePreview } from 'react-live'
import SplitPane from 'react-split-pane'

import H3 from '../../../lona-workspace/components/markdown/H3.component'
import textStyles from '../../../lona-workspace/foundation/textStyles.json'
import highlightTheme from './highlight-theme'

const Wrapper = styled.div`
  flex: 1;
  display: flex;
  height: 350px;
  width: 100%;
  border: 1px solid #eeeeee;
  position: relative;
`

const CodeWrapper = styled.div`
  height: 100%;
  position: relative;
`

const PreviewWrapper = styled.div`
  height: 100%;
  position: relative;
`

const SelectionWrapper = styled.div`
  display: flex;
  border-bottom: 1px solid #eeeeee;
`

const PreviewHeader = styled.div`
  height: 50px;
  border-bottom: 1px solid #eeeeee;
  line-height: 50px;
  font-size: 16px;
  color: #a4a4a4;
  padding-right: 16px;
  padding-left: 16px;
`

const SelectionInputWrapper = styled.div`
  margin-bottom: 0;
  position: relative;
  flex: 0 0 auto;
  display: flex;
`

const SelectionInput = styled.select({
  ...textStyles.regular,
  width: '100%',
  height: '49px',
  lineHeight: '49px',
  border: '0 solid transparent',
  backgroundColor: '#fff',
  paddingRight: '16px',
  paddingLeft: '16px',
})

const Option = styled.option`
  font-size: 16px;
`

const ChevronWrapper = styled.div`
  position: absolute;
  z-index: 1;
  top: 50%;
  right: 0.1rem;
  pointer-events: none;
  transform: translateY(-50%);
  margin-bottom: 0;
`

const ChevronSVG = styled.svg`
  width: 9px;
  height: 5px;
  fill: currentColor;
  stroke: currentColor;
  stroke-width: 1;
  stroke-linecap: round;
  margin-bottom: 0;
`

const StyledLivePreview = styled(LivePreview)`
  display: flex;
  width: 100%;
  padding: 0.8rem;
  height: calc(100% - 50px);
`

const dragHandleSvg = `
<svg width='5px' height='6px' version='1.1' xmlns='http://www.w3.org/2000/svg'>
  <g id='Components-Page' stroke='lightgray' stroke-width='1' fill='none' fill-rule='evenodd' stroke-linecap='square'>
    <path d='M0.5,0.5 L0.5,5.5' id='Line-4'></path>
    <path d='M2.5,0.5 L2.5,5.5' id='Line-4'></path>
    <path d='M4.5,0.5 L4.5,5.5' id='Line-4'></path>
  </g>
</svg>
`

const GlobalStyle = createGlobalStyle`
  .Resizer {
    background: #EEEEEE;
    z-index: 1;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    -moz-background-clip: padding;
    -webkit-background-clip: padding;
    background-clip: padding-box;
    position: relative;

    &::after {
      content: ' ';
      position: absolute;
      top: 50%;
      left: 1px;
      color: teal;
      width: 5px;
      height: 6px;
      background-image: url("data:image/svg+xml;utf8,${dragHandleSvg}");
    }
  }

  .Resizer.horizontal {
    height: 7px;
    cursor: row-resize;
    width: 100%;
  }

  .Resizer.vertical {
    width: 7px;
    cursor: col-resize;
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

  .Examples__live-editor > textarea, .Examples__live-editor > pre {
    /* we need that otherwise some weird spaces appears when the line is longer than the container */
    word-break: normal !important;
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
        <H3 text="Examples" />
        <div>
          <p>{this.props.examples[this.state.selectedExample].description}</p>
        </div>
        <Wrapper>
          <LiveProvider
            code={this.props.examples[this.state.selectedExample].text}
            scope={{ React, styled, ...this.props.scope }}
            theme={highlightTheme}
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
                        viewBox="0 0 9 5"
                        preserveAspectRatio="xMidYMid"
                        focusable="false"
                        ariaHidden="true"
                      >
                        <g
                          fill="none"
                          fillRule="evenodd"
                          stroke="#000000"
                          strokeWidth="1.5"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <path d="M1,1 L4.5,4 L8,1" />
                        </g>
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
                <LiveEditor
                  padding={16}
                  style={{
                    fontSize: '14px',
                    fontFamily: 'Menlo, "Fira code", "Fira Mono", monospace',
                    lineHeight: '21px',
                  }}
                  className="Examples__live-editor"
                />
              </CodeWrapper>
              <PreviewWrapper>
                <PreviewHeader>Live preview</PreviewHeader>
                <StyledLivePreview />
              </PreviewWrapper>
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
