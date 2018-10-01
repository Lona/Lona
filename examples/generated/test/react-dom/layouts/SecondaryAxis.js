import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {


    let theme = {
      "container": { "normal": {} },
      "fixed": { "normal": {} },
      "fit": { "normal": {} },
      "text": { "normal": {} },
      "fill": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.container, {})}>
          <div style={Object.assign(styles.fixed, {})} />
          <div style={Object.assign(styles.fit, {})}>
            <span style={Object.assign(styles.text, {})}>
              {"Text goes here"}
            </span>
          </div>
          <div style={Object.assign(styles.fill, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  container: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
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
    paddingTop: "12px",
    paddingRight: "12px",
    paddingBottom: "12px",
    paddingLeft: "12px",
    height: "100px"
  },
  text: { display: "flex", flexDirection: "column" },
  fill: {
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    height: "100px"
  }
}