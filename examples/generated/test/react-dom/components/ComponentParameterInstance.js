import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import textStyles from "../textStyles"
import ComponentParameterTemplate from "./ComponentParameterTemplate"

export default class ComponentParameterInstance extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "componentParameterTemplate": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign(styles.view, {})}>
          <ComponentParameterTemplate
            style={Object.assign(styles.componentParameterTemplate, {})}
            subtitleComponent={{"parameters":{"text":"Subtitle","textStyle":"subheading2"},"type":"Lona:Text"}}
            titleComponent={{"parameters":{"text":"Title","textStyle":"headline"},"type":"Lona:Text"}}

          />
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex", flexDirection: "column" },
  componentParameterTemplate: { display: "flex", flexDirection: "column" }
}