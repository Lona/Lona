import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "fixed": { "normal": {} },
      "fit": { "normal": {} },
      "text": { "normal": {} },
      "fill1": { "normal": {} },
      "fill2": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <div style={Object.assign(styles.fixed, {})} />
          <div style={Object.assign(styles.fit, {})}>
            <span style={Object.assign(styles.text, {})}>
              {"Text goes here"}
            </span>
          </div>
          <div style={Object.assign(styles.fill1, {})} />
          <div style={Object.assign(styles.fill2, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "500px"
  },
  fixed: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    marginBottom: "24px",
    width: "100px",
    height: "100px"
  },
  fit: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    marginBottom: "24px",
    width: "100px"
  },
  text: { display: "flex", flexDirection: "column" },
  fill1: {
    backgroundColor: colors.cyan500,
    display: "flex",
    flex: 1,
    flexDirection: "column",
    width: "100px"
  },
  fill2: {
    backgroundColor: colors.blue500,
    display: "flex",
    flex: 1,
    flexDirection: "column",
    width: "100px"
  }
}