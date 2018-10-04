import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"
import FitContentParentSecondaryChildren from
  "../layouts/FitContentParentSecondaryChildren"
import LocalAsset from "../images/LocalAsset"

export default class NestedComponent extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "text": { "normal": {} },
      "fitContentParentSecondaryChildren": { "normal": {} },
      "text1": { "normal": {} },
      "localAsset": { "normal": {} },
      "text2": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <span style={Object.assign({}, styles.text, {})}>
            {"Example nested component"}
          </span>
          <div
            style={Object.assign({}, styles
            .fitContentParentSecondaryChildren, {})}
          >
            <FitContentParentSecondaryChildren />
          </div>
          <span style={Object.assign({}, styles.text1, {})}>
            {"Text below"}
          </span>
          <div style={Object.assign({}, styles.localAsset, {})}>
            <LocalAsset />
          </div>
          <span style={Object.assign({}, styles.text2, {})}>
            {"Very bottom"}
          </span>
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
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  text: {
    ...textStyles.subheading2,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    marginBottom: "8px"
  },
  fitContentParentSecondaryChildren: {
    alignItems: "flex-start",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row"
  },
  text1: {
    ...textStyles.body1,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    marginTop: "12px"
  },
  localAsset: {
    alignItems: "flex-start",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row"
  },
  text2: {
    ...textStyles.body1,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column"
  }
}