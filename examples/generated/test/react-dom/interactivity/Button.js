import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class Button extends React.Component {
  render() {
    let View$onPress
    let View$backgroundColor
    let Text$text
    Text$text = this.props.label
    View$onPress = this.props.onTap
    if (View$hovered) {
      View$backgroundColor = colors.blue200
    }
    if (View$pressed) {
      View$backgroundColor = colors.blue50
    }
    if (this.props.secondary==={"case":"Some","data":true}) {
      colors.lightblue100 = View$backgroundColor
    }
    return (
      <div
        style={Object.assign(styles.view, {
          backgroundColor: View$backgroundColor
        })}
        onClick={View$onPress}
      >
        <span style={Object.assign(styles.text, {})}>
          {Text$text}
        </span>
      </div>
    );
  }
};

let styles = {
  view: {
    backgroundColor: colors.blue100,
    display: "flex",
    paddingTop: "12px",
    paddingRight: "16px",
    paddingBottom: "12px",
    paddingLeft: "16px"
  },
  text: { ...textStyles.button, display: "flex" }
}