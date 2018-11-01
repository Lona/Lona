import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import FitContentParentSecondaryChildren from
  "../layouts/FitContentParentSecondaryChildren"
import LocalAsset from "../images/LocalAsset"

export default class NestedComponent extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <span style={styles.text}>
          {"Example nested component"}
        </span>
        <div style={styles.fitContentParentSecondaryChildren}>
          <FitContentParentSecondaryChildren />
        </div>
        <span style={styles.text1}>
          {"Text below"}
        </span>
        <div style={styles.localAsset}>
          <LocalAsset />
        </div>
        <span style={styles.text2}>
          {"Very bottom"}
        </span>
      </div>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  text: {
    textAlign: "left",
    ...textStyles.subheading2,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "8px"
  },
  fitContentParentSecondaryChildren: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  text1: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: "12px"
  },
  localAsset: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  text2: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}