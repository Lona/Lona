import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"
import ComponentParameterTemplate from "./ComponentParameterTemplate"

export default class ComponentParameterInstance extends React.Component {
  render() {
    return (
      <div style={Object.assign(styles.view, {})}>
        <ComponentParameterTemplate
          style={Object.assign(styles.componentParameterTemplate, {})}
          subtitleComponent={{"parameters":{"text":"Subtitle","textStyle":"subheading2"},"type":"Lona:Text"}}
          titleComponent={{"parameters":{"text":"Title","textStyle":"headline"},"type":"Lona:Text"}}
        >

        </ComponentParameterTemplate>
      </div>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex" },
  componentParameterTemplate: { display: "flex" }
}