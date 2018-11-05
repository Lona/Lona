import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import FillWidthFitHeightCard from "./FillWidthFitHeightCard"

export default class PrimaryAxisFillNestedSiblings extends React.Component {
  render() {


    return (
      <div style={styles.container}>
        <div style={styles.horizontal}>
          <FillWidthFitHeightCard />
          <div style={styles.spacer} />
          <FillWidthFitHeightCard />
        </div>
      </div>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    backgroundColor: colors.teal50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  horizontal: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.teal100,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  leftCard: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  spacer: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "8px",
    height: "0px"
  },
  rightCard: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  }
}