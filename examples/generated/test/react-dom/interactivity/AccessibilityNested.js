import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import AccessibilityTest from "./AccessibilityTest"
import AccessibilityVisibility from "./AccessibilityVisibility"

export default class AccessibilityNested extends React.Component {
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
    if (
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
    let elements = []
    return elements.filter(Boolean);
  }

  render() {



    return (
      <Container>
        <AccessibilityTestAccessibilityTestWrapper>
          <AccessibilityTest
            checkboxValue={false}
            customTextAccessibilityLabel={"Text"}
            tabIndex={-1}
            focusRing={this.state.focusRing}
            onKeyDown={this._handleKeyDown}
            ref={(ref) => { this._AccessibilityTest = ref }}

          />
        </AccessibilityTestAccessibilityTestWrapper>
        <AccessibilityVisibilityAccessibilityVisibilityWrapper>
          <AccessibilityVisibility
            showText={true}
            tabIndex={-1}
            focusRing={this.state.focusRing}
            onKeyDown={this._handleKeyDown}
            ref={(ref) => { this._AccessibilityVisibility = ref }}

          />
        </AccessibilityVisibilityAccessibilityVisibilityWrapper>
      </Container>
    );
  }
};

let Container = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let AccessibilityTestAccessibilityTestWrapper = styled.div((props) => ({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "1 1 auto",
  flexDirection: "row",
  justifyContent: "flex-start",
  ...!props.focusRing && { ":focus": { outline: 0 } }
}))

let AccessibilityVisibilityAccessibilityVisibilityWrapper = styled.div((props) => ({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "1 1 auto",
  flexDirection: "row",
  justifyContent: "flex-start",
  ...!props.focusRing && { ":focus": { outline: 0 } }
}))