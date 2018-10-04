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
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.fixed, {})} />
          <div style={Object.assign({}, styles.fit, {})}>
            <span style={Object.assign({}, styles.text, {})}>
              {"Text goes here"}
            </span>
          </div>
          <div style={Object.assign({}, styles.fill1, {})} />
          <div style={Object.assign({}, styles.fill2, {})} />
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
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "500px"
  },
  fixed: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    marginBottom: "24px",
    width: "100px",
    height: "100px"
  },
  fit: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    marginBottom: "24px",
    width: "100px"
  },
  fill1: {
    alignItems: "flex-start",
    backgroundColor: colors.cyan500,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    width: "100px"
  },
  fill2: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    width: "100px"
  },
  text: {
    ...textStyles.body1,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column"
  }
}