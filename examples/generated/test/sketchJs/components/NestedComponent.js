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
        <Text style={[ styles.text, {} ]} text={"Example nested component"}>
          {"Example nested component"}
        </Text>
        <FitContentParentSecondaryChildren
          style={[ styles.fitContentParentSecondaryChildren, {} ]}
        >

        </FitContentParentSecondaryChildren>
        <Text style={[ styles.text1, {} ]} text={"Text below"}>
          {"Text below"}
        </Text>
        <LocalAsset style={[ styles.localAsset, {} ]}>

        </LocalAsset>
        <Text style={[ styles.text2, {} ]} text={"Very bottom"}>
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