import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import Optionals from "../logic/Optionals"

export default class NestedOptionals extends React.Component {
  render() {


    let theme = { "view": { "normal": {} }, "optionals": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.optionals, {})}>
            <Optionals boolParam={null} stringParam={"Text"} />
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