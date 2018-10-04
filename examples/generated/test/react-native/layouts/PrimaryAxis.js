import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.fixed, {} ]} />
        <View style={[ styles.fit, {} ]}>
          <Text style={[ styles.text, {} ]}>
            {"Text goes here"}
          </Text>
        </View>
        <View style={[ styles.fill1, {} ]} />
        <View style={[ styles.fill2, {} ]} />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24,
    height: 500
  },
  fixed: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    marginBottom: 24,
    width: 100,
    height: 100
  },
  fit: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flex: 0,
    marginBottom: 24,
    width: 100
  },
  fill1: {
    alignItems: "flex-start",
    backgroundColor: colors.cyan500,
    flex: 1,
    width: 100
  },
  fill2: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    flex: 1,
    width: 100
  },
  text: { ...textStyles.body1, alignItems: "flex-start", flex: 0 }
})