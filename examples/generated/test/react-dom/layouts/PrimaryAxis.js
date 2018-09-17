import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {


    return (
      <div style={Object.assign(styles.view, {})}>
        <div style={Object.assign(styles.fixed, {})}>

        </div>
        <div style={Object.assign(styles.fit, {})}>
          <span style={Object.assign(styles.text, {})}>
            {"Text goes here"}
          </span>
        </div>
        <div style={Object.assign(styles.fill1, {})}>

        </div>
        <div style={Object.assign(styles.fill2, {})}>

        </div>
      </div>
    );
  }
};

let styles = {
  view: {
    alignSelf: "stretch",
    display: "flex",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px",
    height: "500px"
  },
  fixed: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    marginBottom: "24px",
    width: "100px",
    height: "100px"
  },
  fit: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    marginBottom: "24px",
    width: "100px"
  },
  text: { display: "flex" },
  fill1: {
    backgroundColor: colors.cyan500,
    display: "flex",
    flex: 1,
    width: "100px"
  },
  fill2: {
    backgroundColor: colors.blue500,
    display: "flex",
    flex: 1,
    width: "100px"
  }
}