// Compiled by Lona Version 0.5.2

import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import createActivatableComponent from "../utils/createActivatableComponent"
import { isFocused, focusFirst, focusLast, focusNext, focusPrevious } from
  "../utils/focusUtils"

export default class AccessibilityTest extends React.Component {
  state = { focusRing: false }

  setFocusRing = (focusRing) => { this.setState({ focusRing }) }

  isFocused = () => {
    let focusElements = this._getFocusElements()

    return !!focusElements.find(isFocused);
  }

  focus = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusFirst(this._getFocusElements());
  }

  focusLast = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusLast(this._getFocusElements());
  }

  focusNext = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusNext(this._getFocusElements());
  }

  focusPrevious = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusPrevious(this._getFocusElements());
  }

  _handleKeyDown = (event) => {
    if (event.key === "Tab") {
      this.setFocusRing(true)

      if (event.shiftKey) {
        if (this.focusPrevious()) {
          event.stopPropagation()
          event.preventDefault()
          return ;
        } else if (this.props.onFocusExitPrevious) {
          this.props.onFocusExitPrevious()

          event.stopPropagation()
          event.preventDefault()
          return ;
        }
      } else if (this.focusNext()) {
        event.stopPropagation()
        event.preventDefault()
        return ;
      } else if (this.props.onFocusExitNext) {
        this.props.onFocusExitNext()

        event.stopPropagation()
        event.preventDefault()
        return ;
      }
    }

    if (this.props.onKeyDown) {
      this.props.onKeyDown(event)
    }
  }

  _getFocusElements = () => {
    let elements = [
      this._CheckboxRow,
      this._Element,
      this._AccessibleText,
      this._Image
    ]
    return elements.filter(Boolean);
  }

  render() {


    let AccessibleText$accessibilityLabel
    let CheckboxCircle$visible
    let CheckboxRow$accessibilityChecked
    let CheckboxRow$accessibilityValue
    let CheckboxRow$onAccessibilityActivate
    let Checkbox$onPress
    CheckboxCircle$visible = true
    CheckboxRow$accessibilityValue = ""

    AccessibleText$accessibilityLabel = this.props.customTextAccessibilityLabel
    if (this.props.checkboxValue) {

      CheckboxCircle$visible = true
      CheckboxRow$accessibilityValue = "checked"
    }
    if (this.props.checkboxValue === false) {

      CheckboxCircle$visible = false
      CheckboxRow$accessibilityValue = "unchecked"
    }
    CheckboxRow$onAccessibilityActivate = this.props.onToggleCheckbox
    Checkbox$onPress = this.props.onToggleCheckbox
    CheckboxRow$accessibilityChecked = this.props.checkboxValue
    return (
      <View>
        <CheckboxRowAccessibilityWrapper
          aria-label={"Checkbox row"}
          role={"checkbox"}
          onAccessibilityActivate={CheckboxRow$onAccessibilityActivate}
          aria-checked={CheckboxRow$accessibilityChecked}
          tabIndex={-1}
          className={(
            this.state.focusRing
              ? "lona--focus-ring"
              : "lona--no-focus-ring"
          )}
          onKeyDown={this._handleKeyDown}
          ref={(ref) => { this._CheckboxRow = ref }}
        >
          <Checkbox onClick={Checkbox$onPress}>
            {CheckboxCircle$visible && <CheckboxCircle />}
          </Checkbox>
          <Text>
            {"Checkbox description"}
          </Text>
        </CheckboxRowAccessibilityWrapper>
        <Row1>
          <Element
            aria-label={"Red box"}
            role={"button"}
            tabIndex={-1}
            className={(
              this.state.focusRing
                ? "lona--focus-ring"
                : "lona--no-focus-ring"
            )}
            onKeyDown={this._handleKeyDown}
            ref={(ref) => { this._Element = ref }}
          >
            <Inner />
          </Element>
          <Container>
            <Image
              src={require("../assets/icon_128x128.png")}
              aria-label={"My image"}
              tabIndex={-1}
              className={(
                this.state.focusRing
                  ? "lona--focus-ring"
                  : "lona--no-focus-ring"
              )}
              onKeyDown={this._handleKeyDown}
              ref={(ref) => { this._Image = ref }}

            />
            <AccessibleText
              aria-label={AccessibleText$accessibilityLabel}
              tabIndex={-1}
              className={(
                this.state.focusRing
                  ? "lona--focus-ring"
                  : "lona--no-focus-ring"
              )}
              onKeyDown={this._handleKeyDown}
              ref={(ref) => { this._AccessibleText = ref }}
            >
              {"Greetings"}
            </AccessibleText>
          </Container>
        </Row1>
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

let CheckboxRow = styled.div({
  alignItems: "center",
  alignSelf: "stretch",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "row",
  justifyContent: "flex-start",
  paddingTop: "10px",
  paddingRight: "10px",
  paddingBottom: "10px",
  paddingLeft: "10px"
})

let Checkbox = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginRight: "10px",
  paddingTop: "4px",
  paddingRight: "4px",
  paddingBottom: "4px",
  paddingLeft: "4px",
  borderColor: colors.grey400,
  borderRadius: "20px",
  borderStyle: "solid",
  borderWidth: "1px",
  width: "30px",
  height: "30px"
})

let CheckboxCircle = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.green200,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  borderRadius: "15px"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Row1 = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "row",
  justifyContent: "flex-start",
  paddingTop: "10px",
  paddingRight: "10px",
  paddingBottom: "10px",
  paddingLeft: "10px"
})

let Element = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.red600,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginRight: "10px",
  paddingTop: "10px",
  paddingRight: "10px",
  paddingBottom: "10px",
  paddingLeft: "10px",
  width: "50px",
  height: "50px"
})

let Inner = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.red800,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Container = styled.div({
  alignItems: "center",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "row",
  justifyContent: "flex-start"
})

let Image = styled.img({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginRight: "4px",
  overflow: "hidden",
  width: "50px",
  height: "50px",
  objectFit: "cover",
  position: "relative"
})

let AccessibleText = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let CheckboxRowAccessibilityWrapper = createActivatableComponent(CheckboxRow)