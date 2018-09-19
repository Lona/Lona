import React from "react"
import { Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextStylesTest extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text1, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text2, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text3, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text4, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text5, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text6, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text7, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text8, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text9, {} ]}>
          {"Text goes here"}
        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  text: { ...TextStyles.get("display4") },
  text1: { ...TextStyles.get("display3") },
  text2: { ...TextStyles.get("display2") },
  text3: { ...TextStyles.get("display1") },
  text4: { ...TextStyles.get("headline") },
  text5: { ...TextStyles.get("subheading2") },
  text6: { ...TextStyles.get("subheading1") },
  text7: { ...TextStyles.get("body2") },
  text8: { ...TextStyles.get("body1") },
  text9: { ...TextStyles.get("caption") }
})