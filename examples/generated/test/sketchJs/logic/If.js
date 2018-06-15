import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class If extends React.Component {
  render() {
    let View$backgroundColor
    if (this.props.enabled) {
      View$backgroundColor = "red500"
    }
    return (
      <View style={[ styles.view, { backgroundColor: View$backgroundColor } ]}>

      </View>
    );
  }
};

let styles = StyleSheet.create({ view: { alignSelf: "stretch" } })