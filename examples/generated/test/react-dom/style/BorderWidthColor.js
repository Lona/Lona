import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {


    let theme = { "view": { "normal": {} }, "view1": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.view1, {})} />
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
  view1: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    borderRadius: "10px",
    borderWidth: "20px",
    borderColor: colors.blue300,
    width: "100px",
    height: "100px"
  }
}