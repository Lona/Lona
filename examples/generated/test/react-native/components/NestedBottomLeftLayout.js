// Compiled by Lona Version 0.5.2

import React from "react"
import { View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import LocalAsset from "../images/LocalAsset"

export default class NestedBottomLeftLayout extends React.Component {
  render() {



    return (
      <View style={styles.view}>
        <View style={styles.view1}>
          <View style={styles.localAsset}>
            <LocalAsset />
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
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  view1: {
    alignItems: "flex-end",
    backgroundColor: colors.red100,
    flexDirection: "row",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  localAsset: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  }
})