import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "button": { "normal": {} },
      "view1": { "normal": {} },
      "button2": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.button, {})}>
            <Button label={"Button 1"} />
          </div>
          <div style={Object.assign({}, styles.view1, {})} />
          <div style={Object.assign({}, styles.button2, {})}>
            <Button label={"Button 2"} />
          </div>
        </div>
      </ThemeProvider>
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
  button: { alignSelf: "stretch", display: "flex", flexDirection: "row" },
  view1: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: "8px"
  },
  button2: { alignSelf: "stretch", display: "flex", flexDirection: "row" }
}