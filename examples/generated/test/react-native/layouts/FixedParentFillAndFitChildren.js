import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FixedParentFillAndFitChildren extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]}>
          <View style={[ styles.view4, {} ]} />
          <View style={[ styles.view5, {} ]} />
        </View>
        <View style={[ styles.view2, {} ]} />
        <View style={[ styles.view3, {} ]} />
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
    paddingLeft: 24,
    height: 600
  },
  view1: {
    alignSelf: "stretch",
    backgroundColor: colors.red50,
    flexDirection: "row",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  view4: { backgroundColor: colors.red200, width: 60, height: 100 },
  view5: {
    backgroundColor: colors.deeporange200,
    marginLeft: 12,
    width: 60,
    height: 60
  },
  view2: { alignSelf: "stretch", backgroundColor: colors.indigo100, flex: 1 },
  view3: { alignSelf: "stretch", backgroundColor: colors.teal100, flex: 1 }
})