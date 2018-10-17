import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import ComponentParameterTemplate from "./ComponentParameterTemplate"

export default class ComponentParameterInstance extends React.Component {
  render() {


    return (
      <div style={Object.assign({}, styles.view, {})}>
        <div style={Object.assign({}, styles.componentParameterTemplate, {})}>
          <ComponentParameterTemplate
            subtitleComponent={{"parameters":{"text":"Subtitle","textStyle":"subheading2"},"type":"Lona:Text"}}
            titleComponent={{"parameters":{"text":"Title","textStyle":"headline"},"type":"Lona:Text"}}

          />
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
  componentParameterTemplate: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  }
}