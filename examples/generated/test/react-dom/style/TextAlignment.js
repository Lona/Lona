import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "view1": { "normal": {} },
      "image": { "normal": {} },
      "view2": { "normal": {} },
      "text": { "normal": {} },
      "text1": { "normal": {} },
      "text2": { "normal": {} },
      "text3": { "normal": {} },
      "text4": { "normal": {} },
      "view3": { "normal": {} },
      "text5": { "normal": {} },
      "view4": { "normal": {} },
      "text6": { "normal": {} },
      "view5": { "normal": {} },
      "text7": { "normal": {} },
      "view6": { "normal": {} },
      "text8": { "normal": {} },
      "rightAlignmentContainer": { "normal": {} },
      "text9": { "normal": {} },
      "text10": { "normal": {} },
      "image1": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <div style={Object.assign(styles.view1, {})}>
            <img
              style={Object.assign(styles.image, {})}
              source={require("../assets/icon_128x128.png")}

            />
            <div style={Object.assign(styles.view2, {})} />
            <span style={Object.assign(styles.text, {})}>
              {"Welcome to Lona Studio"}
            </span>
            <span style={Object.assign(styles.text1, {})}>
              {"Centered - Width: Fit"}
            </span>
            <span style={Object.assign(styles.text2, {})}>
              {"Left aligned - Width: Fill"}
            </span>
            <span style={Object.assign(styles.text3, {})}>
              {"Right aligned - Width: Fill"}
            </span>
            <span style={Object.assign(styles.text4, {})}>
              {"Centered - Width: 80"}
            </span>
          </div>
          <div style={Object.assign(styles.view3, {})}>
            <span style={Object.assign(styles.text5, {})}>
              {"Left aligned text, Fit w/ secondary centering"}
            </span>
          </div>
          <div style={Object.assign(styles.view4, {})}>
            <span style={Object.assign(styles.text6, {})}>
              {"Left aligned text, Fixed w/ secondary centering"}
            </span>
          </div>
          <div style={Object.assign(styles.view5, {})}>
            <span style={Object.assign(styles.text7, {})}>
              {"Centered text, Fit parent no centering"}
            </span>
          </div>
          <div style={Object.assign(styles.view6, {})}>
            <span style={Object.assign(styles.text8, {})}>
              {"Centered text, Fixed parent no centering"}
            </span>
          </div>
          <div style={Object.assign(styles.rightAlignmentContainer, {})}>
            <span style={Object.assign(styles.text9, {})}>
              {"Fit Text"}
            </span>
            <span style={Object.assign(styles.text10, {})}>
              {"Fill and center aligned text"}
            </span>
            <img
              style={Object.assign(styles.image1, {})}
              source={require("../assets/icon_128x128.png")}

            />
          </div>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  view1: {
    alignItems: "center",
    alignSelf: "stretch",
    backgroundColor: colors.indigo50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "center"
  },
  image: {
    display: "flex",
    flexDirection: "column",
    width: "100px",
    height: "100px"
  },
  view2: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column"
  },
  text: {
    textAlign: "center",
    ...textStyles.display1,
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    marginTop: "16px"
  },
  text1: {
    textAlign: "center",
    ...textStyles.subheading2,
    display: "flex",
    flexDirection: "column",
    marginTop: "16px"
  },
  text2: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    marginTop: "12px"
  },
  text3: {
    textAlign: "right",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  text4: {
    textAlign: "center",
    display: "flex",
    flexDirection: "column",
    width: "80px"
  },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  text5: { display: "flex", flexDirection: "column" },
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  text6: { display: "flex", flexDirection: "column" },
  view5: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  text7: { textAlign: "center", display: "flex", flexDirection: "column" },
  view6: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  text8: {
    textAlign: "center",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column"
  },
  text9: { display: "flex", flexDirection: "column" },
  text10: {
    textAlign: "center",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column"
  },
  image1: {
    display: "flex",
    flexDirection: "column",
    width: "100px",
    height: "100px"
  }
}