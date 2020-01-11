import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../foundation/colors"
import shadows from "../foundation/shadows"
import textStyles from "../foundation/textStyles"

export default class TextStyleConditional extends React.Component {
  render() {


    let Text$textStyle
    Text$textStyle = textStyles.headline

    if (this.props.large) {

      Text$textStyle = textStyles.display2
    }
    return (
      <View style={styles.view}>
        <Text style={[styles.text, { ...Text$textStyle }]}>
          {"Text goes here"}
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
    justifyContent: "flex-start"
  },
  text: {
    ...textStyles.headline,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})