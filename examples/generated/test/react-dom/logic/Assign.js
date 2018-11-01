import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class Assign extends React.Component {
  render() {

    let Text$text

    Text$text = this.props.text
    return (
      <div style={styles.view}>
        <span style={styles.text}>
          {Text$text}
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
    textAlign: "left",
    ...textStyles.body1,
    alignItems: "flex-start",
    display: "block",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
}