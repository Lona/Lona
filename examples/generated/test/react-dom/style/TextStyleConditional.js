import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextStyleConditional extends React.Component {
  render() {

    let Text$textStyle
    Text$textStyle = textStyles.headline

    if (this.props.large) {
      Text$textStyle = textStyles.display2
    }
    let theme = { "view": { "normal": {} }, "text": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <span style={Object.assign({}, styles.text, { ...Text$textStyle })}>
            {"Text goes here"}
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
    flexDirection: "column"
  },
  text: {
    ...textStyles.headline,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column"
  }
}