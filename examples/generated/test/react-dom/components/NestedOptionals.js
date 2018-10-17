import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import Optionals from "../logic/Optionals"

export default class NestedOptionals extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.optionals}>
          <Optionals boolParam={null} stringParam={"Text"} />
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
    justifyContent: "flex-start"
  },
  optionals: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  }
}