import React from "react"
import styled, { ThemeProvider } from "styled-components"

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
    let theme = { "view": { "normal": {} }, "text": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div
          style={Object.assign({}, styles.view, {
            backgroundColor: View$backgroundColor
          })}
          onClick={View$onPress}
        >
          <span style={Object.assign({}, styles.text, {})}>
            {Text$text}
          </span>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
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
  },
  text: {
    ...textStyles.button,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}