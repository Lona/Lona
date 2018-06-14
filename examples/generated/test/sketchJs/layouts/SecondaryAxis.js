import React from "react"
import { Text, View, StyleSheet } from "react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {
    return (
      <View style={[ styles.container, {} ]}>
        <View style={[ styles.fixed, {} ]}>

        </View>
        <View style={[ styles.fit, {} ]}>
          <Text style={[ styles.text, {} ]} text={"Text goes here"}>
            {"Text goes here"}
          </Text>
        </View>
        <View style={[ styles.fill, {} ]}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  container: {
    alignSelf: "stretch",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  fixed: {
    backgroundColor: "#D8D8D8",
    marginBottom: 24,
    width: 100,
    height: 100
  },
  fit: {
    backgroundColor: "#D8D8D8",
    marginBottom: 24,
    paddingTop: 12,
    paddingRight: 12,
    paddingBottom: 12,
    paddingLeft: 12,
    height: 100
  },
  text: {},
  fill: { alignSelf: "stretch", backgroundColor: "#D8D8D8", height: 100 }
})