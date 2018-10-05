import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"
import FitContentParentSecondaryChildren from
  "../layouts/FitContentParentSecondaryChildren"
import LocalAsset from "../images/LocalAsset"

export default class NestedComponent extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, {} ]}>
          {"Example nested component"}
        </Text>
        <View style={[ styles.fitContentParentSecondaryChildren, {} ]}>
          <FitContentParentSecondaryChildren />
        </View>
        <Text style={[ styles.text1, {} ]}>
          {"Text below"}
        </Text>
        <View style={[ styles.localAsset, {} ]}>
          <LocalAsset />
        </View>
        <Text style={[ styles.text2, {} ]}>
          {"Very bottom"}
        </Text>
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
    justifyContent: "flex-start",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  text: {
    ...textStyles.subheading2,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: 8
  },
  fitContentParentSecondaryChildren: {
    alignItems: "stretch",
    flexDirection: "column"
  },
  text1: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: 12
  },
  localAsset: { alignItems: "stretch", flexDirection: "column" },
  text2: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})