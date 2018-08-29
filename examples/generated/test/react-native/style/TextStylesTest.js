import React from "react"
import { Text, View, StyleSheet } from "react-native"

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
  text: { ...textStyles.display4 },
  text1: { ...textStyles.display3 },
  text2: { ...textStyles.display2 },
  text3: { ...textStyles.display1 },
  text4: { ...textStyles.headline },
  text5: { ...textStyles.subheading2 },
  text6: { ...textStyles.subheading1 },
  text7: { ...textStyles.body2 },
  text8: { ...textStyles.body1 },
  text9: { ...textStyles.caption }
})