import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class FillWidthFitHeightCard extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.image}>
          <img
            style={styles.imageResizeModeCover}
            src={require("../assets/icon_128x128.png")}

          />
        </div>
        <span style={styles.text1}>
          {"Title"}
        </span>
        <span style={styles.text}>
          {"Subtitle"}
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
  image: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.blue200,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  text1: {
    textAlign: "left",
    ...textStyles.body2,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  imageResizeModeCover: {
    width: "100%",
    height: "100%",
    objectFit: "cover",
    position: "absolute"
  }
}