import React from "react"
import { View, StyleSheet } from "react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class FitContentParentSecondaryChildren extends React.Component {
  render() {
    return (
      <View style={[ styles.container, {} ]}>
        <View style={[ styles.view1, {} ]}>

        </View>
        <View style={[ styles.view3, {} ]}>

        </View>
        <View style={[ styles.view2, {} ]}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  container: {
    alignSelf: "stretch",
    backgroundColor: colors.bluegrey50,
    flexDirection: "row",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  view1: { backgroundColor: colors.blue500, width: 60, height: 60 },
  view3: { backgroundColor: colors.lightblue500, width: 100, height: 120 },
  view2: { backgroundColor: colors.cyan500, width: 100, height: 180 }
})