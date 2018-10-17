import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import Optionals from "../logic/Optionals"

export default class NestedOptionals extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Optionals boolParam={null} stringParam={"Text"} />
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
  optionals: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  }
})