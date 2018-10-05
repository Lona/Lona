import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"
import ComponentParameterTemplate from "./ComponentParameterTemplate"

export default class ComponentParameterInstance extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.componentParameterTemplate, {} ]}>
          <ComponentParameterTemplate
            subtitleComponent={{"parameters":{"text":"Subtitle","textStyle":"subheading2"},"type":"Lona:Text"}}
            titleComponent={{"parameters":{"text":"Title","textStyle":"headline"},"type":"Lona:Text"}}

          />
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  componentParameterTemplate: { alignItems: "stretch", flexDirection: "column" }
})