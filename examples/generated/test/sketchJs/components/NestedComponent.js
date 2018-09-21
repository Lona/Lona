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
    alignSelf: "stretch",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  text: { ...TextStyles.get("subheading2"), marginBottom: 8 },
  fitContentParentSecondaryChildren: {},
  text1: { marginTop: 12 },
  localAsset: {},
  text2: {}
})