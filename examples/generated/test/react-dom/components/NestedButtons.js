import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {


    return (
      <div style={Object.assign({}, styles.view, {})}>
        <div style={Object.assign({}, styles.button, {})}>
          <Button label={"Button 1"} />
        </div>
        <div style={Object.assign({}, styles.view1, {})} />
        <div style={Object.assign({}, styles.button2, {})}>
          <Button label={"Button 2"} />
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
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  button: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view1: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "8px"
  },
  button2: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  }
}