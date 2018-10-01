import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class BoxModelConditional extends React.Component {
  render() {

    let Inner$height
    let Inner$marginBottom
    let Inner$marginLeft
    let Inner$marginRight
    let Inner$marginTop
    let Inner$width

    Inner$marginTop = this.props.margin
    Inner$marginRight = this.props.margin
    Inner$marginBottom = this.props.margin
    Inner$marginLeft = this.props.margin
    Inner$height = this.props.size
    Inner$width = this.props.size
    let theme = { "outer": { "normal": {} }, "inner": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.outer, {})}>
          <div
            style={Object.assign(styles.inner, {
              marginTop: Inner$marginTop,
              marginRight: Inner$marginRight,
              marginBottom: Inner$marginBottom,
              marginLeft: Inner$marginLeft,
              width: Inner$width,
              height: Inner$height
            })}

          />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  outer: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "4px",
    paddingRight: "4px",
    paddingBottom: "4px",
    paddingLeft: "4px"
  },
  inner: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    width: "60px",
    height: "60px"
  }
}