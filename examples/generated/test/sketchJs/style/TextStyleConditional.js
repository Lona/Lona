import React from "react"
import { Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextStyleConditional extends React.Component {
  render() {
    let Text$textStyle
    if (this.props.large) {
      Text$textStyle = "display2"
    }
    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, { font: Text$textStyle } ]}>
          {"Text goes here"}
        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  text: { ...TextStyles.get("headline") }
})