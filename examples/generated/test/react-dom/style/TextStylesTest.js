import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextStylesTest extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <span style={styles.text}>
          {"Text goes here"}
        </span>
        <span style={styles.text1}>
          {"Text goes here"}
        </span>
        <span style={styles.text2}>
          {"Text goes here"}
        </span>
        <span style={styles.text3}>
          {"Text goes here"}
        </span>
        <span style={styles.text4}>
          {"Text goes here"}
        </span>
        <span style={styles.text5}>
          {"Text goes here"}
        </span>
        <span style={styles.text6}>
          {"Text goes here"}
        </span>
        <span style={styles.text7}>
          {"Text goes here"}
        </span>
        <span style={styles.text8}>
          {"Text goes here"}
        </span>
        <span style={styles.text9}>
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
    ...textStyles.display4,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text1: {
    ...textStyles.display3,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text2: {
    ...textStyles.display2,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text3: {
    ...textStyles.display1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text4: {
    ...textStyles.headline,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text5: {
    ...textStyles.subheading2,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text6: {
    ...textStyles.subheading1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text7: {
    ...textStyles.body2,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text8: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text9: {
    ...textStyles.caption,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}