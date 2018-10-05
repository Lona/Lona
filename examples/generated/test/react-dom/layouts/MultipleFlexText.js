import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class MultipleFlexText extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "view1": { "normal": {} },
      "view3": { "normal": {} },
      "text": { "normal": {} },
      "view2": { "normal": {} },
      "view4": { "normal": {} },
      "text1": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.view1, {})}>
            <div style={Object.assign({}, styles.view3, {})}>
              <span style={Object.assign({}, styles.text, {})}>
                {"Some long text (currently LS lays out incorrectly)"}
              </span>
            </div>
          </div>
          <div style={Object.assign({}, styles.view2, {})}>
            <div style={Object.assign({}, styles.view4, {})}>
              <span style={Object.assign({}, styles.text1, {})}>
                {"Short"}
              </span>
            </div>
          </div>
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
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view1: {
    alignItems: "flex-start",
    backgroundColor: colors.red50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "100px"
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: colors.blue50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "100px"
  },
  view3: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  view4: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text1: {
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}