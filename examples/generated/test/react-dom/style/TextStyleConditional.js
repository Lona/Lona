import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextStyleConditional extends React.Component {
  render() {

    let Text$textStyle
    Text$textStyle = textStyles.headline

    if (this.props.large) {
      Text$textStyle = textStyles.display2
    }
    return (
      <div style={styles.view}>
        <span style={Object.assign({}, styles.text, { ...Text$textStyle })}>
          {"Text goes here"}
        </span>
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
    justifyContent: "flex-start"
  },
  text: {
    textAlign: "left",
    ...textStyles.headline,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}