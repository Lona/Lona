import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextStylesTest extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "text": { "normal": {} },
      "text1": { "normal": {} },
      "text2": { "normal": {} },
      "text3": { "normal": {} },
      "text4": { "normal": {} },
      "text5": { "normal": {} },
      "text6": { "normal": {} },
      "text7": { "normal": {} },
      "text8": { "normal": {} },
      "text9": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <span style={Object.assign(styles.text, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text1, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text2, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text3, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text4, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text5, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text6, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text7, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text8, {})}>
            {"Text goes here"}
          </span>
          <span style={Object.assign(styles.text9, {})}>
            {"Text goes here"}
          </span>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignItems: "stretch",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text: {
    ...textStyles.display4,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text1: {
    ...textStyles.display3,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text2: {
    ...textStyles.display2,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text3: {
    ...textStyles.display1,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text4: {
    ...textStyles.headline,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text5: {
    ...textStyles.subheading2,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text6: {
    ...textStyles.subheading1,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text7: {
    ...textStyles.body2,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text8: {
    ...textStyles.body1,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text9: {
    ...textStyles.caption,
    alignItems: "stretch",
    display: "flex",
    flexDirection: "column"
  }
}