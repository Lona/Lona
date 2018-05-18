import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.fixed, {} ]}>

        </View>
        <View style={[ styles.fit, {} ]}>
          <Text style={[ styles.text, {} ]} text={"Text goes here"}>
            {"Text goes here"}
          </Text>
        </View>
        <View style={[ styles.fill1, {} ]}>

        </View>
        <View style={[ styles.fill2, {} ]}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignSelf: "stretch",
    height: 500,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  fixed: {
    backgroundColor: "#D8D8D8",
    height: 100,
    marginBottom: 24,
    width: 100
  },
  fit: { backgroundColor: "#D8D8D8", marginBottom: 24, width: 100 },
  text: {},
  fill1: { backgroundColor: colors.cyan500, flex: 1, width: 100 },
  fill2: { backgroundColor: colors.blue500, flex: 1, width: 100 }
});