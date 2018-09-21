import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {


    let theme = { "view": { "normal": {} }, "view1": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <div style={Object.assign(styles.view1, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex" },
  view1: {
    display: "flex",
    borderRadius: "10px",
    borderWidth: "20px",
    borderColor: colors.blue300,
    width: "100px",
    height: "100px"
  }
}