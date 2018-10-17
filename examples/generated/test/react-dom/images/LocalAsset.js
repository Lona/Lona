import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class LocalAsset extends React.Component {
  render() {


    return (
      <div style={Object.assign({}, styles.view, {})}>
        <img
          style={Object.assign({}, styles.image, {})}
          src={require("../assets/icon_128x128.png")}

        />
      </div>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    backgroundColor: colors.red400,
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  }
}