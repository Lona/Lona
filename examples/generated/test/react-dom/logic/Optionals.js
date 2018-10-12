import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class Optionals extends React.Component {
  render() {

    let Label$text
    let View$backgroundColor
    Label$text = ""
    View$backgroundColor = "transparent"

    if (this.props.boolParam == true) {
      Label$text = "boolParam is true"
      View$backgroundColor = colors.green200
    }
    if (this.props.boolParam == false) {
      Label$text = "boolParam is false"
      View$backgroundColor = colors.red200
    }
    if (this.props.boolParam == null) {
      Label$text = "boolParam is null"
    }
    let theme = { "view": { "normal": {} }, "label": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div
          style={Object.assign({}, styles.view, {
            backgroundColor: View$backgroundColor
          })}
        >
          <span style={Object.assign({}, styles.label, {})}>
            {Label$text}
          </span>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  label: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}