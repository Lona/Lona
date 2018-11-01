import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.view1}>
          <img
            style={styles.image}
            src={require("../assets/icon_128x128.png")}

          />
          <div style={styles.view2} />
          <span style={styles.text}>
            {"Welcome to Lona Studio"}
          </span>
          <span style={styles.text1}>
            {"Centered - Width: Fit"}
          </span>
          <span style={styles.text2}>
            {"Left aligned - Width: Fill"}
          </span>
          <span style={styles.text3}>
            {"Right aligned - Width: Fill"}
          </span>
          <span style={styles.text4}>
            {"Centered - Width: 80"}
          </span>
        </div>
        <div style={styles.view3}>
          <span style={styles.text5}>
            {"Left aligned text, Fit w/ secondary centering"}
          </span>
        </div>
        <div style={styles.view4}>
          <span style={styles.text6}>
            {"Left aligned text, Fixed w/ secondary centering"}
          </span>
        </div>
        <div style={styles.view5}>
          <span style={styles.text7}>
            {"Centered text, Fit parent no centering"}
          </span>
        </div>
        <div style={styles.view6}>
          <span style={styles.text8}>
            {"Centered text, Fixed parent no centering"}
          </span>
        </div>
        <div style={styles.rightAlignmentContainer}>
          <span style={styles.text9}>
            {"Fit Text"}
          </span>
          <span style={styles.text10}>
            {"Fill and center aligned text"}
          </span>
          <img
            style={styles.image1}
            src={require("../assets/icon_128x128.png")}

          />
        </div>
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
    justifyContent: "flex-start",
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
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "center"
  },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  view5: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: "12px",
    paddingLeft: "12px"
  },
  view6: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: "12px",
    paddingLeft: "12px",
    width: "400px"
  },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    textAlign: "center",
    ...textStyles.display1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: "16px",
    overflow: "hidden",
    maxHeight: "80px"
  },
  text1: {
    textAlign: "center",
    ...textStyles.subheading2,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: "16px"
  },
  text2: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: "12px"
  },
  text3: {
    textAlign: "right",
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text4: {
    textAlign: "center",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "80px"
  },
  text5: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text6: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text7: {
    textAlign: "center",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text8: {
    textAlign: "center",
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text9: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text10: {
    textAlign: "center",
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image1: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  }
}