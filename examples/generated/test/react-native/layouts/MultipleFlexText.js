import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class MultipleFlexText extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]}>
          <View style={[ styles.view3, {} ]}>
            <Text style={[ styles.text, {} ]}>
              {"Some long text (currently LS lays out incorrectly)"}
            </Text>
          </View>
        </View>
        <View style={[ styles.view2, {} ]}>
          <View style={[ styles.view4, {} ]}>
            <Text style={[ styles.text1, {} ]}>
              {"Short"}
            </Text>
          </View>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view1: {
    alignItems: "flex-start",
    backgroundColor: colors.red50,
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: colors.blue50,
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100
  },
  view3: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  view4: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text1: {
    ...textStyles.body1,
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})