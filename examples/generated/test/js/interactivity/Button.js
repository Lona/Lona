import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class Button extends React.Component {
  render() {
    let View$onPress;
    let View$backgroundColor;
    let Text$text;
    Text$text = this.props.label
    View$onPress = this.props.onTap
    if (View$hovered) {
      View$backgroundColor = "blue200"
    }
    if (View$pressed) {
      View$backgroundColor = "blue50"
    }
    return (
      <View
        style={[
          styles.view,
          { backgroundColor: View$backgroundColor, onPress: View$onPress }
        ]}
      >
        <Text style={[ styles.text, {} ]} text={Text$text}>

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    backgroundColor: colors.blue100,
    paddingBottom: 12,
    paddingLeft: 16,
    paddingRight: 16,
    paddingTop: 12
  },
  text: { font: "button" }
});