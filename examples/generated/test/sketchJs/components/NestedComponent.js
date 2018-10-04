import React from "react"
import { Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

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
        <FitContentParentSecondaryChildren
          style={[ styles.fitContentParentSecondaryChildren, {} ]}

        />
        <Text style={[ styles.text1, {} ]}>
          {"Text below"}
        </Text>
        <LocalAsset style={[ styles.localAsset, {} ]} />
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
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  text: {
    ...TextStyles.get("subheading2"),
    alignItems: "flex-start",
    flex: 0,
    marginBottom: 8
  },
  fitContentParentSecondaryChildren: {
    alignItems: "stretch",
    flex: 0,
    flexDirection: "column"
  },
  text1: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    marginTop: 12
  },
  localAsset: { alignItems: "stretch", flex: 0, flexDirection: "column" },
  text2: { ...TextStyles.get("body1"), alignItems: "flex-start", flex: 0 }
})