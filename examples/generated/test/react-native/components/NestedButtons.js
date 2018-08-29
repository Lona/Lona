import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"
import Button from "../interactivity/Button"

export default class NestedButtons extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <Button style={[ styles.button, {} ]} label={"Button 1"}>

        </Button>
        <View style={[ styles.view1, {} ]}>

        </View>
        <Button style={[ styles.button2, {} ]} label={"Button 2"}>

        </Button>
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