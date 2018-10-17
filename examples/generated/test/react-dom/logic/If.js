import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class If extends React.Component {
  render() {

    let View$backgroundColor
    View$backgroundColor = "transparent"

    if (this.props.enabled) {
      View$backgroundColor = colors.red500
    }
    return (
      <div
        style={Object.assign({}, styles.view, {
          backgroundColor: View$backgroundColor
        })}

      />
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
  }
}