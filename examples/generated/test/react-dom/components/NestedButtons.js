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
        <div style={Object.assign(styles.view, {})}>
          <Button style={Object.assign(styles.button, {})} label={"Button 1"} />
          <div style={Object.assign(styles.view1, {})} />
          <Button
            style={Object.assign(styles.button2, {})}
            label={"Button 2"}

          />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    paddingTop: "24px",
    paddingRight: "24px",
    paddingBottom: "24px",
    paddingLeft: "24px"
  },
  button: { display: "flex", flexDirection: "column" },
  view1: {
    alignSelf: "stretch",
    display: "flex",
    flexDirection: "column",
    height: "8px"
  },
  button2: { display: "flex", flexDirection: "column" }
}