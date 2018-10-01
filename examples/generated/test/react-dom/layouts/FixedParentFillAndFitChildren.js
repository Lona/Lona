import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FixedParentFillAndFitChildren extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "view1": { "normal": {} },
      "view4": { "normal": {} },
      "view5": { "normal": {} },
      "view2": { "normal": {} },
      "view3": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <div style={Object.assign(styles.view1, {})}>
            <div style={Object.assign(styles.view4, {})} />
            <div style={Object.assign(styles.view5, {})} />
          </div>
          <div style={Object.assign(styles.view2, {})} />
          <div style={Object.assign(styles.view3, {})} />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignItems: "stretch",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "600px"
  },
  view1: {
    alignItems: "stretch",
    alignSelf: "stretch",
    backgroundColor: colors.red50,
    display: "flex",
    flexDirection: "row",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  view4: {
    alignItems: "stretch",
    backgroundColor: colors.red200,
    display: "flex",
    flexDirection: "column",
    width: "60px",
    height: "100px"
  },
  view5: {
    alignItems: "stretch",
    backgroundColor: colors.deeporange200,
    display: "flex",
    flexDirection: "column",
    marginLeft: "12px",
    width: "60px",
    height: "60px"
  },
  view2: {
    alignItems: "stretch",
    alignSelf: "stretch",
    backgroundColor: colors.indigo100,
    display: "flex",
    flex: 1,
    flexDirection: "column"
  },
  view3: {
    alignItems: "stretch",
    alignSelf: "stretch",
    backgroundColor: colors.teal100,
    display: "flex",
    flex: 1,
    flexDirection: "column"
  }
}