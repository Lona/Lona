import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FixedParentFitChild extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]}>
          <View style={[ styles.view4, {} ]} />
          <View style={[ styles.view5, {} ]} />
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.bluegrey100,
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24,
    height: 600
  },
  view1: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.red50,
    flex: 0,
    flexDirection: "row",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  view4: {
    alignItems: "flex-start",
    backgroundColor: colors.red200,
    width: 60,
    height: 100
  },
  view5: {
    alignItems: "flex-start",
    backgroundColor: colors.deeporange200,
    marginLeft: 12,
    width: 60,
    height: 60
  }
})