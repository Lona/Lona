import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class If extends React.Component {
  render() {


    let View$backgroundColor
    View$backgroundColor = "transparent"

    if (this.props.enabled) {

      View$backgroundColor = colors.red500
    }
    return (
      <View style={[styles.view, { backgroundColor: View$backgroundColor }]} />
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
  }
})