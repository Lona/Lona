import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextStyleConditional extends React.Component {
  render() {
    let Text$textStyle
    if (this.props.large) {
      Text$textStyle = "display2"
    }
    return (
      <div style={Object.assign(styles.view, {})}>
        <span style={Object.assign(styles.text, { font: Text$textStyle })}>
          {"Text goes here"}
        </span>
      </div>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex" },
  text: { ...textStyles.headline, display: "flex" }
}