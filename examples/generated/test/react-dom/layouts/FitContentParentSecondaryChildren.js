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
        <div style={Object.assign(styles.container, {})}>
          <div style={Object.assign(styles.view1, {})} />
          <div style={Object.assign(styles.view3, {})} />
          <div style={Object.assign(styles.view2, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  container: {
    alignSelf: "stretch",
    backgroundColor: colors.bluegrey50,
    display: "flex",
    flexDirection: "row",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  view1: {
    backgroundColor: colors.blue500,
    display: "flex",
    flexDirection: "column",
    width: "60px",
    height: "60px"
  },
  view3: {
    backgroundColor: colors.lightblue500,
    display: "flex",
    flexDirection: "column",
    width: "100px",
    height: "120px"
  },
  view2: {
    backgroundColor: colors.cyan500,
    display: "flex",
    flexDirection: "column",
    width: "100px",
    height: "180px"
  }
}