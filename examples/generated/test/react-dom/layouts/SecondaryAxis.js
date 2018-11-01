import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {


    return (
      <div style={styles.container}>
        <div style={styles.fixed} />
        <div style={styles.fit}>
          <span style={styles.text}>
            {"Text goes here"}
          </span>
        </div>
        <div style={styles.fill} />
      </div>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
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
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: "24px",
    paddingTop: "12px",
    paddingRight: "12px",
    paddingBottom: "12px",
    paddingLeft: "12px",
    height: "100px"
  },
  fill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "100px"
  },
  text: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}