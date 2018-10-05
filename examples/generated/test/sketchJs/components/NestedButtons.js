import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.button, {} ]}>
          <Button label={"Button 1"} />
        </View>
        <View style={[ styles.view1, {} ]} />
        <View style={[ styles.button2, {} ]}>
          <Button label={"Button 2"} />
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
    justifyContent: "flex-start",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  button: { alignItems: "stretch", flexDirection: "column" },
  view1: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 8
  },
  button2: { alignItems: "stretch", flexDirection: "column" }
})