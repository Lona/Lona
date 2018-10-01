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
        <div style={Object.assign(styles.view, {})}>
          <span style={Object.assign(styles.text, {})}>
            {"Example nested component"}
          </span>
          <FitContentParentSecondaryChildren
            style={Object.assign(styles.fitContentParentSecondaryChildren, {})}

          />
          <span style={Object.assign(styles.text1, {})}>
            {"Text below"}
          </span>
          <LocalAsset style={Object.assign(styles.localAsset, {})} />
          <span style={Object.assign(styles.text2, {})}>
            {"Very bottom"}
          </span>
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
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  text: {
    ...textStyles.subheading2,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column",
    marginBottom: "8px"
  },
  fitContentParentSecondaryChildren: {
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text1: {
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column",
    marginTop: "12px"
  },
  localAsset: {
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text2: { alignItems: "stretch", display: "flex", flexDirection: "column" }
}