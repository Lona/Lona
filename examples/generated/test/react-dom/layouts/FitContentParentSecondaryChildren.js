import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FitContentParentSecondaryChildren extends React.Component {
  render() {


    return (
      <div style={Object.assign(styles.container, {})}>
        <div style={Object.assign(styles.view1, {})}>

        </div>
        <div style={Object.assign(styles.view3, {})}>

        </div>
        <div style={Object.assign(styles.view2, {})}>

        </div>
      </div>
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
    width: "60px",
    height: "60px"
  },
  view3: {
    backgroundColor: colors.lightblue500,
    display: "flex",
    width: "100px",
    height: "120px"
  },
  view2: {
    backgroundColor: colors.cyan500,
    display: "flex",
    width: "100px",
    height: "180px"
  }
}