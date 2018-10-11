import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
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
        <div style={Object.assign({}, styles.container, {})}>
          <div style={Object.assign({}, styles.fixed, {})} />
          <div style={Object.assign({}, styles.fit, {})}>
            <span style={Object.assign({}, styles.text, {})}>
              {"Text goes here"}
            </span>
          </div>
          <div style={Object.assign({}, styles.fill, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  fixed: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "24px",
    width: "100px",
    height: "100px"
  },
  fit: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "24px",
    paddingTop: "12px",
    paddingRight: "12px",
    paddingBottom: "12px",
    paddingLeft: "12px",
    height: "100px"
  },
  fill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "100px"
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}