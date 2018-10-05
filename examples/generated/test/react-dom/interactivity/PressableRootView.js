import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PressableRootView extends React.Component {
  render() {

    let InnerText$text
    let Inner$backgroundColor
    let Inner$hovered
    let Inner$onPress
    let Inner$pressed
    let Outer$backgroundColor
    let Outer$hovered
    let Outer$onPress
    let Outer$pressed
    Inner$backgroundColor = colors.blue500
    InnerText$text = ""
    Outer$backgroundColor = colors.grey50

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
    let theme = {
      "outer": { "normal": {} },
      "inner": { "normal": {} },
      "innerText": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div
          style={Object.assign({}, styles.outer, {
            backgroundColor: Outer$backgroundColor
          })}
          onClick={Outer$onPress}
        >
          <div
            style={Object.assign({}, styles.inner, {
              backgroundColor: Inner$backgroundColor
            })}
            onClick={Inner$onPress}
          >
            <span style={Object.assign({}, styles.innerText, {})}>
              {InnerText$text}
            </span>
          </div>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  outer: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  },
  innerText: {
    ...textStyles.headline,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}