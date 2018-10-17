import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class FitContentParentSecondaryChildren extends React.Component {
  render() {


    return (
      <div style={styles.container}>
        <div style={styles.view1} />
        <div style={styles.view3} />
        <div style={styles.view2} />
      </div>
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