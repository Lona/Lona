import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {

    let Inner$borderColor
    let Inner$borderRadius
    let Inner$borderWidth
    Inner$borderRadius = 10
    Inner$borderWidth = 20
    Inner$borderColor = colors.blue300

    if (this.props.alternativeStyle) {
      Inner$borderColor = colors.reda400
      Inner$borderWidth = 4
      Inner$borderRadius = 20
    }
    let theme = { "view": { "normal": {} }, "inner": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div
            style={Object.assign({}, styles.inner, {
              borderRadius: Inner$borderRadius,
              borderWidth: Inner$borderWidth,
              borderColor: Inner$borderColor
            })}

          />
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
  inner: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    borderRadius: "10px",
    borderWidth: "20px",
    borderColor: colors.blue300,
    width: "100px",
    height: "100px"
  }
}