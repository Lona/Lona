import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class AccessibilityTest extends React.Component {
  focus = () => {
    let focusElements = this._getFocusElements()
    if (focusElements[0] && focusElements[0].focus) {
      focusElements[0].focus()
    }
  }

  focusNext = () => {
    let focusElements = this._getFocusElements()
    let nextIndex = elements.indexOf(document.activeElement) + 1

    if (nextIndex >= focusElements.length) {
      this.props.onFocusNext && this.props.onFocusNext()
      return ;
    }

    focusElements[nextIndex].focus && focusElements[nextIndex].focus()
  }

  focusPrevious = () => {
    let focusElements = this._getFocusElements()
    let previousIndex = elements.indexOf(document.activeElement) - 1

    if (previousIndex < 0) {
      this.props.onFocusPrevious && this.props.onFocusPrevious()
      return ;
    }

    focusElements[previousIndex].focus && focusElements[previousIndex].focus()
  }

  _handleKeyDown = (event) => {
    if (event.key === "Tab") {
      if (event.shiftKey) {
        this.focusPrevious()
      } else {
        this.focusNext()
      }

      event.stopPropagation()
      event.preventDefault()
    }
  }

  _getFocusElements = () => (
    [this._CheckboxRow, this._Element, this._Image, this._AccessibleText]
  )

  render() {


    let AccessibleText$accessibilityLabel
    let CheckboxCircle$visible
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
    return (
      <View>
        <CheckboxRow
          aria-label={"Checkbox row"}
          tabIndex={-1}
          handleKeyDown={this._handleKeyDown}
          ref={(ref) => { this._CheckboxRow = ref }}
        >
          <Checkbox onClick={Checkbox$onPress}>
            {CheckboxCircle$visible && <CheckboxCircle />}
          </Checkbox>
          <Text>
            {"Checkbox description"}
          </Text>
        </CheckboxRow>
        <Row1>
          <Element
            aria-label={"Red box"}
            tabIndex={-1}
            handleKeyDown={this._handleKeyDown}
            ref={(ref) => { this._Element = ref }}
          >
            <Inner />
          </Element>
          <Container>
            <Image
              src={require("../assets/icon_128x128.png")}
              aria-label={"My image"}
              tabIndex={-1}
              handleKeyDown={this._handleKeyDown}
              ref={(ref) => { this._Image = ref }}

            />
            <AccessibleText
              aria-label={AccessibleText$accessibilityLabel}
              tabIndex={-1}
              handleKeyDown={this._handleKeyDown}
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
  borderRadius: "20px",
  borderWidth: "1px",
  borderColor: colors.grey400,
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