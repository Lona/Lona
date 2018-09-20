import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class ThemeTest extends React.Component {
  render() {


    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>

        </div>
      </ThemeProvider>
    );
  }
};

let styles = { view: { display: "flex" } }