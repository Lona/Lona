import React from "react"
import { View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

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
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  view1: { backgroundColor: colors.blue500, height: 60, width: 60 },
  view3: { backgroundColor: colors.lightblue500, height: 120, width: 100 },
  view2: { backgroundColor: colors.cyan500, height: 180, width: 100 }
});