import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class AccessibilityVisibility extends React.Component {
  state = { focusRing: false }

  setFocusRing = (focusRing) => { this.setState({ focusRing }) }

  focus = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    let focusElements = this._getFocusElements()
    if (focusElements[0] && focusElements[0].focus) {
      focusElements[0].focus()
    }
  }

  focusLast = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    let focusElements = this._getFocusElements()
    if
    (
    focusElements[focusElements.length - 1] &&
    focusElements[focusElements.length - 1].focus
    ) {
      focusElements[focusElements.length - 1].focus()
    }
  }

  focusNext = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    let focusElements = this._getFocusElements()
    let nextIndex = focusElements.indexOf(document.activeElement) + 1

    if (nextIndex >= focusElements.length) {
      this.props.onFocusNext && this.props.onFocusNext()
      return ;
    }

    focusElements[nextIndex].focus && focusElements[nextIndex].focus()
  }

  focusPrevious = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    let focusElements = this._getFocusElements()
    let previousIndex = focusElements.indexOf(document.activeElement) - 1

    if (previousIndex < 0) {
      this.props.onFocusPrevious && this.props.onFocusPrevious()
      return ;
    }

    focusElements[previousIndex].focus && focusElements[previousIndex].focus()
  }

  _handleKeyDown = (event) => {
    if (event.key === "Tab") {
      this.setFocusRing(true)

      if (event.shiftKey) {
        this.focusPrevious()
      } else {
        this.focusNext()
      }

      event.stopPropagation()
      event.preventDefault()
    }
  }

  _getFocusElements = () => {
    let elements = [this._GreyBox, this._Text]
    return elements.filter(Boolean);
  }

  render() {


    let Text$visible

    Text$visible = this.props.showText
    return (
      <View>
        <GreyBox
          aria-label={"Grey box"}
          tabIndex={-1}
          focusRing={this.state.focusRing}
          onKeyDown={this._handleKeyDown}
          ref={(ref) => { this._GreyBox = ref }}

        />
        {
          Text$visible &&
          <Text
            aria-label={"Some text that is sometimes hidden"}
            tabIndex={-1}
            focusRing={this.state.focusRing}
            onKeyDown={this._handleKeyDown}
            ref={(ref) => { this._Text = ref }}
          >
            {"Sometimes hidden"}
          </Text>
        }
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let GreyBox = styled.div((props) => ({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px",
  height: "40px",
  ...!props.focusRing && { ":focus": { outline: 0 } }
}))

let Text = styled.span((props) => ({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  ...!props.focusRing && { ":focus": { outline: 0 } }
}))