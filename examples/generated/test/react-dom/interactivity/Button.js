import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class Button extends React.Component {
  render() {


    let Text$text
    let View$backgroundColor
    let View$hovered
    let View$onPress
    let View$pressed
    View$backgroundColor = colors.blue100

    Text$text = this.props.label
    View$onPress = this.props.onTap
    if (View$hovered) {

      View$backgroundColor = colors.blue200
    }
    if (View$pressed) {

      View$backgroundColor = colors.blue50
    }
    if (this.props.secondary) {

      View$backgroundColor = colors.lightblue100
    }
    return (
      <View
        style={{ backgroundColor: View$backgroundColor }}
        onClick={View$onPress}
      >
        <Text>
          {Text$text}
        </Text>
      </View>
    );
  }
};

let View = styled.button({
  alignItems: "flex-start",
  backgroundColor: colors.blue100,
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingTop: "12px",
  paddingRight: "16px",
  paddingBottom: "12px",
  paddingLeft: "16px"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.button,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})