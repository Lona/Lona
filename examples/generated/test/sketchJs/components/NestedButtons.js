import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Button style={[ styles.button, {} ]} label={"Button 1"} />
        <View style={[ styles.view1, {} ]} />
        <Button style={[ styles.button2, {} ]} label={"Button 2"} />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignSelf: "stretch",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  button: {},
  view1: { alignSelf: "stretch", height: 8 },
  button2: {}
})