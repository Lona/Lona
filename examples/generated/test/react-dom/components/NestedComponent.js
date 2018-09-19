import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"
import FitContentParentSecondaryChildren from
  "../layouts/FitContentParentSecondaryChildren"
import LocalAsset from "../images/LocalAsset"

export default class NestedComponent extends React.Component {
  render() {


    return (
      <div style={Object.assign(styles.view, {})}>
        <span style={Object.assign(styles.text, {})}>
          {"Example nested component"}
        </span>
        <FitContentParentSecondaryChildren
          style={Object.assign(styles.fitContentParentSecondaryChildren, {})}
        >

        </FitContentParentSecondaryChildren>
        <span style={Object.assign(styles.text1, {})}>
          {"Text below"}
        </span>
        <LocalAsset style={Object.assign(styles.localAsset, {})}>

        </LocalAsset>
        <span style={Object.assign(styles.text2, {})}>
          {"Very bottom"}
        </span>
      </div>
    );
  }
};

let styles = {
  view: {
    alignSelf: "stretch",
    display: "flex",
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  text: { ...textStyles.subheading2, display: "flex", marginBottom: "8px" },
  fitContentParentSecondaryChildren: { display: "flex" },
  text1: { display: "flex", marginTop: "12px" },
  localAsset: { display: "flex" },
  text2: { display: "flex" }
}