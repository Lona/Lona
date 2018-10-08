import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FitContentParentSecondaryChildren extends React.Component {
  render() {


    let theme = {
      "container": { "normal": {} },
      "view1": { "normal": {} },
      "view3": { "normal": {} },
      "view2": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.container, {})}>
          <div style={Object.assign({}, styles.view1, {})} />
          <div style={Object.assign({}, styles.view3, {})} />
          <div style={Object.assign({}, styles.view2, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    backgroundColor: colors.bluegrey50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "row",
    justifyContent: "flex-start",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  view1: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "60px",
    height: "60px"
  },
  view3: {
    alignItems: "flex-start",
    backgroundColor: colors.lightblue500,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "120px"
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: colors.cyan500,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "180px"
  }
}