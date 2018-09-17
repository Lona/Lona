import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {


    return (
      <div style={Object.assign(styles.view, {})}>
        <div style={Object.assign(styles.view1, {})}>
          <img
            style={Object.assign(styles.image, {})}
            source={require("../assets/icon_128x128.png")}
          >

          </img>
          <div style={Object.assign(styles.view2, {})}>

          </div>
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
          >

          </img>
        </div>
      </div>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
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
    justifyContent: "center"
  },
  image: { display: "flex", width: "100px", height: "100px" },
  view2: { backgroundColor: "#D8D8D8", display: "flex" },
  text: {
    textAlign: "center",
    ...textStyles.display1,
    alignSelf: "stretch",
    display: "flex",
    marginTop: "16px"
  },
  text1: {
    textAlign: "center",
    ...textStyles.subheading2,
    display: "flex",
    marginTop: "16px"
  },
  text2: { alignSelf: "stretch", display: "flex", marginTop: "12px" },
  text3: { textAlign: "right", alignSelf: "stretch", display: "flex" },
  text4: { textAlign: "center", display: "flex", width: "80px" },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  text5: { display: "flex" },
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  text6: { display: "flex" },
  view5: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  text7: { textAlign: "center", display: "flex" },
  view6: {
    backgroundColor: "#D8D8D8",
    display: "flex",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  text8: { textAlign: "center", alignSelf: "stretch", display: "flex" },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex"
  },
  text9: { display: "flex" },
  text10: { textAlign: "center", alignSelf: "stretch", display: "flex" },
  image1: { display: "flex", width: "100px", height: "100px" }
}