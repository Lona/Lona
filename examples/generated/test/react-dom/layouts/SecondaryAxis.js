import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {


    return (
      <div style={Object.assign(styles.container, {})}>
        <div style={Object.assign(styles.fixed, {})}>

        </div>
        <div style={Object.assign(styles.fit, {})}>
          <span style={Object.assign(styles.text, {})}>
            {"Text goes here"}
          </span>
        </div>
        <div style={Object.assign(styles.fill, {})}>

        </div>
      </div>
    );
  }
};

let styles = {
  container: {
    alignSelf: "stretch",
    display: "flex",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
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
    paddingTop: "12px",
    paddingRight: "12px",
    paddingBottom: "12px",
    paddingLeft: "12px",
    height: "100px"
  },
  text: { display: "flex" },
  fill: {
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    height: "100px"
  }
}