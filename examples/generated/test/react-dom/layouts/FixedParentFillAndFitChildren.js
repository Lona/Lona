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
    alignSelf: "stretch",
    display: "flex",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "600px"
  },
  view1: {
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
    backgroundColor: colors.red200,
    display: "flex",
    width: "60px",
    height: "100px"
  },
  view5: {
    backgroundColor: colors.deeporange200,
    display: "flex",
    marginLeft: "12px",
    width: "60px",
    height: "60px"
  },
  view2: {
    alignSelf: "stretch",
    backgroundColor: colors.indigo100,
    display: "flex",
    flex: 1
  },
  view3: {
    alignSelf: "stretch",
    backgroundColor: colors.teal100,
    display: "flex",
    flex: 1
  }
}