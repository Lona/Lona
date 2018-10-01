import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"

export default class Assign extends React.Component {
  render() {

    let Text$text

    Text$text = this.props.text
    let theme = { "view": { "normal": {} }, "text": { "normal": {} } }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <span style={Object.assign(styles.text, {})}>
            {Text$text}
          </span>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex", flexDirection: "column" },
  text: { display: "flex", flexDirection: "column" }
}