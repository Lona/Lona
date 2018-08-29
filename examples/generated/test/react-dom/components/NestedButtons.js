import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {
    return (
      <div style={Object.assign(styles.view, {})}>
        <Button style={Object.assign(styles.button, {})} label={"Button 1"}>

        </Button>
        <div style={Object.assign(styles.view1, {})}>

        </div>
        <Button style={Object.assign(styles.button2, {})} label={"Button 2"}>

        </Button>
      </div>
    );
  }
};

let styles = {
  view: {
    alignSelf: "stretch",
    display: "flex",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  button: { display: "flex" },
  view1: { alignSelf: "stretch", display: "flex", height: "8px" },
  button2: { display: "flex" }
}