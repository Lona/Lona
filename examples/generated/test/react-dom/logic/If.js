import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class If extends React.Component {
  render() {
    let View$backgroundColor
    if (this.props.enabled) {
      View$backgroundColor = colors.red500
    }
    return (
      <div
        style={Object.assign(styles.view, {
          backgroundColor: View$backgroundColor
        })}
      >

      </div>
    );
  }
};

let styles = { view: { alignSelf: "stretch", display: "flex" } }