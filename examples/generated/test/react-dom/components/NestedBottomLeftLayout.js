import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import LocalAsset from "../images/LocalAsset"

export default class NestedBottomLeftLayout extends React.Component {
  render() {


    return (
      <div style={Object.assign({}, styles.view, {})}>
        <div style={Object.assign({}, styles.view1, {})}>
          <LocalAsset />
        </div>
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
    justifyContent: "flex-start"
  },
  view1: {
    alignItems: "flex-end",
    backgroundColor: colors.red100,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  localAsset: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  }
}