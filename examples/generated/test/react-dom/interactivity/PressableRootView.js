import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PressableRootView extends React.Component {
  render() {
    let Outer$onPress
    let Outer$backgroundColor
    let Inner$onPress
    let Inner$backgroundColor
    let InnerText$text
    Outer$onPress = this.props.onPressOuter
    Inner$onPress = this.props.onPressInner
    if (Outer$hovered) {
      Outer$backgroundColor = colors.grey100
    }
    if (Outer$pressed) {
      Outer$backgroundColor = colors.grey300
    }
    if (Inner$hovered) {
      Inner$backgroundColor = colors.blue300
      InnerText$text = "Hovered"
    }
    if (Inner$pressed) {
      Inner$backgroundColor = colors.blue800
      InnerText$text = "Pressed"
    }
    if (Inner$hovered) {
      if (Inner$pressed) {
        InnerText$text = "Hovered & Pressed"
      }
    }
    return (
      <div
        style={Object.assign(styles.outer, {
          backgroundColor: Outer$backgroundColor
        })}
        onClick={Outer$onPress}
      >
        <div
          style={Object.assign(styles.inner, {
            backgroundColor: Inner$backgroundColor
          })}
          onClick={Inner$onPress}
        >
          <span style={Object.assign(styles.innerText, {})}>
            {InnerText$text}
          </span>
        </div>
      </div>
    );
  }
};

let styles = {
  outer: {
    alignSelf: "stretch",
    backgroundColor: colors.grey50,
    display: "flex",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  inner: {
    backgroundColor: colors.blue500,
    display: "flex",
    width: "100px",
    height: "100px"
  },
  innerText: { ...textStyles.headline, display: "flex" }
}