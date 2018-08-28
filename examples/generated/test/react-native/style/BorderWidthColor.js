import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  view1: {
    borderRadius: 10,
    borderWidth: 20,
    borderColor: colors.blue300,
    width: 100,
    height: 100
  }
})