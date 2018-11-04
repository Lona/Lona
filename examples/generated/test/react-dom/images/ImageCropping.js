import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class ImageCropping extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.aspectFit}>
          <img
            style={{
              width: "100%",
              height: "100%",
              objectFit: "contain",
              position: "absolute"
            }}
            src={require("../assets/icon_128x128.png")}

          />
        </div>
        <div style={styles.aspectFill}>
          <img
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
              position: "absolute"
            }}
            src={require("../assets/icon_128x128.png")}

          />
        </div>
        <div style={styles.stretchFill}>
          <img
            style={{
              width: "100%",
              height: "100%",
              objectFit: "stretch",
              position: "absolute"
            }}
            src={require("../assets/icon_128x128.png")}

          />
        </div>
        <img
          style={styles.fixedAspectFill}
          src={require("../assets/icon_128x128.png")}

        />
        <img
          style={styles.fixedStretch}
          src={require("../assets/icon_128x128.png")}

        />
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
  aspectFit: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  aspectFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  stretchFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    height: "100px",
    position: "relative"
  },
  fixedAspectFill: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    width: "200px",
    height: "100px",
    objectFit: "cover",
    position: "relative"
  },
  fixedStretch: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    overflow: "hidden",
    width: "200px",
    height: "100px",
    objectFit: "fill",
    position: "relative"
  }
}