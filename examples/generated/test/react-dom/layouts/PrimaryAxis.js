import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.fixed} />
        <div style={styles.fit}>
          <span style={styles.text}>
            {"Text goes here"}
          </span>
        </div>
        <div style={styles.fill1} />
        <div style={styles.fill2} />
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
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "500px"
  },
  fixed: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "24px",
    width: "100px",
    height: "100px"
  },
  fit: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "24px",
    width: "100px"
  },
  fill1: {
    alignItems: "flex-start",
    backgroundColor: colors.cyan500,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px"
  },
  fill2: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px"
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}