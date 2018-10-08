import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class If extends React.Component {
  render() {

    let View$backgroundColor
    View$backgroundColor = "transparent"

    if (this.props.enabled) {
      View$backgroundColor = colors.red500
    }
    let theme = { "view": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div
          style={Object.assign({}, styles.view, {
            backgroundColor: View$backgroundColor
          })}

        />
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
  }
}