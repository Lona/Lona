import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class PrimaryAxisFillSiblings extends React.Component {
  render() {


    return (
      <div style={styles.container}>
        <div style={styles.horizontal}>
          <div style={styles.leftCard}>
            <div style={styles.image}>
              <img
                style={styles.imageResizeModeCover}
                src={require("../assets/icon_128x128.png")}

              />
            </div>
            <span style={styles.title}>
              {"Title"}
            </span>
            <span style={styles.subtitle}>
              {"Subtitle"}
            </span>
          </div>
          <div style={styles.spacer} />
          <div style={styles.rightCard}>
            <div style={styles.image1}>
              <img
                style={styles.imageResizeModeCover}
                src={require("../assets/icon_128x128.png")}

              />
            </div>
            <span style={styles.title1}>
              {"Title"}
            </span>
            <span style={styles.subtitle1}>
              {"Subtitle"}
            </span>
          </div>
        </div>
      </div>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    backgroundColor: colors.teal50,
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "10px",
    paddingRight: "10px",
    paddingBottom: "10px",
    paddingLeft: "10px"
  },
  horizontal: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.teal100,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  leftCard: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  spacer: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "8px",
    height: "0px"
  },
  rightCard: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.teal200,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  title: {
    textAlign: "left",
    ...textStyles.body2,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  subtitle: {
    textAlign: "left",
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
    alignSelf: "stretch",
    backgroundColor: colors.teal200,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  title1: {
    textAlign: "left",
    ...textStyles.body2,
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  subtitle1: {
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